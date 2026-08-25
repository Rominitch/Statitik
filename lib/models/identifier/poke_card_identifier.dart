
import 'package:flutter/foundation.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:statitikcard/models/poke_card_design.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeCardImageIdentifier {
  PokeSet set;
  int idImage;

  PokeCardImageIdentifier(this.set, [this.idImage=0]);

  @override
  String toString() {
    return "${set.pid().id()}_$idImage";
  }
}

class PokeCardIdentifier {
  final List<int> cardId;

  PokeCardIdentifier.from(this.cardId) {
    assert(cardId.length >= 2);
  }

  PokeCardIdentifier.copy(PokeCardIdentifier idCard) :
        cardId = List<int>.generate(idCard.cardId.length, (index) => idCard.cardId[index]){
    assert(cardId.length >= 2);
  }

  PokeCardIdentifier.fromBytes(BinaryReader reader) :
    cardId = [reader.readUint8(), reader.readUint16(), reader.readUint8()];

  PokeCardIdentifier.fromOldBytes(BinaryReader reader) :
        cardId = [reader.readUint8(), reader.tmpReadInt16BIG(), reader.readUint8()];

  int get alternativeId {
    assert(cardId.length >= 3);
    return cardId[2];
  }
  int get numberId {
    return cardId[1];
  }
  int get listId {
    return cardId[0];
  }

  @override
  String toString() {
    return cardId.join("_");
  }

  int compareTo(PokeCardIdentifier other) {
    var itOther = other.cardId.iterator;
    for(var element in cardId) {
      if(itOther.moveNext()) {
        var cmp = element.compareTo(itOther.current);
        if(cmp != 0) {
          return cmp;
        }
      }
    }
    return 0;
  }

  @override
  bool operator==(Object other)
  {
    if(other is PokeCardIdentifier) {
      return compareTo(other) == 0;
    }
    return false;
  }

  bool isEqual(PokeCardIdentifier other) => listEquals(cardId, other.cardId);

  void toBytes(BinaryWriter writer) {
    writer.writeUint8(listId);
    writer.writeUint16(numberId);
    writer.writeUint8(alternativeId);
  }

  PokeCardIdentifier changeNumber(int position) {
    var newId = List<int>.from(cardId, growable: false);
    newId[1] = position;
    return PokeCardIdentifier.from(newId);
  }

  @override
  int get hashCode {
    int code = cardId.length;
    int step = 8;
    for(int id in cardId) {
      code |= id << step;
      step += 8;
    }
    return code;
  }
}

class PokeCardViewerIdentifier {
  final PokeExpansion            expansion;
  final PokeCardIdentifier       idCard;
  final PokeLangage?             specificLanguage;

  PokeCardImageIdentifier?       idImage;

  PokeCardViewerIdentifier(this.expansion, this.idCard, {this.idImage, this.specificLanguage}) {
    idImage ??= PokeCardImageIdentifier(cardInExp().orderedSets().first);
  }

  List<PokeLangage> compatibleLanguage() {
    List<PokeLangage> allLanguage = [];
    for(final language in Environment.instance.pkCollection().languages()) {
      if (language.location() == expansion.location()) {
        allLanguage.add(language);
      }
    }
    return allLanguage;
  }

  PokeCardInExpansion cardInExp() {
    return expansion.cards.cardFromId(idCard);
  }

  String readTitleOfCard() {
    return expansion.cards.readTitleOfCard(specificLanguage!, idCard);
  }

  PokeCardDesign cardDesign() {
    return cardInExp().tryGetImage(idImage!);
  }

