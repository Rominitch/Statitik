import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/multi_language_string.dart';

import 'bytes_coder.dart';

class CardSet {
  static const int setMaskUnknown                  = 0;
  static const int setMaskSystem                   = 1;
  static const int setMaskParallel                 = 2;
  static const int setMaskReplaceRevertIntoBooster = 4;

  final MultiLanguageString names;
  final Color               color;
  final String              image;
  final bool                isSystem;
  final bool                isParallel;
  final bool                replaceRevertIntoBooster;

  const CardSet(this.names, this.color, this.image, this.isSystem, this.isParallel, this.replaceRevertIntoBooster);

  CardSet.fromBytes(ByteParser parser):
    names     = parser.extractMultiLanguage()!,
    color     = parser.extractColor(),
    image     = parser.extractString16(),
    isSystem  = parser.extractBool(),
    isParallel= parser.extractBool(),
    replaceRevertIntoBooster = parser.extractBool();

  List<int> toBytes() {
    return ByteEncoder.encodeMultiLanguage(names) + ByteEncoder.encodeColor(color)
        + ByteEncoder.encodeString16(image.codeUnits) + ByteEncoder.encodeBool(isSystem)
        + ByteEncoder.encodeBool(isParallel) + ByteEncoder.encodeBool(replaceRevertIntoBooster);
  }

  Widget imageWidget({double? width, double? height}){
    try {
      var imageAsset = AssetImage('assets/carte/$image.png');
      return Image(image: imageAsset, width: width, height: height);
    }
    catch(e)
    {
      return const Icon(Icons.help_outline);
    }
  }

}