
import 'package:statitikcard/models/poke_card_effect.dart';
import 'package:statitikcard/models/poke_card_energy_value.dart';
import 'package:statitikcard/models/poke_card_subject.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_illustrator.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/models/poke_level.dart';
import 'package:statitikcard/models/poke_marker.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeCard {
  final PokeIdentifier _id;
  PokeTitleCard title;
  PokeLevel level;
  TypeCard type;
  TypeCard? typeExtended; //Double energy can exists but less than 20 card !
  PokeMarkers markers;
  PokeCardEffects cardEffects = PokeCardEffects();
  int life;
  int retreat;
  PokeEnergyValue? resistance;
  PokeEnergyValue? weakness;
  PokeIllustrator? illustrator;

  PokeIdentifier pid() { return _id; }

  PokeCard.fromDB(this._id, this.title, this.level, this.type, this.typeExtended, this.markers, this.cardEffects,
      this.life, this.retreat, this.weakness, this.resistance);

  PokeCard.fromBytes(this._id, BinaryReader reader, PokeCollection collection) :
    title = PokeTitleCard.fromBytes(reader, collection),
    level = PokeLevel.values[reader.readInt8()],
    type = TypeCard.values[reader.readInt8()],
    typeExtended = reader.readOptional(() => TypeCard.values[reader.readInt8()]),
    illustrator  = reader.readOptional(() => collection.illustrator(PokeIdentifier.fromBytes(reader))),
    markers      = PokeMarkers.fromBytes(reader, collection),
    cardEffects  = PokeCardEffects.fromBytes(reader, collection),
    life         = reader.readInt16(),
    retreat      = reader.readInt16(),
    resistance   = reader.readOptional(() => PokeEnergyValue.fromBytes(reader)),
    weakness     = reader.readOptional(() => PokeEnergyValue.fromBytes(reader));


  bool isEqual(PokeIdentifier pid) {
    return _id == pid;
  }

  String titleOfCard(PokeLangage l) {
    List<String> name = [];
    for (var pokemon in title.title) {
      name.add(pokemon.titleOfCard(l));
    }
    return name.join("&");
  }

  PokeCard.empty()
      : _id=PokeIdentifier(0),
        title = PokeTitleCard.empty(),
        level=PokeLevel.base,
        type=TypeCard.unknown,
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
    writer.writeOptional( typeExtended, () => writer.writeInt8(typeExtended!.index));
    writer.writeOptional( illustrator, () => illustrator!.toBytesID(writer));
    markers.toBytes(writer);
    cardEffects.toBytes(writer);
    writer.writeInt16(life);
    writer.writeInt16(retreat);
    writer.writeOptional(resistance, () => resistance!.toBytes(writer));
    writer.writeOptional(weakness,   () => weakness!.toBytes(writer));
  }
}