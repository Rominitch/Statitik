
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/tools/binary_manager.dart';

enum PokeIdentifierType
{
  serie(0),
  expansion_jp(10),
  expansion_w(11),
  cards_jp(20),
  cards_w(21),
  booster_jp(30),
  booster_w(31),
  pokemon(3),
  object(4),
  info(5),
  product(62),
  sideProduct(63),
  booster(64),
  description(7),
  effect(8),
  region(9);

  const PokeIdentifierType(this.value);
  final int value;
}

class PokeIdentifier {
  final int _id;

  const PokeIdentifier(this._id);

  PokeIdentifier.fromBytes(BinaryReader reader):
    _id = reader.readUint32();

  PokeIdentifier.region(int number, bool name) :
    _id = PokeIdentifierType.region.value * 100000000 + (name ? 10000000 : 20000000) + number;

  PokeIdentifier.create(PokeIdentifierType type, int number) :
    _id = (type == PokeIdentifierType.product
        || type == PokeIdentifierType.sideProduct) ? type.value *  10000000 + number
        :                                            type.value * 100000000 + number;

  PokeIdentifier.boosterFrom(PokeIdentifier expID) :
        _id = expID._id + 2000000000;

  PokeIdentifier.expensionFrom(PokeIdentifier boosterID) :
        _id = boosterID._id - 2000000000;


  CardLocation location() {
    switch( _codeLocation()) {
      case 0: { return CardLocation.Asie;}
      case 1: { return CardLocation.Monde;}
      default: throw "No location";
    }
  }

  void toBytesID(BinaryWriter writer) {
    writer.writeUint32(_id);
  }

  bool isEqual(PokeIdentifier pid) {
    return this == pid;
  }

  @override
  bool operator ==(Object other) {
    return (other is PokeIdentifier) && other._id == _id;
  }

  int id() {
    return _id;
  }

  int _codeLocation() {
    return (_id ~/ 100000000) % 10;
  }

  int serie() {
    return (_id ~/ 1000000) % 100;
  }
  int expansion() {
    return (_id ~/ 1000) % 1000;
  }
  PokeIdentifierType type() {
    final code = (_id ~/ 100000000) % 100;
    for( final e in PokeIdentifierType.values) {
      if( e.value == code ) { return e; }
    }
    throw Exception("bad type");
  }
  int number() {
    return _id % 10000;
  }
  int subCode() {
    return (_id ~/ 100000000) % 10;
  }

  @override
  int get hashCode => _id;
}