import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';

// WARNING: Never changed order
enum Design {
  Mat,
  Holographic,
  Reverse,
  ArcEnCiel,
  Gold,
  GoldBlack,
  Shiny,
  Full,
  K,
  Unknown,
}

enum ShiningPattern {
  None,
  Alternative,
  Alternative2,
  Alternative3,
}

enum ArtFormat {
  Normal,
  HalfArt,
  FullArt,
  Unknown,
}

Widget iconArt(ArtFormat design, [double? width, double? height]) {
  switch(design) {
    case ArtFormat.Normal:
      return Image.asset("assets/design/ArtNormal.png", width: width, height: height);
    case ArtFormat.HalfArt:
      return Image.asset("assets/design/ArtHalf.png", width: width, height: height);
    case ArtFormat.FullArt:
      return Image.asset("assets/design/ArtFull.png", width: width, height: height);
    default:
      return Icon(Icons.help_outline);
  }
}

String codeArt(ArtFormat design) {
  switch(design) {
    case ArtFormat.Normal:
      return 'ART_N';
    case ArtFormat.HalfArt:
      return 'ART_HA';
    case ArtFormat.FullArt:
      return 'ART_FA';
    default:
      return '';
  }
}

Widget iconDesign(Design design, [double? width, double? height]) {
  switch(design) {
    case Design.Mat:
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
    case Design.Full:
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
  ArtFormat      art;

  CardDesign([this.design = Design.Mat, this.pattern = ShiningPattern.None, this.art = ArtFormat.Normal]);

  CardDesign.fromBytesV1(ByteParser parser):
    this.design  = Design.Unknown,
    this.pattern = ShiningPattern.None,
    this.art     = ArtFormat.Normal
  {
    int idDesign = parser.extractInt8();
    if(idDesign < Design.values.length)
      this.design  = Design.values[idDesign];

    int idPattern = parser.extractInt8();
    if(idPattern < ShiningPattern.values.length)
      this.pattern = ShiningPattern.values[idPattern];
  }

  CardDesign.fromBytes(ByteParser parser):
    this.design  = Design.Unknown,
    this.pattern = ShiningPattern.None,
    this.art     = ArtFormat.Unknown
  {
    int idDesign = parser.extractInt8();
    if(idDesign < Design.values.length)
      this.design  = Design.values[idDesign];

    int idPattern = parser.extractInt8();
    if(idPattern < ShiningPattern.values.length)
      this.pattern = ShiningPattern.values[idPattern];

    int idArt = parser.extractInt8();
    if(idArt < ArtFormat.values.length)
      this.art     = ArtFormat.values[idArt];
  }

  List<int> toBytes() {
    return  ByteEncoder.encodeInt8(design.index) +
            ByteEncoder.encodeInt8(pattern.index) +
            ByteEncoder.encodeInt8(art.index);
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
          case ShiningPattern.Alternative3:
            return "DESIGN_H3";
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
          case ShiningPattern.Alternative3:
            return "DESIGN_R3";
          default:
            return "DESIGN_R0";
        }
      }
      case Design.ArcEnCiel:
        return 'DESIGN_R';
      case Design.Gold:
        return 'DESIGN_G';
      case Design.GoldBlack:
        return 'DESIGN_GB';
      case Design.Shiny:
        return 'DESIGN_SH';
      case Design.Full:
        return 'DESIGN_F';
      case Design.K:
        return 'DESIGN_K';
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
    else if(pattern == ShiningPattern.Alternative3)
      switch(design) {
        case Design.Holographic:
          return Image.asset("assets/design/DesignHoloMosaic.png", width: width, height: height);
        case Design.Reverse:
          return Image.asset("assets/design/DesignReverseEnergy.png", width: width, height: height);
        default:
      }
    return Icon(Icons.help_outline);
  }

  Widget iconFullDesign({double? width, double? height}) {
    return Row(
        children : [
          iconArt(art, width, height),
          SizedBox(width: 8),
          icon(width: width, height: height)
        ]
    );
  }

  @override
  bool operator ==(other) {
    return other is CardDesign && design == other.design && pattern == other.pattern;
  }

  @override
  int get hashCode => design.index * 100 + pattern.index;

  void copyFrom(CardDesign selectedDesign) {
    design  = selectedDesign.design;
    pattern = selectedDesign.pattern;
  }
}

List<CardDesign> validDesigns = [
  CardDesign(Design.Mat),
  CardDesign(Design.Holographic),
  CardDesign(Design.Holographic, ShiningPattern.Alternative),
  CardDesign(Design.Holographic, ShiningPattern.Alternative2),
  CardDesign(Design.Holographic, ShiningPattern.Alternative3),
  CardDesign(Design.Reverse),
  CardDesign(Design.Reverse, ShiningPattern.Alternative),
  CardDesign(Design.Reverse, ShiningPattern.Alternative2),
  CardDesign(Design.Reverse, ShiningPattern.Alternative3),
  CardDesign(Design.Full),
  CardDesign(Design.ArcEnCiel),
  CardDesign(Design.Gold),
  CardDesign(Design.GoldBlack),
  CardDesign(Design.Shiny),
  CardDesign(Design.K),
];