
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/models/database/poke_db_cards_blob.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_expansion_cards.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

enum ExpansionType {
  Normal,
  Promo,
  Deck
}

class PokeExpansion {
  final PokeIdentifier    _id;
  final int               _nbCardsPerBooster;
  final DateTime          _released;
  final String            _icon;
  final List<String>      _codes;
  final ExpansionType     _type;

  // Card info
  final PokeExpansionCards  cards;
  //final StatsExtension      stats = StatsExtension();

  const PokeExpansion.fromDB(this._id, this._released, this._icon, this._nbCardsPerBooster, this._type, this._codes, this.cards );

  PokeIdentifier pid() { return _id; }

  DateTime released() { return _released; }

  PokeExpansion.fromBytes(BinaryReader reader, PokeCollection collection):
    _id                = PokeIdentifier.fromBytes(reader),
    _nbCardsPerBooster = reader.readUint8(),
    _released = reader.readDateTime(),
    _icon     = reader.readString(),
    _codes    = reader.readList( (reader) => reader.readString() ),
    _type     = ExpansionType.values[reader.readUint8()],
    cards     = PokeExpansionCards.fromBytes(reader.readUint8(), reader, collection);

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
    writer.writeUint8(_nbCardsPerBooster);
    writer.writeDateTime(_released);
    writer.writeString(_icon);
    writer.writeList<String>( _codes, (w, item) => w.writeString(item) );
    writer.writeUint8(_type.index);
    writer.writeUint8(PokeDbCardsBlob.version); // Version of cards
    cards.toBytes(writer);
  }

  CardLocation location() {
    return _id.type() == PokeIdentifierType.expansion_jp ? CardLocation.Asie : CardLocation.Monde;
  }

  String? label(PokeLangage language) {
    return language.label(_id);
  }

  bool isSameSerie(PokeIdentifier id) {
    return _id.serie() == id.serie();
  }

  ExpansionType type() { return _type;}

  /// Show Extension image
  Widget image(PokeLangage l, {double? wSize, double? hSize}) {
    return drawCachedImage('extensions', _icon.replaceAll("<L>", l.code()), width: wSize, height: hSize);
  }

  /// Get formated release date of product
  String outDate() {
    return DateFormat('yyyyMMdd').format(_released);
  }
}