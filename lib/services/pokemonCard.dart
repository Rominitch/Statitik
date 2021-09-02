
import 'dart:typed_data';

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
    int idName = bytes[pointer] << 8 + bytes[pointer+1];
    Pokemon p = Pokemon(Environment.instance.collection.getNamedID(idName));
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
      var rPokemon = Environment.instance.collection.pokemons.map((k, v) => MapEntry(v, k));
      id = rPokemon[name];
    } else {
      var rOther = Environment.instance.collection.otherNames.map((k, v) => MapEntry(v, k));
      id = rOther[name];
    }
    var rRegion = Environment.instance.collection.regions.map((k, v) => MapEntry(v, k));
    var rFormes = Environment.instance.collection.formes.map((k, v) => MapEntry(v, k));

    return <int>
    [
      id & 0xFF00,
      id & 0xFF,
      region != null ? rRegion[region] : 0,
      forme  != null ? rFormes[forme]  : 0,
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

  void saveDatabase(connection, int id, [bool creation=false]) async {
    List<int> nameBytes = [];
    pokemons.forEach((element) { nameBytes += element.toByte(); });

    var rIllustrator = Environment.instance.collection.regions.map((k, v) => MapEntry(v, k));
    int? idIllustrator = illustrator != null ? rIllustrator[illustrator] : null;

    List data = [Int8List.fromList(nameBytes), level.index, type, null, null, null, null, null, null, idIllustrator, null];
    var query = "";
    if (creation) {
      data.insert(0, id);
      query = 'INSERT INTO `Cartes` VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, );';
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
}

class SubExtensionCards {
  List<List<PokemonCardExtension>> cards;

  SubExtensionCards(this.cards);
}