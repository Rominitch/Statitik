import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';

import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/screen/widgets/image_stored_locally.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';

Widget genericCardWidget(SubExtension se, CardIdentifier idCard, CardImageIdentifier idImage, {FilterQuality? quality, double? width, double? height, Language? language, bool reloader=false, BoxFit? fit}) {
  if( Environment.instance.storeImageLocally ) {
    Widget? alternative;
    if( language != null ) {
      alternative = Center(child: Text(se.seCards.readTitleOfCard(language, idCard)));
    }
    var nameDiskImage = "${idCard.toString()}_${idImage.toString()}";
    return ImageStoredLocally(["images", "card", se.extension.language.image, se.icon],
      nameDiskImage, CardImage.computeImageURI(se, idCard, idImage), quality: quality, width: width, height: height, alternativeRendering: alternative, reloader: reloader, fit: fit);
  } else {
    return CardImage(se, se.cardFromId(idCard), idCard, idImage, height: height ?? 400, language: language);
  }
}

class CardImage extends StatefulWidget {
  final List<Uri> cardImage;
  final double height;
  final SubExtension se;
  final PokemonCardExtension card;
  final CardIdentifier idCard;
  final Language? language;
  final CardImageIdentifier idImage;

  CardImage(SubExtension currentSE, PokemonCardExtension currentCard, this.idCard, this.idImage, {this.height=400, this.language, Key? key}) :
    cardImage = computeImageLabel(currentSE, currentCard, idCard, idImage), card = currentCard, se = currentSE, super(key: key);

  static String convertRomaji(String name, bool alternative) {
    const kanaKit = KanaKit();
    var val = "";
    try {
      // Remove no translate symbol
      val = name.replaceAll("ー", ""); // ー is not translated

      for(var key in Environment.instance.collection.orderedKanji.reversed) {
        var value = Environment.instance.collection.convertKanji[key];
        val = val.replaceAll(key, value);
      }
      if( alternative ) {
        val = val.replaceAll("ャ", "XYA");
        val = val.replaceAll("ュ", "XYU");
        val = val.replaceAll("ョ", "XYO");
        val = val.replaceAll("ゃ", "XYA");
        val = val.replaceAll("ゅ", "XYU");
        val = val.replaceAll("ょ", "XYO");
      }

      // Convert kana
      val = kanaKit.copyWithConfig(upcaseKatakana: true).toRomaji(val);
      val = val.toUpperCase();

      // Finish by clean converter
      for(var key in Environment.instance.collection.orderedKanji.reversed) {
        var value = Environment.instance.collection.convertKanji[key];
        val = val.replaceAll(key, value);
      }
    } catch(_) {}
    return val;
  }

  static String computeJPPokemonName(SubExtension se, PokemonCardExtension card, [bool alternative=false]) {
    String romajiName = "";
    try {
      romajiName = convertRomaji(card.data.titleOfCard(se.extension.language), alternative);

      card.data.markers.markers.firstWhere((element) {
        if(element.toTitle) {
          romajiName += element.name.name(se.extension.language).toUpperCase();
        }
        return element.toTitle;
      });
    } catch(_) {}
    return romajiName;
  }

  static List<Uri> computeImageURI(SubExtension se, CardIdentifier card, CardImageIdentifier idImage) {
    return computeImageLabel(se, se.cardFromId(card), card, idImage);
  }

