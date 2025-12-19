import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/collection.dart';

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
  final int _id;
  final MultiLanguageString _fullName;
  final MultiLanguageString _applyPokemonName;

  const Region(this._id, this._fullName, this._applyPokemonName);

  String name(Language l) {
    return _fullName.name(l);
  }

  String applyToPokemonName(Language l) {
    return _applyPokemonName.name(l);
  }

  Region.fromBytes(ByteParser parser):
    _id               = parser.extractInt32(),
    _fullName         = parser.extractMultiLanguage()!,
    _applyPokemonName = parser.extractMultiLanguage()!;

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(_id)
    + ByteEncoder.encodeMultiLanguage(_fullName)
    + ByteEncoder.encodeMultiLanguage(_applyPokemonName);
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

  Forme.fromBytes(ByteParser parser):
      _applyPokemonName = parser.extractMultiLanguage()!;

  List<int> toBytes() {
    return ByteEncoder.encodeMultiLanguage(_applyPokemonName);
  }
}

/// Full pokemon definition
class Pokemon {
  CardTitleData   name;
  Region?         region;
  Forme?          forme;

  Pokemon(this.name, {this.region, this.forme});

  static Pokemon fromBytes(ByteParser parser, collection) {
    // Extract all leave parser in good state if issue
    int idName   = parser.extractInt16();
    int idForme  = parser.extractInt8();
    int idRegion = parser.extractInt8();
    assert(idName != 0);

    Pokemon p = Pokemon(idName < 10000
          ? collection.getPokemonID(idName)
          : collection.getNamedID(idName));

    if(idRegion > 0) {
      p.region = collection.regions[idRegion];
    }

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
  final int id;
  final String name;

  const Illustrator(this.id, this.name);
  Illustrator.fromBytes(ByteParser parser):
    id = parser.extractInt32(),
    name = parser.extractString16();

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(id)
      + ByteEncoder.encodeString16(name.codeUnits);
  }
}

class EnergyValue {
  TypeCard energy;
  int  value;

  EnergyValue(this.energy, this.value);

  EnergyValue.fromBytesArray(List<int> bytes) :
    energy = TypeCard.values[bytes[0]],
    value = (bytes[1] << 8) | bytes[2];

  EnergyValue.fromBytes(ByteParser parser) :
    energy = TypeCard.values[parser.extractInt8()],
    value = parser.extractInt16();

  List<int> toBytes() {
    return ByteEncoder.encodeInt8(energy.index)
      + ByteEncoder.encodeInt16(value);
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

  PokemonCardData.fromBytes(ByteParser parser, Collection collection) :
    title        = parser.extractArray16<Pokemon>( (parser) => Pokemon.fromBytes(parser, collection) ),
    level        = Level.values[parser.extractInt8()],
    type         = TypeCard.values[parser.extractInt8()],
    typeExtended = parser.extractOptional((parser) => TypeCard.values[parser.extractInt8()]),
    illustrator  = parser.extractOptional((parser) => collection.illustrators[parser.extractInt32()]),
    markers      = CardMarkers.fromBytes(parser, collection.markers),
    cardEffects  = CardEffects.fromBytes(parser),
    life         = parser.extractInt16(),
    retreat      = parser.extractInt16(),
    resistance   = parser.extractOptional((parser) => EnergyValue.fromBytes(parser)),
    weakness     = parser.extractOptional((parser) => EnergyValue.fromBytes(parser));


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

  List<int> toBytes(Collection collection) {
    return ByteEncoder.encodeArray16<Pokemon>( title, (Pokemon p) => p.toBytes(collection) )
    + ByteEncoder.encodeInt8(level.index)
    + ByteEncoder.encodeInt8(type.index)
    + ByteEncoder.encodeOptional(typeExtended, () => ByteEncoder.encodeInt8(typeExtended!.index) )
    + ByteEncoder.encodeOptional(illustrator,  () => ByteEncoder.encodeInt32(illustrator!.id) )
    + markers.toBytes(collection.markers)
    + cardEffects.toBytes()
    + ByteEncoder.encodeInt16(life)
    + ByteEncoder.encodeInt16(retreat)
    + ByteEncoder.encodeOptional(resistance,  () => resistance!.toBytes())
    + ByteEncoder.encodeOptional(weakness,  () => weakness!.toBytes());
  }
}