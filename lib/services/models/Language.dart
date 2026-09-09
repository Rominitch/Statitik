import 'package:flutter/material.dart';

import 'bytes_coder.dart';

class LanguageOld
{
  int id;
  String image;

  LanguageOld({required this.id, required this.image});

  AssetImage create()
  {
    return AssetImage('assets/langue/$image.png');
  }

  Image barIcon([double? newHeight]) {
    return Image(
      image: create(),
      height: newHeight ?? AppBar().preferredSize.height * 0.4,
    );
  }

  bool isWorld() {
    return id != 3;
  }

  bool isJapanese() {
    return id == 3;
  }

  LanguageOld.fromBytes(ByteParser parser):
    id    = parser.extractInt32(),
    image = parser.extractString16();

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(id)
         + ByteEncoder.encodeString16(image.codeUnits);
  }
}