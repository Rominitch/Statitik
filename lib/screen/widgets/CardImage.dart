import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardImage extends StatefulWidget {
  final List<String> cardImage;
  final double height;
  final SubExtension se;
  final PokemonCardExtension card;
  final int idCard;
  final Language? language;

  CardImage(SubExtension se, PokemonCardExtension card, this.idCard, {this.height=400, this.language}) :
    cardImage = computeImageLabel(se, card, idCard), this.card = card, this.se = se;

  static String convertRomaji(String name) {
    const Map<String, String> convertions = {
      "FYI":  "FI",
      "RY":   "RI",
      "TCH":  "CCH",
      "&":    "TO",
      "CHE":  "CHIE",
      "BYI":  "BII",
      //"JI":   "DI",
      "'":    "", // Remove '
      ".":    "", // Remove .
      " ":    "", // Remove space
      "/":    "", // Remove /
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

      card.data.markers.markers.firstWhere((element) {
        if(element.toTitle)
          romajiName += element.name.name(se.extension.language).toUpperCase();
        return element.toTitle;
      });
      //if( card.data.markers.markers.contains(ECardMarker.V) )           { romajiName += "V"; }
      //else if( card.data.markers.markers.contains(ECardMarker.VMAX) )   { romajiName += "VMAX"; }
      //else if( card.data.markers.markers.contains(ECardMarker.VUNION) ) { romajiName += "VUNION"; }
      //else if( card.data.markers.markers.contains(ECardMarker.VSTAR)  ) { romajiName += "VSTAR"; }
      //else if( card.data.markers.markers.contains(ECardMarker.GX)  )    { romajiName += "GX"; }
      //else if( card.data.markers.markers.contains(ECardMarker.EX)  )    { romajiName += "EX"; }

    } catch(e) {

    }
    return romajiName;
  }

  static List<String> computeImageLabel(SubExtension se, PokemonCardExtension card, int id) {
    if(Environment.instance.showTCGImages){
      if( se.extension.language.id == 1 )
        if(card.image.startsWith("https://"))
          return [card.image];
        else
          return [
             // Official image source
             "https://assets.pokemon.com/assets/cms2-fr-fr/img/cards/web/${se.seCode}/${se.seCode}_FR_${se.seCards.tcgImage(id)}.png",
             // Fiable alternative source
             "https://www.pokecardex.com/assets/images/sets_fr/${(se.seCode).toUpperCase()}/HD/${se.seCards.tcgImage(id)}.jpg"
          ];
      else if( se.extension.language.id == 2 )
        if(card.image.startsWith("https://"))
          return [card.image];
        else
          // Official image source
          return ["https://assets.pokemon.com/assets/cms2/img/cards/web/${se.seCode}/${se.seCode}_EN_${se.seCards.tcgImage(id)}.png"];
      else if( se.extension.language.id == 3 ) {
        if(card.image.startsWith("https://"))
          return [card.image];
        else {
          String romajiName = card.image.isEmpty ? computeJPPokemonName(se, card) : card.image;
          String codeType = "P";
          if(card.data.type == Type.Supporter || card.data.type == Type.Stade || card.data.type == Type.Objet)
            codeType = "T";
          else if(card.data.type == Type.Energy)
            codeType = "E";
          String codeImage = card.jpDBId.toString().padLeft(6, '0');

          return [
            // Official image source
            "https://www.pokemon-card.com/assets/images/card_images/large/${se.seCode}/${codeImage}_${codeType}_$romajiName.jpg",
            // Fiable alternative source
            "https://www.pokecardex.com/assets/images/sets_jp/${se.seCode.toUpperCase()}/HD/${se.seCards.tcgImage(id)}.jpg"
          ];
        }
      }
    }
    return [""];
  }

  @override
  State<CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<CardImage> {
  StreamController<int> onURLError = StreamController<int>();

  @override
  void initState() {
    onURLError.stream.listen((event) {
      setState(() {
        widget.cardImage.removeAt(0);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    onURLError.close();
    super.dispose();
  }

  Widget buildCachedImage([bool admin=false]) {
    if(widget.cardImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.cardImage.first,
        errorWidget: (context, url, error) {
          if(admin && widget.se.extension.language.id == 3) {
            widget.card.jpDBId = 0;
          }
          onURLError.add(0);
          return Icon(Icons.help_outline);
        },
        filterQuality: widget.height > 300 ? FilterQuality.low : FilterQuality.medium,
        placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
        height: widget.height,
      );
    } else {
      return widget.language != null
          ? Center(child: Text(widget.se.seCards.titleOfCard(widget.language!, widget.idCard)))
          : Icon(Icons.help_outline);
    }
  }
  @override
  Widget build(BuildContext context) {
    if(Environment.instance.user != null && Environment.instance.user!.admin)
      return Tooltip(
        message: widget.cardImage.isNotEmpty ? widget.cardImage.first : "",
        child: buildCachedImage(true)
      );
    else
      return buildCachedImage();
  }
}