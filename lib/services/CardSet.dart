import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/MultiLanguageString.dart';

class CardSet {
  static const int SetMaskUnknown                  = 0;
  static const int SetMaskSystem                   = 1;
  static const int SetMaskParallel                 = 2;
  static const int SetMaskReplaceRevertIntoBooster = 4;

  final MultiLanguageString names;
  final Color               color;
  final String              image;
  final bool                isSystem;
  final bool                isParallel;
  final bool                replaceRevertIntoBooster;

  const CardSet(this.names, this.color, this.image, this.isSystem, this.isParallel, this.replaceRevertIntoBooster);

  Widget imageWidget({double? width, double? height}){
    return Image(image: AssetImage('assets/carte/$image.png'), width: width, height: height);
  }

}