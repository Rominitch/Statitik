import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeMarker
{
  final PokeIdentifier _id;
  final String         _image;
  final Color          _color;
  final bool           _toTitle;

  // Computed
  Widget? widget;

  PokeMarker.fromDB(this._id, this._image, this._color, this._toTitle);

  PokeMarker.fromBytes(BinaryReader reader):
    _id = PokeIdentifier.fromBytes(reader),
    _image = reader.readString(),
    _color = reader.readColor(),
    _toTitle = reader.readBool();

  void toBytes(BinaryWriter writer) {
    _id.toBytesID(writer);
    writer.writeString(_image);
    writer.writeColor(_color);
    writer.writeBool(_toTitle);
  }

  bool toTitle() { return _toTitle; }

  void toBytesId(BinaryWriter writer) {
    _id.toBytesID(writer);
  }

  bool isEqual(PokeIdentifier pid) {
    return _id == pid;
  }

  String titleName() {
    return _image.toUpperCase().replaceAll("_SV", "");
  }

  Widget icon(PokeLanguage l, {height}) {
    var val = _image;
    return drawCachedImage('logo', val, height: height,
        alternativeRendering: Text(val, style: TextStyle(fontSize: val.length > 9 ? 7
            : (val.length > 6 ? 9 : 12) )));
  }

  Widget? pokeMarker(PokeLanguage l, PokeMarker marker, {double? height=15.0, bool generate=false}) {
    if( _toTitle ) {
      if (generate || widget == null) {
        widget = marker.icon(l, height: height);
      }
      return widget!;
    }
    return null;
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