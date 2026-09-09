
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_design.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/screenOld/widgets/image_stored_locally.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/widgets/image/image_with_cache.dart';

import '../screens/card/card_image.dart';

class PokeRendering {
  static const spacing = 5.0;
  static const bestBoosterHeight = 200.0;
  static const bestCardWidth    = 200.0;
  static const bestCardRatio    = 0.7;
  static const bestProductWidth = 300.0;
  static const bestProductRatio = 0.7;
  static const bestSideProductWidth = 250.0;
  static const bestSideProductRatio = 0.9;
  static const bestMiniCardWidth = 135;
  static const bestMiniCardRatio = 1.2;
  static const colorLightCard = Color(0xFF424242); // = Colors.grey.shade800

  PokeCollection collection;

  // Computed data and internal cache
  final Map<PokeRarity, List<Widget>?> _cachedImageRarity = {};

  PokeRendering(this.collection);

  void clean() {
    _cachedImageRarity.clear();
  }

  List<Widget> imageRarity(PokeRarity rarity, {iconSize, textureSize=20.0, fontSize=12.0, generate=false}) {
    if(generate || _cachedImageRarity[rarity] == null) {
      List<Widget> rendering = rarity.icon(iconSize: iconSize, fontSize: fontSize, textureSize: textureSize);
      if(generate) {
        return rendering;
      } else {
        _cachedImageRarity[rarity] = rendering;
      }
    }
    return _cachedImageRarity[rarity]!;
  }

  Widget genericCardWidget(PokeCardViewerIdentifier cardId, {FilterQuality? quality, double? width, double? height, required PokeLanguage language, bool reloader=false, BoxFit? fit, photoView=false}) {
    if( Environment.instance.storeImageLocally ) {
      Widget alternative = Center(child: Text(cardId.expansion.cards.readTitleOfCard(language, cardId.idCard)));

      var nameDiskImage = "${cardId.idCard.toString()}_${cardId.idImage.toString()}";
      return ImageStoredLocally(["images", "card", language.code(), cardId.expansion.icon()],
          nameDiskImage, cardId.computeImageURI(Environment.instance.pkConfig().showTCGImages), quality: quality, width: width, height: height, alternativeRendering: alternative, reloader: reloader, fit: fit, photoView: photoView);
    } else {
      return CardImage(cardId, height: height ?? 400);
    }
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

  Widget icon(PokeDesign design, {double? width, double? height}) {
    if(design.image().isNotEmpty) {
      return drawCachedImage("design", design.image(), width: width, height: height);
    }
    return const Icon(Icons.help_outline);
  }

  Widget iconFullDesign(PokeCardDesign design, {double? width, double? height}) {
    return Row(
        children : [
          iconArt(design.art, width, height),
          const SizedBox(width: 8),
          icon(design.design, width: width, height: height)
        ]
    );
  }

  static Widget productImage(PokeIdentifier pid, {double? height=70.0, alternativeRendering, photoView=false}) {
    return drawCachedImage('PKProducts', pid.id().toString(), height: height, alternativeRendering: alternativeRendering, photoView: photoView);
  }

  static Widget sideProductImage(PokeIdentifier pid, {alternativeRendering})
  {
    return ImageWithCache.generator('PKSideProducts', [pid.id().toString()], alternativeRendering: alternativeRendering);
  }
}