
import 'package:statitikcard/tools/binary_manager.dart';

enum PokeIdentifierType
{
  serie(0),
  expansion_jp(10),
  expansion_w(11),
  cards_jp(20),
  cards_w(21),
  pokemon(3),
  object(4),
  info(5),
  product(6),
  description(7),
  effect(8),
  region(9);

  const PokeIdentifierType(this.value);
  final num value;
}

class PokeIdentifier {
  final int _id;

  const PokeIdentifier(this._id);

  PokeIdentifier.fromBytes(BinaryReader reader):
    _id = reader.readInt32();

  PokeIdentifier.region(int number, bool name) :
    _id = PokeIdentifierType.region.index * 100000000 + (name ? 10000000 : 20000000) + number;

  void toBytesID(BinaryWriter writer) {
    writer.writeInt32(_id);
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