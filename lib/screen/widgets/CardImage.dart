
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardImage extends StatelessWidget {
  final String cardImage;
  final double height;
  final PokemonCardExtension card;

  CardImage(SubExtension se, PokemonCardExtension card, int id, {this.height=400}) :
    cardImage = computeImageLabel(se, card, id), this.card = card;

  static String convertRomaji(String name) {
    const Map<String, String> convertions = {
      "FYI":  "FI",
      "RY":   "RI",
      "TCH":  "CCH",
      "&":    "TO",
      "CHE":  "CHIE",
      "BYI":  "BII",
      //"JI":   "DI",
      "'":    "",
      ".":    "",
      " ":    "", // Remove space
      // Kanji Convertion
      "溶接工": "YOUSETSUKOU",
      "基本": "KIHON",
      "回収":   "KAISHUU",
      "博士":   "HAKASE",
      "研究":   "KENKYUU",
      "通信":   "TSUUSHIN",
      "探索":   "TANSAKU",
      "加速":   "KASOKU",
      "転送":   "TENSOU",
      "指令":   "SHIREI",
      "無色":   "MUSHOKU",
      "姉":     "NEE",
      "水":    "MIZU",
      "団":    "DAN",
      "雷":    "KAMINARI",
      "超":    "CHOU",
      "草":    "KUSA",
      "悪":    "AKU",
      "闘":    "TOU",
      "炎":    "HONOO",
      "鋼":    "KOU",
    };
    const kanaKit = KanaKit();
    var val = "";
    try {
      // Remove no translate symbol
      name = name.replaceAll("ー", ""); // ー is not translated

      // Convert kana
      val = kanaKit.copyWithConfig(upcaseKatakana: true).toRomaji(name);
      val = val.toUpperCase();

      // Finish by clean converter
      convertions.forEach((key, value) {
        val = val.replaceAll(key, value);
      });
    } catch(e) {

    }
    return val;
  }

  static String computeJPPokemonName(SubExtension se, PokemonCardExtension card) {
    String romajiName = "";
    try {
      romajiName = convertRomaji(card.data.titleOfCard(se.extension.language));

      if( card.data.markers.markers.contains(CardMarker.V) )           { romajiName += "V"; }
      else if( card.data.markers.markers.contains(CardMarker.VMAX) )   { romajiName += "VMAX"; }
      else if( card.data.markers.markers.contains(CardMarker.VUNION) ) { romajiName += "VUNION"; }
      else if( card.data.markers.markers.contains(CardMarker.VSTAR)  ) { romajiName += "VSTAR"; }

    } catch(e, s) {

    }
    return romajiName;
  }

  static String computeExtension(SubExtension se) {
    const List<String> removeColor = [
      "Blue",
      "Green",
      "Yellow",
      "Red",
      "Brown",
    ];
    String ext = se.icon;
    removeColor.forEach((value) {
      ext = ext.replaceAll(value, "");
    });
    return ext;
  }

  static String computeImageLabel(SubExtension se, PokemonCardExtension card, int id) {
    if(Environment.instance.showTCGImages){
      if( se.extension.language.id == 1 )
        return "https://assets.pokemon.com/assets/cms2-fr-fr/img/cards/web/${se.icon}/${se.icon}_FR_${se.seCards.tcgImage(id)}.png";
      else if( se.extension.language.id == 2 )
        return "https://assets.pokemon.com/assets/cms2/img/cards/web/${se.icon}/${se.icon}_EN_${se.seCards.tcgImage(id)}.png";
      else if( se.extension.language.id == 3 ) {
        if(card.image.startsWith("https://"))
          return card.image;
        else {
          String ext = computeExtension(se);
          String romajiName = card.image.isEmpty ? computeJPPokemonName(se, card) : card.image;
          String codeType = "P";
          if(card.data.type == Type.Supporter || card.data.type == Type.Stade || card.data.type == Type.Objet)
            codeType = "T";
          else if(card.data.type == Type.Energy)
            codeType = "E";
          String codeImage = card.jpDBId.toString().padLeft(6, '0');

          return "https://www.pokemon-card.com/assets/images/card_images/large/$ext/${codeImage}_${codeType}_$romajiName.jpg";
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
              card.jpDBId = 0;
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