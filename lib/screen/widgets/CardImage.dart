
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
      name = name.replaceAll("ー", ""); // ー is not translated
      val = kanaKit.copyWithConfig(upcaseKatakana: true).toRomaji(name);
      val = val.replaceAll("FYI", "FI");
      val = val.replaceAll("RY", "RI");
      val = val.replaceAll("'", "");
      val = val.replaceAll(".", "");
      val = val.replaceAll(" ", ""); // Remove space
      val = val.toUpperCase();
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
          // Search jp ID card (by default start from first card)
          var ancestorCard = se.seCards.cards.reversed.firstWhere((element) => element[0].image.isNotEmpty);

          if(ancestorCard[0].image.isNotEmpty) {
            String codeImage  = "";
            String romajiName = "";
            String codeType = "P";
            try {
              codeImage = (int.parse(ancestorCard[0].image.split("_")[0]) + id).toString().padLeft(6, '0');
              romajiName = convertRomaji(card.data.titleOfCard(se.extension.language));
            } catch(e, s) {

            }
            var specialCode = "";
            if( card.data.markers.markers.contains(CardMarker.V) )         { specialCode = "V"; }
            else if( card.data.markers.markers.contains(CardMarker.VMAX) ) { specialCode = "VMAX"; }
            else if( card.data.markers.markers.contains(CardMarker.VUNION) ) { specialCode = "VUNION"; }
            if(card.data.type == Type.Supporter || card.data.type == Type.Stade || card.data.type == Type.Objet)
              codeType = "T";
            else if(card.data.type == Type.Energy)
              codeType = "E";
            return "https://www.pokemon-card.com/assets/images/card_images/large/${se.icon}/${codeImage}_${codeType}_$romajiName$specialCode.jpg";
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
      if(Environment.instance.user != null && Environment.instance.user!.admin)
        return Tooltip(
          message: cardImage,
          child: CachedNetworkImage(
            imageUrl: cardImage,
            errorWidget: (context, url, error) {
              return Icon(Icons.help_outline);
            },
            filterQuality: height > 300 ? FilterQuality.low : FilterQuality.medium,
            placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
            height: height,
          ),
        );
      else
        return CachedNetworkImage(
          imageUrl: cardImage,
          errorWidget: (context, url, error) {
            return Icon(Icons.help_outline);
          },
          placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
          height: height,
        );
    else
      return Container(height: height);
  }
}