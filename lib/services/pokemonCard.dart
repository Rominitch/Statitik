import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

/// Pokemon region
class Region {
  List<String> _fullName;
  List<String> _applyPokemonName;

  Region(this._fullName, this._applyPokemonName);

  String name(Language l) {
    assert(l.id-1 < _fullName.length);
    return _fullName[l.id-1];
  }

  String applyToPokemonName(Language l) {
    assert(l.id-1 < _applyPokemonName.length);
    return _applyPokemonName[l.id-1];
  }
}

/// Special name to give (flying pikachu, ...)
class Forme
{
  List<String> _applyPokemonName;

  Forme(this._applyPokemonName);

  String applyToPokemonName(Language l) {
    assert(l.id-1 < _applyPokemonName.length);
    return _applyPokemonName[l.id-1];
  }
}

/// Full pokemon definition
class Pokemon {
  NamedInfo   name;
  Region?     region;
  Forme?      forme;

  Pokemon(this.name, {this.region, this.forme});

  static const int byteLength = 4;

  static Pokemon loadBytes(pointer, bytes) {
    int idName = bytes[pointer] << 8 | bytes[pointer+1];
    assert(idName != 0);

    Pokemon p = Pokemon(idName < 10000
              ? Environment.instance.collection.getPokemonID(idName)
              : Environment.instance.collection.getNamedID(idName));
    int idRegion = bytes[pointer+2];
    if(idRegion > 0)
      p.region = Environment.instance.collection.getRegion(idRegion);

    int idForme  = bytes[pointer+3];
    if(idForme > 0)
      p.forme = Environment.instance.collection.getForme(idForme);

    pointer += byteLength;
    return p;
  }

  List<int> toByte() {
    int id=0;
    if (name.isPokemon()) {
      id = Environment.instance.collection.rPokemon[name];
    } else {
      id = Environment.instance.collection.rOther[name];
    }
    return <int>
    [
      id & 0xFF00,
      id & 0xFF,
      region != null ? Environment.instance.collection.rRegions[region] : 0,
      forme  != null ? Environment.instance.collection.rFormes[forme]   : 0,
    ];
  }
}

class Illustrator {
  String name;

  Illustrator(this.name);
}

/// Full card definition except Number/Extension/Rarity
class PokemonCard {
  List<Pokemon> pokemons;
  Level         level;
  Type          type;
  Type?         typeExtended; //Double energy can exists but less than 20 card !
  Illustrator?  illustrator;

  PokemonCard(this.pokemons, this.level, this.type);

  Future<void> saveDatabase(connection, int id, [bool creation=false]) async {
    List<int> nameBytes = [];
    pokemons.forEach((element) { nameBytes += element.toByte(); });

    int? idIllustrator = illustrator != null ? Environment.instance.collection.rIllustrator[illustrator] : null;

    List data = [Int8List.fromList(nameBytes), level.index, type.index, null, null, null, null, null, null, idIllustrator, null];
    var query = "";
    if (creation) {
      data.insert(0, id);
      query = 'INSERT INTO `Cartes` VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);';
    } else {
      query = 'UPDATE `Cartes` SET `nom` = ?, `niveau` = ?, `type` = ?, `vie` = ?, `marqueur` = ?, `effets` = ?, `retrait` = ?, `faiblesse` = ?, `resistance` = ?, `idIllustrateur` = ?, `image` = ?'
      ' WHERE `Cartes`.`idCartes` = ${id}';
    }

    await connection.queryMulti(query, [data]);
  }
}

class PokemonCardExtension {
  PokemonCard  card;
  Rarity       rarity;

  PokemonCardExtension(this.card, this.rarity);

  static const int byteSize = 3;
  PokemonCardExtension.fromByte(pointer, bytes) :
    card = Environment.instance.collection.getCard(bytes[pointer] << 8 | bytes[pointer+1]),
    rarity = Rarity.values[bytes[pointer+2]]
  {
    pointer+=3;
  }

  List<int> toByte() {
    int idCard = Environment.instance.collection.rCard[card];
    return <int>[
      idCard & 0xFF00,
      idCard & 0xFF,
      rarity.index
    ];
  }
}

class SubExtensionCards {
  List<List<PokemonCardExtension>> cards;
  List<CodeNaming>                 codeNaming = [];

  SubExtensionCards(this.cards);

  SubExtensionCards.build(byteCard, naming) : this.cards=[] {
    // Extract card
    int pointer = 0;
    while(pointer < byteCard.length) {
      List<PokemonCardExtension> numberedCard = [];
      for( int cardId=0; cardId < byteCard[pointer]; cardId +=1) {
        numberedCard.add(PokemonCardExtension.fromByte(pointer+1, byteCard));
      }
      cards.add(numberedCard);
    }
    // Extract code naming
    if(naming != null) {
      naming.toString().split("|").forEach((element) {
        if(element.isNotEmpty) {
          var item = element.split(":");
          assert(item.length == 2);
          codeNaming.add(CodeNaming(int.parse(item[0]), item[1]));
        }
      });
    }
  }

  List<int> toByte() {
    List<int> cardBytes = [];
    cards.forEach((cardById) {
      // Add nb cards by number
      cardBytes.add(cardById.length);
      // Add card code
      cardById.forEach((card) {
        cardBytes += card.toByte();
      });
    });
    return cardBytes;
  }

  Future<void> saveDatabase(connection, int id) async {
    var query = 'UPDATE `CartesExtension` SET `cartes` = ?'
        ' WHERE `CartesExtension`.`idCartesExtension` = $id';
    await connection.query(query, [Int8List.fromList(toByte())]);
  }
}