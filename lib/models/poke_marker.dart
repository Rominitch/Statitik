import 'dart:io';

import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeMarker
{
  final PokeIdentifier _id;
  final Color          _color;
  final bool           _toTitle;
  final bool           _isByLanguage; //Otherwise is unique
  final String         _codeName;

  const PokeMarker.fromDB(this._id, this._color, this._toTitle, this._isByLanguage, this._codeName);

  PokeMarker.fromBytes(BinaryReader reader):
    _id = PokeIdentifier.fromBytes(reader),
    _color = reader.readColor(),
    _toTitle = reader.readBool(),
    _isByLanguage = reader.readBool(),
    _codeName = reader.readSmallString();

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
    writer.writeColor(_color);
    writer.writeBool(_toTitle);
    writer.writeBool(_isByLanguage);
    writer.writeSmallString(_codeName);
  }

  bool toTitle() { return _toTitle; }

  bool isByLanguage() {
    return _isByLanguage;
  }

  void toBytesId(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  bool isEqual(PokeIdentifier pid) {
    return _id == pid;
  }

  static List<String> mainFolderPath() {
    return ["images", "markers"];
  }

  String titleName() {
    return _codeName;
  }

  String imagePath(PokeLanguage l) {
    return _isByLanguage ? "${_id.id()}_${l.code()}" : _id.id().toString();
  }

  Widget icon(PokeLanguage l, {height}) {
    //var val = _image;
    //return drawCachedImage('logo', val, height: height,
    //    alternativeRendering: Text(val, style: TextStyle(fontSize: val.length > 9 ? 7
    //        : (val.length > 6 ? 9 : 12) )));

    final String path = Environment.instance.storage.imageLocalPath(mainFolderPath(), imagePath(l), "webp");
    return Image.file(File(path), height: height);
  }

  Widget? pokeMarker(PokeLanguage l, {double? height=15.0}) {
    return icon(l, height: height);
  }
}

class PokeMarkers
{
  final List<PokeMarker> _markers;

  const PokeMarkers(this._markers);

  PokeMarkers.fromBytes(BinaryReader reader, PokeCollection collection) :
    _markers = reader.readSmallList((reader) => collection.marker(PokeIdentifier.fromBytes(reader))!);

  PokeMarkers.fromBytesOld(List<int> bytes, PokeCollection collection) :
    _markers = _extractOld(bytes,  collection);

  List<PokeMarker> markers() { return _markers; }

  void add(PokeMarker value) {
    _markers.add(value);
  }

  void remove(PokeMarker value) {
    _markers.remove(value);
  }

  bool contains(PokeMarker value) {
    return _markers.contains(value);
  }

  static List<PokeMarker> _extractOld(List<int> bytes, PokeCollection collection) {
    List<PokeMarker> markers = [];
    final List<int> fullcode = <int>[
      bytes[0],
      ((bytes[1] << 8 | bytes[2]) << 8 | bytes[3]) << 8 | bytes[4]
    ];
    int nextId = 33;
    int id = 1;
    for (var code in fullcode.reversed) {
      while(code > 0)
      {
        if((code & 0x1) == 0x1) {
          try {
            markers.add(collection.markers()[id-1]);
          } catch(e) {
            printOutput("Error Marker: $id");
          }
        }
        id = id+1;
        code = code >> 1;
      }
      id = nextId;
      nextId += 32;
    }
    return markers;
  }

  void toBytes(BinaryWriter writer) {
    writer.writeSmallList(_markers, (writer, marker) => marker.toBytesId(writer) );
  }
}