import 'package:flutter/widgets.dart';

import 'package:sprintf/sprintf.dart';

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

  static Pokemon fromBytes(ByteParser parser, collection) {
    int idName = parser.byteArray[parser.pointer] << 8 | parser.byteArray[parser.pointer+1];
    assert(idName != 0);

    Pokemon p = Pokemon(idName < 10000
              ? collection.getPokemonID(idName)
              : collection.getNamedID(idName));
    int idRegion = parser.byteArray[parser.pointer+2];
    if(idRegion > 0)
      p.region = collection.regions[idRegion];

    int idForme  = parser.byteArray[parser.pointer+3];
    if(idForme > 0)
      p.forme = collection.formes[idForme];

    parser.pointer += byteLength;
    return p;
  }

  List<int> toBytes(collection) {
    int id=0;
    if (name.isPokemon()) {
      id = collection.rPokemon[name];
    } else {
      id = collection.rOther[name];
    }
    assert(id != 0);

    var bytes = <int>
    [
      (id & 0xFF00) >> 8,
      id & 0xFF,
      region != null ? collection.rRegions[region] : 0,
      forme  != null ? collection.rFormes[forme]   : 0,
    ];
    assert((bytes[0] | bytes[1]) != 0);
    assert(bytes[0] <= 0xFF && bytes[1] <= 0xFF);
    return bytes;
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

  CardMarkers();

  CardMarkers.from(List<CardMarker> markers) : this.markers = markers;

  static const int byteLength=5;
  CardMarkers.fromBytes(List<int> bytes) {
    var fullcode = <int>[
      bytes[0],
      ((bytes[1] << 8 | bytes[2]) << 8 | bytes[3]) << 8 | bytes[4]
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
  }

  List<int> toBytes() {
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
      (codeMarkers[1] & 0xFF000000) >> 24,
      (codeMarkers[1] & 0xFF0000) >> 16,
      (codeMarkers[1] & 0xFF00) >> 8,
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
  PokemonCardExtension.fromBytes(ByteParser parser, Map collection) :
    data   = collection[parser.byteArray[parser.pointer] << 8 | parser.byteArray[parser.pointer+1]],
    rarity = Rarity.values[parser.byteArray[parser.pointer+2]]
  {
    parser.pointer+=byteSize;
  }

  List<int> toBytes(Map rCollection) {
    assert(rCollection.isNotEmpty); // Admin condition

    int idCard = rCollection[data];
    assert(idCard != 0);

    return <int>[
      (idCard & 0xFF00) >> 8,
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

  SubExtensionCards.build(ByteParser parser, List<CodeNaming> naming, cardCollection) : this.cards=[], this.isValid = (parser.byteArray.length > 0) {
    // Extract card
    while(parser.pointer < parser.byteArray.length) {
      List<PokemonCardExtension> numberedCard = [];
      int nbTitle = parser.byteArray[parser.pointer];
      for( int cardId=0; cardId < nbTitle; cardId +=1) {
        parser.pointer += 1;
        numberedCard.add(PokemonCardExtension.fromBytes(parser, cardCollection));
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

  List<int> toBytes(Map collectionCards) {
    List<int> cardBytes = [];
    cards.forEach((cardById) {
      // Add nb cards by number
      cardBytes.add(cardById.length);
      // Add card code
      cardById.forEach((card) {
        cardBytes += card.toBytes(collectionCards);
      });
    });
    return cardBytes;
  }
}