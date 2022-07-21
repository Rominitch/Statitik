import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/marker.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/type_card.dart';

/// Pokemon region
class Region {
  final MultiLanguageString _fullName;
  final MultiLanguageString _applyPokemonName;

  const Region(this._fullName, this._applyPokemonName);

  String name(Language l) {
    return _fullName.name(l);
  }

  String applyToPokemonName(Language l) {
    return _applyPokemonName.name(l);
  }
}

/// Special name to give (flying pikachu, ...)
class Forme
{
  final MultiLanguageString _applyPokemonName;

  const Forme(this._applyPokemonName);

  String applyToPokemonName(Language l) {
    return _applyPokemonName.name(l);
  }
}

/// Full pokemon definition
class Pokemon {
  CardTitleData   name;
  Region?     region;
  Forme?      forme;

  Pokemon(this.name, {this.region, this.forme});

  static Pokemon fromBytes(ByteParser parser, collection) {
    int idName = parser.extractInt16();
    assert(idName != 0);

    Pokemon p = Pokemon(idName < 10000
              ? collection.getPokemonID(idName)
              : collection.getNamedID(idName));
    int idRegion = parser.extractInt8();
    if(idRegion > 0) {
      p.region = collection.regions[idRegion];
    }

    int idForme  = parser.extractInt8();
    if(idForme > 0) {
      p.forme = collection.formes[idForme];
    }
    return p;
  }

  List<int> toBytes(collection) {
    int id=0;
    if (name.isPokemon()) {
      assert(collection.rPokemon.containsKey(name), name.defaultName());
      id = collection.rPokemon[name];
    } else {
      assert(collection.rOther.containsKey(name), name.defaultName());
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
      title = sprintf(forme!._applyPokemonName.name(l), [title]);
    }
    if(region != null) {
      title = sprintf(region!._applyPokemonName.name(l), [title]);
    }
    return title;
  }
}

class Illustrator {
  final String name;

  const Illustrator(this.name);
}

class EnergyValue {
  TypeCard energy;
  int  value;

  EnergyValue(this.energy, this.value);

  EnergyValue.fromBytes(bytes) :
    energy = TypeCard.values[bytes[0]],
    value = (bytes[1] << 8) | bytes[2];

  List<int> toBytes() {
    return <int>[
      energy.index,
      (value & 0xFF00) >> 8,
      value & 0xFF
    ];
  }
}

enum AlternativeDesign {
  basic,
  holographicHorizontalLine,
  holographicVerticalLine,
  holographicStarDot,
}

/// Full card definition except Number/Extension/Rarity
class PokemonCardData {
  List<Pokemon>    title;
  Level            level;
  TypeCard         type;
  TypeCard?        typeExtended; //Double energy can exists but less than 20 card !
  Illustrator?     illustrator;
  CardMarkers      markers;
  CardEffects      cardEffects = CardEffects();
  int              life;
  int              retreat;
  EnergyValue?     resistance;
  EnergyValue?     weakness;

  PokemonCardData(this.title, this.level, this.type, this.markers, [this.life=0, this.retreat=0, this.resistance, this.weakness]) {
    if( retreat > 5) {
      retreat = 0;
    }
  }

  String titleOfCard(Language l) {
    List<String> name = [];
    for (var pokemon in title) {
      name.add(pokemon.titleOfCard(l));
    }
    return name.join("&");
  }

  PokemonCardData.empty() : title=[], level=Level.base, type=TypeCard.unknown, markers=CardMarkers(), life=0, retreat=0;

  bool missingMainData() {
    return isPokemonType(type) && life == 0;
  }
}