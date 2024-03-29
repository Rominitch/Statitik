import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/MultiLanguageString.dart';

class CardSet {
  final MultiLanguageString names;
  final Color               color;
  final String              image;
  final bool                isStandard;

  const CardSet(this.names, this.color, this.image, [this.isStandard=true]);

  Widget imageWidget({double? width, double? height}){
    return Image(image: AssetImage('assets/carte/$image.png'), width: width, height: height);
  }

}