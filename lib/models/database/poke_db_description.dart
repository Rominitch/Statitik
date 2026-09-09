
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/tools/binary_manager.dart';

enum DescriptionEffect {
  unknown(0),          // 0
  attack(1),           // 1
  draw(2),             // 2
  flipCoin(4),         // 4
  poison(8),           // 8
  burn(16),            // 16
  sleep(32),           // 32
  paralyzed(64),       // 64
  search(128),         // 128
  heal(256),           // 256
  mix(512),            // 512
  confusion(1024);     // 1024

  const DescriptionEffect(this.value);
  final int value;

  static List<DescriptionEffect> convertMarkers(int? marks) {
    if(marks == null) {
      return const [];
    }
    List<DescriptionEffect> markers = [];
    int id = 1;
    while(marks! > 0)
    {
      if((marks & 0x1) == 0x1) {
        markers.add(DescriptionEffect.values[id]);
      }
      id = id+1;
      marks = marks >> 1;
    }
    return markers;
  }
  static int convert(List<DescriptionEffect> effects) {
    int code = 0;
    for( final e in effects ) {
      code += e.value;
    }
    return code;
  }
}

class PokeDbDescription {
  final PokeIdentifier          _id;
  final List<DescriptionEffect> _markers;

  const PokeDbDescription.fromDB(this._id, this._markers);

  PokeDbDescription.fromBytes(BinaryReader reader):
    _id      = PokeIdentifier.fromBytes(reader),
    _markers = DescriptionEffect.convertMarkers(reader.readInt32());

  void toBytesID(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
    writer.writeInt32(DescriptionEffect.convert(_markers));
  }

  PokeIdentifier pid() {
    return _id;
  }

  String? name(PokeLanguage l) {
    return l.label(_id);
  }

  bool search(PokeLanguage l, String searchPart) {
    return l.search(_id, searchPart);
  }
}