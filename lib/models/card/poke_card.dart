
import 'package:statitikcard/models/card/poke_card_effect.dart';
import 'package:statitikcard/models/card/poke_card_energy_value.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_illustrator.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_level.dart';
import 'package:statitikcard/models/poke_marker.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeCard {
  static const int minLife = 0;
  static const int maxLife = 400;

  static const int minAttackPower = 0;
  static const int maxAttackPower = 400;

  static const int minAttackEnergy = 0;
  static const int maxAttackEnergy = 5;

  static const int minRetreat = 0;
  static const int maxRetreat = 5;

  static const int minResistance = 0;
  static const int maxResistance = 60;

  static const int minWeakness = 0;
  static const int maxWeakness = 5;

  final PokeIdentifier _id;
  PokeTitleCard title;
  PokeLevel level;
  PokeCardType  type;
  PokeCardType? typeExtended; //Double energy can exists but less than 20 card !
  PokeMarkers markers;
  PokeCardEffects cardEffects = PokeCardEffects();
  int life;
  int retreat;
  PokeEnergyValue? resistance;
  PokeEnergyValue? weakness;
  PokeIllustrator? illustrator;

  PokeCard.newCard(this.type):
    _id   = PokeIdentifier(0),
    title = PokeTitleCard.empty(),
    level = PokeLevel.base,
    markers = PokeMarkers([]),
    life    = 0,
    retreat = 0;

  PokeIdentifier pid() { return _id; }

  PokeCard.fromDB(this._id, this.title, this.level, this.type, this.typeExtended, this.markers, this.cardEffects,
      this.life, this.retreat, this.weakness, this.resistance);

  PokeCard.fromBytes(this._id, BinaryReader reader, PokeCollection collection) :
    title = PokeTitleCard.fromBytes(reader, collection),
    level = PokeLevel.values[reader.readInt8()],
    type  = PokeCardType.values[reader.readInt8()],
    typeExtended = reader.readOptional((r) => PokeCardType.values[r.readInt8()]),
    illustrator  = reader.readOptional((r) => collection.illustrator(PokeIdentifier.fromBytes(r))),
    markers      = PokeMarkers.fromBytes(reader, collection),
    cardEffects  = PokeCardEffects.fromBytes(reader, collection),
    life         = reader.readInt16(),
    retreat      = reader.readInt16(),
    resistance   = reader.readOptional((r) => PokeEnergyValue.fromBytes(r)),
    weakness     = reader.readOptional((r) => PokeEnergyValue.fromBytes(r));


  bool isEqual(PokeIdentifier pid) {
    return _id == pid;
  }

  String titleOfCard(PokeLanguage l) {
    List<String> name = [];
    for (var pokemon in title.title) {
      name.add(pokemon.titleOfCard(l));
    }
    return name.join("&");
  }

  PokeCard.empty()
      : _id=PokeIdentifier(0),
        title = PokeTitleCard.empty(),
        level = PokeLevel.base,
        type  = PokeCardType.unknown,
        markers=PokeMarkers([]),
        life=0,
        retreat=0;

  bool missingMainData() {
    return isPokemonType(type) && life == 0;
  }

  void toBytesID(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  void toBytes(BinaryWriter writer) {
    title.toBytes(writer);
    writer.writeInt8(level.index);
    writer.writeInt8(type.index);
    writer.writeOptional( typeExtended, (w) => w.writeInt8(typeExtended!.index));
    writer.writeOptional( illustrator, (w) => illustrator!.toBytesID(w));
    markers.toBytes(writer);
    cardEffects.toBytes(writer);
    writer.writeInt16(life);
    writer.writeInt16(retreat);
    writer.writeOptional(resistance, (w) => resistance!.toBytes(w));
    writer.writeOptional(weakness,   (w) => weakness!.toBytes(w));
  }
}