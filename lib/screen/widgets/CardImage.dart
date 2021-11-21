
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardImage extends StatelessWidget {
  final String cardImage;
  final double height;

  CardImage(SubExtension se, PokemonCardExtension card, int id, {this.height=400}) :
    cardImage = computeImageLabel(se, card, id);

  static String convertRomaji(String name) {
    const kanaKit = KanaKit();
    var val = "";
    try {
      name = name.replaceAll("ー", "");
      val = kanaKit.copyWithConfig(upcaseKatakana: true).toRomaji(name);
      val = val.replaceAll("FYI", "FI");
    } catch(e) {

    }
    return val;
  }

  static String computeImageLabel(SubExtension se, PokemonCardExtension card, int id) {
    if(Environment.instance.showTCGImages){
      if( se.extension.language.id == 1 )
        return "https://assets.pokemon.com/assets/cms2-fr-fr/img/cards/web/${se.icon}/${se.icon}_FR_${se.seCards.tcgImage(id)}.png";
      else if( se.extension.language.id == 2 )
        return "https://assets.pokemon.com/assets/cms2/img/cards/web/${se.icon}/${se.icon}_EN_${se.seCards.tcgImage(id)}.png";
      else if( se.extension.language.id == 3 ) {
        if( card.image.isEmpty) {
          if(se.seCards.cards[0][0].image.isNotEmpty) {
            String codeImage  = "";
            String romajiName = "";
            try {
              codeImage = (int.parse(se.seCards.cards[0][0].image.split("_")[0]) + id).toString().padLeft(6, '0');
              romajiName = convertRomaji(card.data.titleOfCard(se.extension.language));
            } catch(e, s) {

            }
            var specialCode = "";
            if( card.data.markers.markers.contains(CardMarker.V) )         { specialCode = "V"; }
            else if( card.data.markers.markers.contains(CardMarker.VMAX) ) { specialCode = "VMAX"; }
            return "https://www.pokemon-card.com/assets/images/card_images/large/${se.icon}/${codeImage}_P_$romajiName$specialCode.jpg";
          }
        } else {
          return "https://www.pokemon-card.com/assets/images/card_images/large/${se.icon}/${card.image}.jpg";
        }
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if(cardImage.isNotEmpty)
      return CachedNetworkImage(
        imageUrl: cardImage,
        errorWidget: (context, url, error) {
          return Icon(Icons.help_outline);
        },
        placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
        height: height,
      );
    else
      return Container();
  }
}