import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/MultiLanguageString.dart';

enum CardSetConfiguration {
  Unknown,
  System,
  Parallel,
}

class CardSet {
  final MultiLanguageString names;
  final Color               color;
  final String              image;
  final bool                isSystem;
  final bool                isParallel;

  const CardSet(this.names, this.color, this.image, this.isSystem, this.isParallel);

  Widget imageWidget({double? width, double? height}){
    return Image(image: AssetImage('assets/carte/$image.png'), width: width, height: height);
  }

}