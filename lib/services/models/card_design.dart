import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

// WARNING: Never changed order
enum Design {
  mat,
  holographic,
  reverse,
  arcEnCiel,
  gold,
  goldBlack,
  shiny,
  full,
  k,
  unknown,
}

enum ShiningPattern {
  none,
  alternative,
  alternative2,
  alternative3,
  alternative4,
  alternative5,
  alternative6,
  alternative7,
}

enum ArtFormat {
  normal,
  halfArt,
  fullArt,
  unknown,
}

Widget iconArt(ArtFormat design, [double? width, double? height]) {
  switch(design) {
    case ArtFormat.normal:
      return Image.asset("assets/design/ArtNormal.png", width: width, height: height);
    case ArtFormat.halfArt:
      return Image.asset("assets/design/ArtHalf.png", width: width, height: height);
    case ArtFormat.fullArt:
      return Image.asset("assets/design/ArtFull.png", width: width, height: height);
    default:
      return const Icon(Icons.help_outline);
  }
}

String codeArt(BuildContext context, ArtFormat design) {
  switch(design) {
    case ArtFormat.normal:
      return AppLocalizations.of(context)!.art_n;
    case ArtFormat.halfArt:
      return AppLocalizations.of(context)!.art_ha;
    case ArtFormat.fullArt:
      return AppLocalizations.of(context)!.art_fa;
    default:
      return '';
  }
}

class CardDesign {
  int         design;
  int         pattern;
  ArtFormat   art;

  CardDesign([this.design = 0, this.pattern = 0, this.art = ArtFormat.normal]);

  CardDesign.fromBytesV1(ByteParser parser):
    design  = Design.unknown.index,
    pattern = ShiningPattern.none.index,
    art     = ArtFormat.normal
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
    design  = Design.unknown.index,
    pattern = ShiningPattern.none.index,
    art     = ArtFormat.unknown
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

  String name(LanguageOld l) {
    return designData().name(l);
  }

  Widget icon({double? width, double? height}) {
    return designData().icon(width: width, height: height);
  }

  CardDesignData designData() {
    return Environment.instance.collection.designs[design]![pattern]!;
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
  CardDesignData.fromBytes(ByteParser parser):
    image = parser.extractString16(),
    nameDesign = parser.extractMultiLanguage()!;

  List<int> toBytes() {
    return ByteEncoder.encodeString16(image.codeUnits)
    + ByteEncoder.encodeMultiLanguage(nameDesign);
  }

  String name(LanguageOld l) {
    return nameDesign.name(l);
  }

  Widget icon({double? width, double? height}) {
    if(image.isNotEmpty) {
      return drawCachedImage("design", image, width: width, height: height);
    }
    return const Icon(Icons.help_outline);
  }
}