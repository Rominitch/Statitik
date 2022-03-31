import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';

enum Design {
  Basic,
  ImageShining,
  TextShining,
  ArcEnCiel,
  Gold,
}
enum ShiningPattern {
  None,
  Horizontal,
  Vertical,
  Dot,
}

Widget iconDesign(Design design) {
  switch(design) {
    case Design.Basic:
      return Icon(Icons.crop_square);
    case Design.ImageShining:
      return Icon(Icons.image);
    case Design.TextShining:
      return Icon(Icons.article);
    case Design.ArcEnCiel:
      return Icon(Icons.looks);
    case Design.Gold:
      return Icon(Icons.stars_rounded, color: Colors.yellow.shade700);
    default:
      return Icon(Icons.help_outline);
  }
}

class CardDesign {
  Design         design;
  ShiningPattern pattern;

  CardDesign([this.design = Design.Basic, this.pattern = ShiningPattern.None]);

  CardDesign.fromBytes(ByteParser parser):
    this.design  = Design.values[parser.extractInt8()],
    this.pattern = ShiningPattern.values[parser.extractInt8()] ;

  List<int> toBytes() {
    return  ByteEncoder.encodeInt8(design.index) +
            ByteEncoder.encodeInt8(pattern.index);
  }

  Widget icon() {
    return Row(
      children: [
        iconDesign(design)
      ]
    );
  }
}