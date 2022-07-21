import 'package:flutter/material.dart';

import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

class CardMarker
{
  final MultiLanguageString name;
  final Color               color;
  final bool                toTitle;

  const CardMarker(this.name, this.color, this.toTitle);

  Widget icon(Language l, {height}) {
    var val = name.name(l);
    return drawCachedImage('logo', val, height: height,
        alternativeRendering: Text(val, style: TextStyle(fontSize: val.length > 9 ? 7
            : (val.length > 6 ? 9 : 12) )));
  }
}

class CardMarkers {
  List<CardMarker> markers = [];

  CardMarkers();
  CardMarkers.from(List<CardMarker> currentMarkers) :
    markers = currentMarkers;

  static const int byteLength=5;
  CardMarkers.fromBytes(List<int> bytes, Map allMarkers) {
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
            markers.add(allMarkers[id]);
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
  }

  List<int> toBytes(Map rMarkers) {
    List<int> codeMarkers = [0, 0];
    for (var element in markers) {
      int id = rMarkers[element];
      if(id < 33) {
        codeMarkers[1] |= (1<<(id-1));
      } else {
        var multiple = id-33;
        codeMarkers[0] |= (1<<(multiple));
      }
    }
    return <int>[
      codeMarkers[0] & 0xFF,
    ]+ByteEncoder.encodeInt32(codeMarkers[1]);
  }

  void add(value) {
    markers.add(value);
  }

  void remove(value) {
    markers.remove(value);
  }

  bool contains(value) {
    return markers.contains(value);
  }
}

Widget pokeMarker(Language l, CardMarker marker, {double? height=15.0, bool generate=false}) {
  if( generate || Environment.instance.collection.cachedMarkers[marker] == null ) {
    Environment.instance.collection.cachedMarkers[marker] = marker.icon(l, height: height);
  }
  return Environment.instance.collection.cachedMarkers[marker]!;
}