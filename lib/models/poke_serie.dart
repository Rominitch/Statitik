
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeSerie {
  final PokeIdentifier  _id;

  // Computed Link
  Map<CardLocation, List<PokeExpansion>> _expansions;

  PokeSerie.fromDB(this._id) :
    _expansions = {};

  PokeSerie.fromBytes(BinaryReader reader):
    _id = PokeIdentifier.fromBytes(reader),
    _expansions = {};

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  String? label(PokeLanguage language) {
    return language.label(_id);
  }

  void addExpansion(PokeExpansion expansion) {
    if( !_expansions.containsKey(expansion.location()) ) {
      _expansions[expansion.location()] = [];
    }
    _expansions[expansion.location()]!.add(expansion);
  }

  PokeIdentifier id() { return _id; }

  List<PokeExpansion>? expansions(CardLocation location) {
    return _expansions[location];
  }
}