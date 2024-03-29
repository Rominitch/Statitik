import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';

enum Design {
  Basic,
  Holographic,
  Reverse,
  ArcEnCiel,
  Gold,
  GoldBlack,
  Shiny,
  FullArt,
  K,
}
enum ShiningPattern {
  None,
  Alternative,
  Alternative2,
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
    case Design.Shiny:
      return Image.asset("assets/design/DesignShiny.png", width: width, height: height);
    case Design.FullArt:
      return Image.asset("assets/design/DesignFullArt.png", width: width, height: height);
    case Design.K:
      return Image.asset("assets/design/DesignK.png", width: width, height: height);
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

  String nameCode() {
    switch(design) {
      case Design.Holographic:
      {
        switch(pattern) {
          case ShiningPattern.Alternative:
            return "DESIGN_H1";
          case ShiningPattern.Alternative2:
            return "DESIGN_H2";
          default:
            return "DESIGN_H0";
        }
      }
      case Design.Reverse:
      {
        switch(pattern) {
          case ShiningPattern.Alternative:
            return "DESIGN_R1";
          case ShiningPattern.Alternative2:
            return "DESIGN_R2";
          default:
            return "DESIGN_R0";
        }
      }
      case Design.ArcEnCiel:
        return 'DESIGN_R';
      case Design.Gold:
        return 'DESIGN_G';
      case Design.GoldBlack:
        return 'DESIGN_G';
      case Design.Shiny:
        return 'DESIGN_SH';
      case Design.FullArt:
        return 'DESIGN_F';
      default:
        return "DESIGN_S";
    }
  }

  Widget icon({double? width, double? height}) {
    if(pattern == ShiningPattern.None)
      return iconDesign(design, width, height);
    else if(pattern == ShiningPattern.Alternative)
      switch(design) {
        case Design.Holographic:
          return Image.asset("assets/design/DesignHoloDot.png", width: width, height: height);
        case Design.Reverse:
          return Image.asset("assets/design/DesignReverse1.png", width: width, height: height);
        default:
      }
    else if(pattern == ShiningPattern.Alternative2)
      switch(design) {
        case Design.Holographic:
          return Image.asset("assets/design/DesignHoloLight.png", width: width, height: height);
        case Design.Reverse:
          return Image.asset("assets/design/DesignReversePoke.png", width: width, height: height);
        default:
      }
    return Icon(Icons.help_outline);
  }

  @override
  bool operator ==(other) {
    return other is CardDesign && design == other.design && pattern == other.pattern;
  }

  @override
  int get hashCode => design.index * 100 + pattern.index;
}