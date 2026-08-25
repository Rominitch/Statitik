import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeSet {
  static const int setMaskUnknown                  = 0;
  static const int setMaskSystem                   = 1;
  static const int setMaskParallel                 = 2;
  static const int setMaskReplaceRevertIntoBooster = 4;

  final PokeIdentifier      _id;
  final Color               _color;
  final String              _image;
  final int                 _configuration;

  const PokeSet.fromDB(this._id, this._color, this._image, this._configuration);

  PokeSet.fromBytes(BinaryReader reader):
    _id = PokeIdentifier.fromBytes(reader),
    _color = Color(reader.readInt32()),
    _image = reader.readString(),
    _configuration = reader.readInt16();

  PokeIdentifier      pid() { return _id; }

  void toBytesID(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
    writer.writeInt32(_color.toARGB32());
    writer.writeString(_image);
    writer.writeInt16(_configuration);
  }

  bool isEqual(PokeIdentifier id) {
    return id == _id;
  }

  bool isSystem()                 { return mask(_configuration, setMaskSystem); }
  bool isParallel()               { return mask(_configuration, setMaskParallel); }
  bool replaceRevertIntoBooster() { return mask(_configuration, setMaskReplaceRevertIntoBooster); }

  Widget imageWidget({double? width, double? height}){
    try {
      var imageAsset = AssetImage('assets/carte/$_image.png');
        return Image(image: imageAsset, width: width, height: height);
    }
    catch(e)
    {
      return const Icon(Icons.help_outline);
    }
  }

  @override
  bool operator ==(Object other) {
    return (other is PokeSet) && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  int compareTo(PokeSet other) {
    return other._id.id().compareTo(other._id.id());
  }
}