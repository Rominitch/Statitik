import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/multi_language_string.dart';

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