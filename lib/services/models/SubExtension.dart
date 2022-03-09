import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class SubExtension
{
  int                 id;           ///< ID into database
  String              name;         ///< Name of extension (translate)
  String              icon;         ///< Path to extension's icon (on Statitik card folder)
  List<String>        seCode;       ///< Official Se code + others (use into web folder and other stuff)
  DateTime            out;
  SubExtensionCards   seCards;
  Extension           extension;
  SerieType           type;
  int                 cardPerBooster;
  late StatsExtension stats;

  SubExtension(this.id, this.name, this.icon, this.extension, this.out, this.seCards, this.type, this.seCode, this.cardPerBooster)
  {
    computeStats();
  }

  void computeStats() {
    stats = StatsExtension.from(this);
  }

  /// Show Extension image
  Widget image({double? wSize, double? hSize}) {
    return drawCachedImage('extensions', icon, width: wSize, height: hSize);
  }

  /// Get formated release date of product
  String outDate() {
    return DateFormat('yyyyMMdd').format(out);
  }

  PokemonCardExtension cardFromId(List<int> cardId) {
    assert(cardId.length >= 2);
    switch(cardId[0]){
      case 0: {
        assert(cardId.length == 3);
        return seCards.cards[cardId[1]][cardId[2]];
      }
      case 1: {
        return seCards.energyCard[cardId[1]];
      }
      case 2: {
        return seCards.noNumberedCard[cardId[1]];
      }
      default:
        throw StatitikException("Unknown list");
    }
  }

  Widget cardInfo(List<int> cardId) {
    assert(cardId.length >= 2);
    var card = cardFromId(cardId);

    switch(cardId[0]){
      case 0: {
        assert(cardId.length == 3);
        var label = seCards.numberOfCard(cardId[1]);
        return Text(label, style: TextStyle(fontSize: label.length > 3 ? 10 : 12));
      }
      case 1: {
        return card.imageTypeExtended() ?? card.imageType();
      }
      case 2: {
        return Text(card.numberOfCard(cardId[1]));
      }
      default:
        throw StatitikException("Unknown list");
    }
  }
}

class StatsExtension {
  late List<Rarity>       rarities;
  late List<CardSet>      allSets;

  late List<int>          countByType;
  late Map<Rarity, int>   countByRarity;
  late Map<CardSet, int>  countBySet;
  late int                countSecret;

  StatsExtension.from(SubExtension subExt) {
    countByType   = List<int>.filled(TypeCard.values.length, 0);
    countByRarity = {};
    rarities      = [];
    allSets       = [];
    countBySet    = {};
    countSecret   = 0;

    subExt.seCards.cards.forEach((cards) {
      cards.forEach((c) {
        c.sets.forEach((element) {
          if(!allSets.contains(element)) {
            allSets.add(element);
            countBySet[element] = 1;
          } else {
            countBySet[element] = countBySet[element]! + 1;
          }
        });

        if(c.isSecret)
          countSecret += 1;

        countByType[c.data.type.index] += 1;
        if(countByRarity.containsKey(c.rarity))
          countByRarity[c.rarity] = countByRarity[c.rarity]! + 1;
        else
          countByRarity[c.rarity] = 1;

        if(!rarities.contains(c.rarity))
          rarities.add(c.rarity);
      });
    });
  }

  int countAllCards() {
    int count = 0;
    countBySet.forEach((key, value) {
      count += value;
    });
    return count;
  }
}