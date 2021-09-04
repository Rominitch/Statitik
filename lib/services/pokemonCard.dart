import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';
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

  static Pokemon loadBytes(ByteParser parser) {
    int idName = parser.byteArray[parser.pointer] << 8 | parser.byteArray[parser.pointer+1];
    assert(idName != 0);

    Pokemon p = Pokemon(idName < 10000
              ? Environment.instance.collection.getPokemonID(idName)
              : Environment.instance.collection.getNamedID(idName));
    int idRegion = parser.byteArray[parser.pointer+2];
    if(idRegion > 0)
      p.region = Environment.instance.collection.getRegion(idRegion);

    int idForme  = parser.byteArray[parser.pointer+3];
    if(idForme > 0)
      p.forme = Environment.instance.collection.getForme(idForme);

    parser.pointer += byteLength;
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

  String titleOfCard(Language l) {
    String title = name.name(l);
    if(forme != null) {
      title = sprintf(forme!._applyPokemonName[l.id-1], [title]);
    }
    if(region != null) {
      title = sprintf(region!._applyPokemonName[l.id-1], [title]);
    }
    return title;
  }
}

class Illustrator {
  String name;

  Illustrator(this.name);
}

class CardMarkers {
  List<CardMarker> markers = [];

  CardMarkers.from(markers) : this.markers = markers;

  static const int byteLength=5;
  CardMarkers.fromByte(ByteParser parser) {
    var fullcode = <int>[
      parser.byteArray[parser.pointer],
      ((parser.byteArray[parser.pointer+1] << 8 | parser.byteArray[parser.pointer+2]) << 8 | parser.byteArray[parser.pointer+3]) | parser.byteArray[parser.pointer+4]
    ];
    int id = 1;
    fullcode.reversed.forEach((code) {
      while(code > 0)
      {
        if((code & 0x1) == 0x1) {
          markers.add(CardMarker.values[id]);
        }
        id = id+1;
        code = code >> 1;
      }
    });

    parser.pointer += byteLength;
  }

  List<int> toByte() {
    List<int> codeMarkers = [0, 0];
    markers.forEach((element) {
      if(element != CardMarker.Nothing) {
        if(element.index < 32) {
          codeMarkers[1] |= (1<<(element.index-1));
        } else {
          codeMarkers[0] |= (1<<(element.index-32-1));
        }
      }
    });
    return <int>[
      codeMarkers[0] & 0xFF,
      codeMarkers[1] & 0xFF000000,
      codeMarkers[1] & 0xFF0000,
      codeMarkers[1] & 0xFF00,
      codeMarkers[1] & 0xFF,
    ];
  }
}

/// Full card definition except Number/Extension/Rarity
class PokemonCardData {
  List<Pokemon>    title;
  Level            level;
  Type             type;
  Type?            typeExtended; //Double energy can exists but less than 20 card !
  Illustrator?     illustrator;
  CardMarkers      markers;

  PokemonCardData(this.title, this.level, this.type, this.markers);

  Future<void> saveDatabase(connection, int id, [bool creation=false]) async {
    List<int> nameBytes = [];
    title.forEach((element) { nameBytes += element.toByte(); });

    int? idIllustrator = illustrator != null ? Environment.instance.collection.rIllustrator[illustrator] : null;

    List<int> typesByte = [type.index];
    if( typeExtended != null) {
      typesByte.add(typeExtended!.index);
    }

    List data = [Int8List.fromList(nameBytes), level.index, Int8List.fromList(typesByte), null, Int8List.fromList(markers.toByte()), null, null, null, null, idIllustrator, null];
    var query = "";
    if (creation) {
      data.insert(0, id);
      query = 'INSERT INTO `Cartes` VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);';
    } else {
      query = 'UPDATE `Cartes` SET `nom` = ?, `niveau` = ?, `type` = ?, `vie` = ?, `marqueur` = ?, `effets` = ?, `retrait` = ?, `faiblesse` = ?, `resistance` = ?, `idIllustrateur` = ?, `image` = ?'
      ' WHERE `Cartes`.`idCartes` = $id';
    }

    await connection.queryMulti(query, [data]);
  }

  String titleOfCard(Language l) {
    List<String> name = [];
    title.forEach((pokemon) {
      name.add(pokemon.titleOfCard(l));
    });
    return name.join("&");
  }
}

class PokemonCardExtension {
  PokemonCardData  data;
  Rarity           rarity;

  PokemonCardExtension(this.data, this.rarity);

  static const int byteSize = 3;
  PokemonCardExtension.fromByte(ByteParser parser) :
    data = Environment.instance.collection.getCard(parser.byteArray[parser.pointer] << 8 | parser.byteArray[parser.pointer+1]),
    rarity = Rarity.values[parser.byteArray[parser.pointer+2]]
  {
    parser.pointer+=3;
  }

  List<int> toByte() {
    int idCard = Environment.instance.collection.rCard[data];
    return <int>[
      idCard & 0xFF00,
      idCard & 0xFF,
      rarity.index
    ];
  }

  bool isValid() {
    return data.type!= Type.Unknown && rarity != Rarity.Unknown;
  }

  List<Widget> imageRarity() {
    return getImageRarity(rarity);
  }

  Widget imageType() {
    return getImageType(data.type);
  }

  bool hasAnotherRendering() {
    return !isValid() || rarity == Rarity.Commune || rarity == Rarity.PeuCommune || rarity == Rarity.Rare
        || rarity == Rarity.HoloRare;
  }

  Mode defaultMode() {
    return rarity == Rarity.HoloRare ? Mode.Halo : Mode.Normal;
  }

  bool isForReport() {
    return rarity.index >= Rarity.HoloRare.index;
  }

  Widget? showImportantMarker(BuildContext context, {double? height}) {
    var importantMarkers = [CardMarker.Escouade, CardMarker.EX, CardMarker.GX, CardMarker.V, CardMarker.VMAX];
    for(var m in importantMarkers) {
      if(data.markers.markers.contains(m)) {
        return pokeMarker(context, m, height: height);
      }
    }
    return null;
  }
}

class SubExtensionCards {
  List<List<PokemonCardExtension>> cards;
  List<CodeNaming>                 codeNaming = [];
  bool                             isValid;         ///< Data exists (Not waiting fill)

  SubExtensionCards(List<List<PokemonCardExtension>> cards, this.codeNaming) : this.cards = cards, this.isValid = cards.length > 0;

  SubExtensionCards.build(ByteParser parser, List<CodeNaming> naming) : this.cards=[], this.isValid = (parser.byteArray.length > 0) {
    // Extract card
    while(parser.pointer < parser.byteArray.length) {
      List<PokemonCardExtension> numberedCard = [];
      for( int cardId=0; cardId < parser.byteArray[parser.pointer]; cardId +=1) {
        parser.pointer += 1;
        numberedCard.add(PokemonCardExtension.fromByte(parser));
      }
      cards.add(numberedCard);
    }

  }

  String numberOfCard(int id) {
    CodeNaming cn = CodeNaming();
    if(codeNaming.isNotEmpty) {
      codeNaming.forEach((element) {
        if( id >= element.idStart)
          cn = element;
      });
    }
    return sprintf(cn.naming, [(id-cn.idStart + 1)]);// .toString();
  }

  String titleOfCard(Language l, int idCard, [int idAlternative=0]) {
    return idCard < cards.length
    ? cards[idCard][idAlternative].data.titleOfCard(l)
    : "";
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