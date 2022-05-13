import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';

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
  int         design;
  int         pattern;
  ArtFormat   art;

  CardDesign([this.design = 0, this.pattern = 0, this.art = ArtFormat.Normal]);

  CardDesign.fromBytesV1(ByteParser parser):
    this.design  = Design.Unknown.index,
    this.pattern = ShiningPattern.None.index,
    this.art     = ArtFormat.Normal
  {
    int idDesign = parser.extractInt8();
    if(idDesign < Design.values.length)
      this.design  = idDesign;

    int idPattern = parser.extractInt8();
    if(idPattern < ShiningPattern.values.length)
      this.pattern = idPattern;
  }

  CardDesign.fromBytes(ByteParser parser):
    this.design  = Design.Unknown.index,
    this.pattern = ShiningPattern.None.index,
    this.art     = ArtFormat.Unknown
  {
    int idDesign = parser.extractInt8();
    if(idDesign < Design.values.length)
      this.design  = idDesign;

    int idPattern = parser.extractInt8();
    if(idPattern < ShiningPattern.values.length)
      this.pattern = idPattern;

    int idArt = parser.extractInt8();
    if(idArt < ArtFormat.values.length)
      this.art     = ArtFormat.values[idArt];
  }

  List<int> toBytes() {
    return  ByteEncoder.encodeInt8(design)  +
            ByteEncoder.encodeInt8(pattern) +
            ByteEncoder.encodeInt8(art.index);
  }

  String name(Language l) {
    return designData().name(l);
  }

  Widget icon({double? width, double? height}) {
    return designData().icon(width: width, height: height);
  }

  CardDesignData designData() {
    return Environment.instance.collection.designs[design][pattern];
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
  int get hashCode => design * 100 + pattern;

  void copyFrom(CardDesign selectedDesign) {
    design  = selectedDesign.design;
    pattern = selectedDesign.pattern;
  }
}

class CardDesignData {
  String              image;
  MultiLanguageString nameDesign;

  CardDesignData(this.image, this.nameDesign);

  String name(Language l) {
    return nameDesign.name(l);
  }

  Widget icon({double? width, double? height}) {
    if(this.image.isNotEmpty)
      return drawCachedImage("design", this.image, width: width, height: height);
    return Icon(Icons.help_outline);
  }
}