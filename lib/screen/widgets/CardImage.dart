import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/screen/widgets/ImageStoredLocally.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/PokemonCardData.dart';


Widget genericCardWidget(SubExtension se, CardIdentifier idCard, {double height=400, Language? language, bool reloader=false}) {
  if( Environment.instance.storeImageLocally ) {
    Widget? alternative;
    if( language != null ) {
      alternative = Center(child: Text(se.seCards.readTitleOfCard(language, idCard)));
    }
    return ImageStoredLocally(["images", "card", se.extension.language.image, se.seCode.first],
      idCard.toString(), CardImage.computeImageURI(se, idCard), height: height, alternativeRendering: alternative, reloader: reloader);

  } else {
    return CardImage(se, se.cardFromId(idCard), idCard, height: height, language: language);
  }
}

class CardImage extends StatefulWidget {
  final List<Uri> cardImage;
  final double height;
  final SubExtension se;
  final PokemonCardExtension card;
  final CardIdentifier idCard;
  final Language? language;

  CardImage(SubExtension se, PokemonCardExtension card, this.idCard, {this.height=400, this.language}) :
    cardImage = computeImageLabel(se, card, idCard.numberId), this.card = card, this.se = se;

  static String convertRomaji(String name) {
    const Map<String, String> conversions = {
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
      conversions.forEach((key, value) {
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
    } catch(e) {

    }
    return romajiName;
  }

  static List<Uri> computeImageURI(SubExtension se, CardIdentifier card) {
    return computeImageLabel(se, se.cardFromId(card), card.numberId);
  }

  static List<Uri> computeImageLabel(SubExtension se, PokemonCardExtension card, int id) {
    if(Environment.instance.showTCGImages){
      if(card.finalImage.isNotEmpty)
        return [Uri.parse(card.finalImage)];

      if( se.extension.language.id == 1 )
        if(card.image.startsWith("https://"))
          return [Uri.parse(card.image)];
        else
        if( se.seCards.energyCard.contains(card) )
          return [Uri.https("assets.pokemon.com", "assets/cms2-fr-fr/img/cards/web/NRG/NRG_FR_${card.image}.png")];
        else {
          List<Uri> images = [];
          se.seCode.forEach((seFolder) {
            // Official image source
            images += [
              Uri.https("assets.pokemon.com", "assets/cms2-fr-fr/img/cards/web/$seFolder/${seFolder}_FR_${se.seCards.tcgImage(id)}.png"),
              Uri.https("www.pokecardex.com", "assets/images/sets_fr/${seFolder.toUpperCase()}/HD/${se.seCards.tcgImage(id)}.jpg"),
              Uri.https("www.pokecardex.com", "assets/images/sets/${seFolder.toUpperCase()}/HD/${se.seCards.tcgImage(id)}.jpg"),
            ];
          });
          return images;
        }
      else if( se.extension.language.id == 2 )
        if(card.image.startsWith("https://"))
          return [Uri.parse(card.image)];
        else
        if( se.seCards.energyCard.contains(card) )
          return [Uri.https("assets.pokemon.com", "assets/cms2/img/cards/web/NRG/NRG_EN_${card.image}.png")];
        else {
          // Official image source
          List<Uri> images = [];
          se.seCode.forEach((seFolder) {
            images += [
              Uri.https("assets.pokemon.com", "assets/cms2/img/cards/web/$seFolder/${seFolder}_EN_${se.seCards.tcgImage(id)}.png")
            ];
          });
          return images;
        }
      else if( se.extension.language.id == 3 ) {
        if(card.image.startsWith("https://"))
          return [Uri.parse(card.image)];
        else {
          String romajiName = card.image.isEmpty ? computeJPPokemonName(se, card) : card.image;
          String codeType = "P";
          if(card.data.type == TypeCard.Supporter || card.data.type == TypeCard.Stade || card.data.type == TypeCard.Objet)
            codeType = "T";
          else if(card.data.type == TypeCard.Energy)
            codeType = "E";
          String codeImage = card.jpDBId.toString().padLeft(6, '0');

          List<Uri> images = [];
          se.seCode.forEach((seFolder) {
            // Official image source
            images.add(Uri.https("www.pokemon-card.com", "assets/images/card_images/large/$seFolder/${codeImage}_${codeType}_$romajiName.jpg"));
            // Fiable alternative source
            images.add(Uri.https("www.pokecardex.com", "assets/images/sets_jp/${seFolder.toUpperCase()}/HD/${se.seCards.tcgImage(id)}.jpg"));
          });
          return images;
        }
      }
    }
    return [Uri()];
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
      // Save current name (to avoid search in future)
      widget.card.finalImage = widget.cardImage.first.toString();

      // Show image if possible
      return CachedNetworkImage(
        imageUrl: widget.cardImage.first.toString(),
        errorWidget: (context, url, error) {
          widget.card.finalImage = "";
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
          ? Center(child: Text(widget.se.seCards.readTitleOfCard(widget.language!, widget.idCard)))
          : Icon(Icons.help_outline);
    }
  }
  @override
  Widget build(BuildContext context) {
    if(Environment.instance.isAdministrator())
      return Tooltip(
        message: widget.card.finalImage.isNotEmpty ? widget.card.finalImage : widget.cardImage.join("\n"),
        child: buildCachedImage(true)
      );
    else
      return buildCachedImage();
  }
}