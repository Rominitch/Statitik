import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';

enum Design {
  Basic,
  Holographic,
  Reverse,
  ArcEnCiel,
  Gold,
  GoldBlack
}
enum ShiningPattern {
  None,
  Alternative,
}

Widget iconDesign(Design design, [double? width, double? height]) {
  switch(design) {
    case Design.Basic:
      return Image.asset("assets/design/DesignNormal.png", width: width, height: height);
    case Design.Holographic:
      return Image.asset("assets/design/DesignHoloVertical.png", width: width, height: height);
    case Design.Reverse:
      return Image.asset("assets/design/DesignReverse0.png", width: width, height: height);
    case Design.ArcEnCiel:
      return Image.asset("assets/design/DesignRainbow.png", width: width, height: height);
    case Design.Gold:
      return Image.asset("assets/design/DesignGold.png", width: width, height: height);
    case Design.GoldBlack:
      return Image.asset("assets/design/DesignGoldBlack.png", width: width, height: height);
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

  Widget icon({double? width, double? height}) {
    if(pattern == ShiningPattern.Alternative)
      switch(design) {
        case Design.Holographic:
          return Image.asset("assets/design/DesignHoloDot.png", width: width, height: height);
        case Design.Reverse:
          return Image.asset("assets/design/DesignReverse1.png", width: width, height: height);
        default:
          return Icon(Icons.help_outline);
      }
    else
      return iconDesign(design, width, height);
  }
}