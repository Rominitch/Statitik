
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_form.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_region.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class CardTitle
{
  final PokeIdentifier _id;

  const CardTitle(this._id);

  CardTitle.fromBytes(BinaryReader reader):
    _id = PokeIdentifier.fromBytes(reader);

  void toBytesID(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  String? fullname(PokeLanguage l) {
    return l.label(_id);
  }

  String? name(PokeLanguage l) {
    return l.label(_id);
  }

  bool isPokemon() {
    return false;
  }

  bool isEqual(PokeIdentifier pid) {
    return _id == pid;
  }

  PokeIdentifier pid() {
    return _id;
  }
}

class PokemonName extends CardTitle
{
  PokemonName.fromDB(super._id) {
    assert(_id.type() == PokeIdentifierType.pokemon, "Error with id= ${_id.id()} -> ${_id.type()}");
  }

  PokemonName.fromBytes(super.reader) : super.fromBytes();

  int idPokedex() {
    return _id.number();
  }

  int generation() {
    return _id.serie();
  }

  @override
  String? fullname(PokeLanguage l) {
    return "${name(l)} - n°${idPokedex()}";
  }

  @override
  bool isPokemon() {
    return true;
  }
}

enum CardType
{
  object(1),
  trainer(2),
  tools(3),
  stadium(4),
  energy(5);

  const CardType(this.value);
  final num value;
}

class OtherCardName extends CardTitle
{
  OtherCardName.fromDB(super._id) {
    assert(_id.type() == PokeIdentifierType.object);
  }

  OtherCardName.fromBytes(super.reader) : super.fromBytes();

  CardType type() {
    return CardType.values[_id.subCode()];
  }
}

class PokeFullCardPokemon {
  CardTitle   name;
  PokeRegion? region;
  PokeForm?   form;

  PokeFullCardPokemon(this.name, {this.region, this.form});

  PokeFullCardPokemon.fromBytesOld(BinaryReader reader, PokeCollection collection):
    name   = collection.cardTitleOld( reader.tmpReadInt16BIG() )!,
    region = collection.regionOld(reader.readInt8()),
    form   = collection.formOld(reader.readInt8());

  PokeFullCardPokemon.fromBytes(BinaryReader reader, PokeCollection collection):
    name   = collection.cardTitle( PokeIdentifier.fromBytes(reader))!,
    region = reader.readOptional((r) => collection.region(PokeIdentifier.fromBytes(r))),
    form   = reader.readOptional((r) => collection.form( PokeIdentifier.fromBytes(r)));

  void toBytes(BinaryWriter writer) {
    name.toBytesID(writer);
    writer.writeOptional(region, (w) => region!.toBytesID(w));
    writer.writeOptional(form,   (w) => form!.toBytesID(w));
  }

  String titleOfCard(PokeLanguage l) {
    String title = name.name(l)!;
    if(form != null) {
      title = sprintf(l.label(form!)!, [title]);
    }
    if(region != null) {
      title = sprintf(l.label(region!)!, [title]);
    }
    return title;
  }
}

class PokeTitleCard {
  List<PokeFullCardPokemon> title;

  PokeTitleCard.empty() : title = [];

  PokeTitleCard.fromBytesOld(BinaryReader reader, PokeCollection collection) : title = []
  {
    while (reader.canParse()) {
      title.add(PokeFullCardPokemon.fromBytesOld(reader, collection));
    }
  }

  PokeTitleCard.fromBytes(BinaryReader reader, PokeCollection collection):
    title = reader.readSmallList((reader) => PokeFullCardPokemon.fromBytes(reader, collection));

  void toBytes(BinaryWriter writer) {
    writer.writeSmallList(title, (writer, item) => item.toBytes(writer));
  }
}
