
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_design.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/screenOld/widgets/image_stored_locally.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/tools.dart';

import '../screens/card/card_image.dart';

class PokeRendering {
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

  Widget genericCardWidget(PokeCardViewerIdentifier cardId, {FilterQuality? quality, double? width, double? height, required PokeLangage language, bool reloader=false, BoxFit? fit, photoView=false}) {
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
}