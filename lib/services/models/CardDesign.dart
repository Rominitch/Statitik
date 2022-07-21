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
  Alternative4,
  Alternative5,
  Alternative6,
  Alternative7,
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
      return const Icon(Icons.help_outline);
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

class CardDesign {
  int         design;
  int         pattern;
  ArtFormat   art;

  CardDesign([this.design = 0, this.pattern = 0, this.art = ArtFormat.Normal]);

  CardDesign.fromBytesV1(ByteParser parser):
    design  = Design.Unknown.index,
    pattern = ShiningPattern.None.index,
    art     = ArtFormat.Normal
  {
    int idDesign = parser.extractInt8();
    if(idDesign < Design.values.length) {
      design = idDesign;
    }

    int idPattern = parser.extractInt8();
    if(idPattern < ShiningPattern.values.length) {
      pattern = idPattern;
    }
  }

  CardDesign.fromBytes(ByteParser parser):
    design  = Design.Unknown.index,
    pattern = ShiningPattern.None.index,
    art     = ArtFormat.Unknown
  {
    int idDesign = parser.extractInt8();
    design  = idDesign;

    int idPattern = parser.extractInt8();
    pattern = idPattern;

    int idArt = parser.extractInt8();
    if(idArt < ArtFormat.values.length) {
      art = ArtFormat.values[idArt];
    }
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
          const SizedBox(width: 8),
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
    if(image.isNotEmpty) {
      return drawCachedImage("design", image, width: width, height: height);
    }
    return const Icon(Icons.help_outline);
  }
}