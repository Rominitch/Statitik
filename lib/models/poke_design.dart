
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/tools/binary_manager.dart';

// WARNING: Never changed order
enum Design {
  mat,
  holographic,
  reverse,
  arcEnCiel,
  gold,
  goldBlack,
  shiny,
  full,
  k,
  unknown,
}

enum ShiningPattern {
  none,
  alternative,
  alternative2,
  alternative3,
  alternative4,
  alternative5,
  alternative6,
  alternative7,
}

enum ArtFormat {
  normal,
  halfArt,
  fullArt,
  unknown,
}

class PokeDesign {
  final PokeIdentifier _id;
  final String         _image;

  const PokeDesign.fromDB(this._id, this._image);

  PokeDesign.fromBytes(BinaryReader reader):
    _id = PokeIdentifier.fromBytes(reader),
    _image = reader.readString();

  void toBytesID(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
    writer.writeString(_image);
  }

  String? name(PokeLanguage l) {
    return l.label(_id);
  }

  bool isEqual(PokeIdentifier id) {
    return _id == id;
  }

  Design design() {
    return Design.values[_id.id() % 100];
  }

  String image() { return _image; }

  ShiningPattern shining() {
    return ShiningPattern.values[(_id.id() ~/10000) % 100];
  }

}