  List<Uri> computeImageURI(bool showTCGImages) {
    if(showTCGImages){
      final cardInExp = expansion.cards.cardFromId(idCard);
      final defaultImage = cardInExp.image(idImage!)!;
      final codeLangue = specificLanguage!.code();

      if(defaultImage.finalImage.isNotEmpty) {
        return [Uri.parse(defaultImage.finalImage)];
      }


      List<Uri> images = [];

      // Card Order:
      // - Official
      // - Mine
      // - Alternative

      // Mine
      var cardIdentifier = "${idCard.toString()}_${idImage.toString()}";
      var cardPath = "StatitikCard/card/${codeLangue}/${expansion.icon()}/$cardIdentifier";
      var formats = ["webp", "png", "jpg"];
      for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardPath.$ext"));}

      if(idCard.listId == 1) {
        var cardEnergyPath = "StatitikCard/card/${codeLangue}/E_${expansion.icon()}_${idCard.numberId+1}";
        for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardEnergyPath.$ext"));}
        var cardEnergy2Path = "StatitikCard/card/${codeLangue}/E_${defaultImage.cardImage}_${idCard.numberId+1}";
        for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardEnergy2Path.$ext"));}
      }
      if(idCard.listId == 2) {
        var cardNoNumberPath = "StatitikCard/card/${codeLangue}/$cardIdentifier";
        for (var ext in formats) { images.add(Uri(scheme: scheme, host:moucaServer, path: "$cardNoNumberPath.$ext"));}
      }

      //
      if( codeLangue == "FR" ) {
        if (defaultImage.cardImage.startsWith("https://")) {
          images += [Uri.parse(defaultImage.cardImage)];
        } else {
          int addAt = idCard.listId != 0 ? images.length : 0;
          for (var seFolder in expansion.codes()) {
            String tcgId = expansion.cards.tcgImage(idCard.numberId);
            // Official image source
            if (idCard.listId == 1) {
              images.insert(addAt, Uri.https("assets.pokemon.com",
                  "assets/cms2-fr-fr/img/cards/web/NRG/NRG_FR_${defaultImage
                      .cardImage}.png"));
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
                  "assets/images/sets_fr/${seFolder.toUpperCase()}/HD/${idCard
                      .numberId + 1}.jpg"),
              Uri.https("www.pokecardex.com",
                  "assets/images/sets/${seFolder.toUpperCase()}/HD/${idCard
                      .numberId + 1}.jpg"),
            ];
          }
        }
      } else if( codeLangue == "EN" ) {
        if (defaultImage.cardImage.startsWith("https://")) {
          images += [Uri.parse(defaultImage.cardImage)];
        } else {
          int addAt = idCard.listId != 0 ? images.length : 0;
          if (idCard.listId == 1) {
            images.insert(addAt, Uri.https("assets.pokemon.com",
                "assets/cms2/img/cards/web/NRG/NRG_EN_${defaultImage
                    .cardImage}.png"));
          }

          // Official image source
          for (var seFolder in expansion.codes()) {
            images.insert(addAt, Uri.https("assets.pokemon.com",
                "assets/cms2/img/cards/web/$seFolder/${seFolder}_EN_${expansion.cards
                    .tcgImage(idCard.numberId)}.png"));
          }
        }
      } else if( codeLangue == "JP" ) {
        if(defaultImage.cardImage.startsWith("https://")) {
          images += [Uri.parse(defaultImage.cardImage)];
        } else {
          var romajiNames = [
            defaultImage.cardImage.isEmpty ? computeJPPokemonName()     : defaultImage.cardImage,
            defaultImage.cardImage.isEmpty ? computeJPPokemonName(true) : defaultImage.cardImage,
          ];

          String codeType = "P";
          if(cardInExp.card.type == TypeCard.supporter || cardInExp.card.type == TypeCard.stade || cardInExp.card.type == TypeCard.objet) {
            codeType = "T";
          } else if(cardInExp.card.type == TypeCard.energy) {
            codeType = "E";
          }
          String codeImage = defaultImage.jpDBId.toString().padLeft(6, '0');

          for( var romajiName in romajiNames )
          {
            if( idCard.listId == 1 ) {
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large/ENE/${codeImage}_${codeType}_$romajiName.jpg"));
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large//${codeImage}_${codeType}_$romajiName.jpg"));
            }

            for (var seFolder in expansion.codes()) {
              // Official image source
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large/$seFolder/${codeImage}_${codeType}_${romajiName}_m.jpg"));
              images.insert(0, Uri.https("www.pokemon-card.com", "assets/images/card_images/large/$seFolder/${codeImage}_${codeType}_$romajiName.jpg"));
              // Reliable alternative source
              images.add(Uri.https("www.pokecardex.com", "assets/images/sets_jp/${seFolder.toUpperCase()}/HD/${expansion.cards.tcgImage(idCard.numberId)}.jpg"));
            }
          }
        }
      }
      return images;
    }
    return [Uri()];
  }

  String computeJPPokemonName([bool alternative=false]) {
    final myCardInExp = cardInExp();
    String romajiName = "";
    try {
      romajiName = convertRomaji(myCardInExp.card.titleOfCard(specificLanguage!), alternative);

      myCardInExp.card.markers.markers().firstWhere((element) {
        if(element.toTitle()) {
          romajiName += element.titleName();
        }
        return element.toTitle();
      });
    } catch(_) {}
    return romajiName;
  }

  String convertRomaji(String name, bool alternative) {
    final collection = Environment.instance.pkCollection();
    const kanaKit = KanaKit();
    var val = "";
    try {
      // Remove no translate symbol
      val = name.replaceAll("ー", ""); // ー is not translated

      for(var key in collection.orderedKanji.reversed) {
        var value = collection.convertKanji[key]!;
        val = val.replaceAll(key, value);
      }
      if( alternative ) {
        val = val.replaceAll("ッチ", "TCHI");
        val = val.replaceAll("ャ", "XYA");
        val = val.replaceAll("ュ", "XYU");
        val = val.replaceAll("ョ", "XYO");
        val = val.replaceAll("ゃ", "XYA");
        val = val.replaceAll("ゅ", "XYU");
        val = val.replaceAll("ょ", "XYO");
        val = val.replaceAll("ファ", "FUA");
        val = val.replaceAll("フィ", "FUI");
      }

      // Convert kana
      val = kanaKit.copyWithConfig(upcaseKatakana: true).toRomaji(val);
      val = val.toUpperCase();

      // Finish by clean converter
      for(var key in collection.orderedKanji.reversed) {
        var value = collection.convertKanji[key]!;
        val = val.replaceAll(key, value);
      }
    } catch(_) {}
    return val;
  }
}