  static List<Uri> computeImageLabel(SubExtension se, PokemonCardExtension card, CardIdentifier cardId, CardImageIdentifier idImage) {
    if(Environment.instance.showTCGImages){
      ImageDesign defaultImage = card.image(idImage)!;

      if(defaultImage.finalImage.isNotEmpty) {
        return [Uri.parse(defaultImage.finalImage)];
      }


      List<Uri> images = [];

      // Card Order:
      // - Official
      // - Mine
      // - Alternative

      // Mine
      var cardIdentifier = "${cardId.toString()}_${idImage.toString()}";
      var cardPath = "StatitikCard/card/${se.extension.language.image}/${se.icon}/$cardIdentifier";
      var formats = ["webp", "png", "jpg"];
      for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardPath.$ext"));}

      if(cardId.listId == 1) {
        var cardEnergyPath = "StatitikCard/card/${se.extension.language.image}/E_${se.icon}_${cardId.numberId+1}";
        for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardEnergyPath.$ext"));}
        var cardEnergy2Path = "StatitikCard/card/${se.extension.language.image}/E_${defaultImage.image}_${cardId.numberId+1}";
        for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardEnergy2Path.$ext"));}
      }
      if(cardId.listId == 2) {
        var cardNoNumberPath = "StatitikCard/card/${se.extension.language.image}/$cardIdentifier";
        for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardNoNumberPath.$ext"));}
      }

      //
      if( se.extension.language.id == 1 ) {
        if (defaultImage.image.startsWith("https://")) {
          images += [Uri.parse(defaultImage.image)];
        } else {
          int addAt = cardId.listId != 0 ? images.length : 0;
          for (var seFolder in se.seCode) {
            String tcgId = se.seCards.tcgImage(cardId.numberId);
            // Official image source
            if (cardId.listId == 1) {
              images.insert(addAt, Uri.https("assets.pokemon.com",
                  "assets/cms2-fr-fr/img/cards/web/NRG/NRG_FR_${defaultImage
                      .image}.png"));
            }

            images.insert(addAt, Uri.https("assets.pokemon.com",
                "assets/cms2-fr-fr/img/cards/web/$seFolder/${seFolder}_FR_$tcgId.png"));
            // Reliable alternative source
            images += [
              Uri.https("www.pokecardex.com", "assets/images/sets_fr/${seFolder
                  .toUpperCase()}/HD/$tcgId.jpg"),
              Uri.https("www.pokecardex.com",
                  "assets/images/sets/${seFolder.toUpperCase()}/HD/$tcgId.jpg"),
              Uri.https("www.pokecardex.com",
                  "assets/images/sets_fr/${seFolder.toUpperCase()}/HD/${cardId
                      .numberId + 1}.jpg"),
              Uri.https("www.pokecardex.com",
                  "assets/images/sets/${seFolder.toUpperCase()}/HD/${cardId
                      .numberId + 1}.jpg"),
            ];
          }
        }
      } else if( se.extension.language.id == 2 ) {
        if (defaultImage.image.startsWith("https://")) {
          images += [Uri.parse(defaultImage.image)];
        } else {
          int addAt = cardId.listId != 0 ? images.length : 0;
          if (cardId.listId == 1) {
            images.insert(addAt, Uri.https("assets.pokemon.com",
                "assets/cms2/img/cards/web/NRG/NRG_EN_${defaultImage
                    .image}.png"));
          }

          // Official image source
          for (var seFolder in se.seCode) {
            images.insert(addAt, Uri.https("assets.pokemon.com",
                "assets/cms2/img/cards/web/$seFolder/${seFolder}_EN_${se.seCards
                    .tcgImage(cardId.numberId)}.png"));
          }
        }
      } else if( se.extension.language.id == 3 ) {
        if(defaultImage.image.startsWith("https://")) {
          images += [Uri.parse(defaultImage.image)];
        } else {
          var romajiNames = [
            defaultImage.image.isEmpty ? computeJPPokemonName(se, card)       : defaultImage.image,
            defaultImage.image.isEmpty ? computeJPPokemonName(se, card, true) : defaultImage.image,
          ];

          String codeType = "P";
          if(card.data.type == TypeCard.supporter || card.data.type == TypeCard.stade || card.data.type == TypeCard.objet) {
            codeType = "T";
          } else if(card.data.type == TypeCard.energy) {
            codeType = "E";
          }
          String codeImage = defaultImage.jpDBId.toString().padLeft(6, '0');

          for( var romajiName in romajiNames )
          {
            if( cardId.listId == 1 ) {
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large/ENE/${codeImage}_${codeType}_$romajiName.jpg"));
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large//${codeImage}_${codeType}_$romajiName.jpg"));
            }

            for (var seFolder in se.seCode) {
              // Official image source
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large/$seFolder/${codeImage}_${codeType}_${romajiName}_m.jpg"));
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large/$seFolder/${codeImage}_${codeType}_$romajiName.jpg"));
              // Reliable alternative source
              images.add(Uri.https("www.pokecardex.com", "assets/images/sets_jp/${seFolder.toUpperCase()}/HD/${se.seCards.tcgImage(cardId.numberId)}.jpg"));
            }
          }
        }
      }
      return images;
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
    var img = widget.card.tryGetImage(widget.idImage);
    if(widget.cardImage.isNotEmpty) {
      // Save current name (to avoid search in future)
      img.finalImage = widget.cardImage.first.toString();

      // Show image if possible
      return CachedNetworkImage(
        imageUrl: widget.cardImage.first.toString(),
        errorWidget: (context, url, error) {
          img.finalImage = "";
          if(admin && widget.se.extension.language.id == 3) {
            widget.card.tryGetImage(widget.idImage).jpDBId = 0;
          }
          onURLError.add(0);
          return const Icon(Icons.help_outline);
        },
        filterQuality: widget.height > 300 ? FilterQuality.low : FilterQuality.medium,
        placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
        height: widget.height,
      );
    } else {
      return widget.language != null
        ? Center(child: Text(widget.se.seCards.readTitleOfCard(widget.language!, widget.idCard)))
        : const Icon(Icons.help_outline);
    }
  }
  @override
  Widget build(BuildContext context) {
    if(Environment.instance.isAdministrator()) {
      var img = widget.card.tryGetImage(widget.idImage);
      return Tooltip(
        message: img.finalImage.isNotEmpty ? img.finalImage : widget.cardImage.join("\n"),
        child: buildCachedImage(true)
      );
    } else {
      return buildCachedImage();
    }
  }
}