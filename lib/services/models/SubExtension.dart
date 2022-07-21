import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/SubExtensionCards.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

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

  PokemonCardExtension cardFromId(CardIdentifier cardId) {
    switch(cardId.listId){
      case 0: {
        return seCards.cards[cardId.numberId][cardId.alternativeId];
      }
      case 1: {
        return seCards.energyCard[cardId.numberId];
      }
      case 2: {
        return seCards.noNumberedCard[cardId.numberId];
      }
      default:
        throw StatitikException("Unknown list");
    }
  }

  Widget cardInfo(CardIdentifier cardId) {
    var card = cardFromId(cardId);
    switch(cardId.listId){
      case 0: {
        var label = seCards.numberOfCard(cardId.numberId);
        return Text(label, style: TextStyle(fontSize: label.length > 3 ? 10 : 12));
      }
      case 1: {
        return card.imageTypeExtended() ?? card.imageType();
      }
      case 2: {
        return Text(card.numberOfCard(cardId.numberId));
      }
      default:
        throw StatitikException("Unknown list");
    }
  }
}

class StatsExtension {
  late List<Rarity>         rarities;
  late List<CardSet>        allSets;
  late Map<CardSet, List<Rarity>> allRarityPerSets;

  late List<int>          countByType;
  late Map<Rarity, int>   countByRarity;
  late Map<CardSet, int>  countBySet;
  late int                countSecret;
  late Map<CardSet, Map<Rarity, int>> countBySetByRarity;
  late int                countOneCards;

  StatsExtension.from(SubExtension subExt) {
    countByType   = List<int>.filled(TypeCard.values.length, 0);
    countByRarity = {};
    rarities      = [];
    allSets       = [];
    countBySet    = {};
    countSecret   = 0;
    allRarityPerSets = {};
    countBySetByRarity = {};

    var computeStatsByCard = (PokemonCardExtension c) {
      c.sets.forEach((element) {
        if(!allSets.contains(element)) {
          allSets.add(element);
          allRarityPerSets[element] = [c.rarity];
          countBySetByRarity[element] = {};
          countBySetByRarity[element]![c.rarity] = 1;
          countBySet[element] = 1;
        } else {
          countBySet[element] = countBySet[element]! + 1;
          if(!allRarityPerSets[element]!.contains(c.rarity)) {
            allRarityPerSets[element]!.add(c.rarity);
          }
          if(!countBySetByRarity[element]!.containsKey(c.rarity)) {
            countBySetByRarity[element]![c.rarity] = 1;
          } else {
            countBySetByRarity[element]![c.rarity] =  countBySetByRarity[element]![c.rarity]! + 1;
          }
        }
      });

      if(c.isSecret) {
        countSecret += 1;
      }

      countByType[c.data.type.index] += 1;
      if(countByRarity.containsKey(c.rarity)) {
        countByRarity[c.rarity] = countByRarity[c.rarity]! + 1;
      } else {
        countByRarity[c.rarity] = 1;
      }

      if(!rarities.contains(c.rarity)) {
        rarities.add(c.rarity);
      }

    };

    subExt.seCards.cards.forEach((cards) {
      cards.forEach((c) {
        computeStatsByCard(c);
      });
    });
    subExt.seCards.energyCard.forEach((c) {
      computeStatsByCard(c);
    });
    subExt.seCards.noNumberedCard.forEach((c) {
      computeStatsByCard(c);
    });

    countOneCards = subExt.seCards.cards.length + subExt.seCards.energyCard.length + subExt.seCards.noNumberedCard.length;
  }

  int countAllCards() {
    int count = 0;
    countBySet.forEach((key, value) {
      count += value;
    });
    return count;
  }
}