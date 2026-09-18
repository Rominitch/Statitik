
import 'package:statitikcard/models/draw/poke_expansion_draw.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/type_card.dart';

class PokeStatsBooster {
  final PokeExpansion expansion;
  int nbBoosters = 0;
  int cardByBooster = 0;
  int anomaly = 0;
  late List<List<int>> count;   /// Card count into extension list
  int totalCards = 0;

  // Cached
  late List<int>            countByType;
  late Map<PokeRarity, int> countByRarity;
  late Map<PokeSet,int>     countBySet;
  late List<int>            countEnergy;

  late Map<PokeSet, Map<PokeRarity, int>> countBySetByRarity;

  PokeStatsBooster({required this.expansion}) {
    count         = List<List<int>>.generate(expansion.cards.cards.length, (id) {
      return List<int>.filled(expansion.cards.cards[id].length, 0);
    });
    countByType   = List<int>.filled(TypeCard.values.length, 0);
    countByRarity = {};
    countBySet    = {};
    countEnergy   = List<int>.filled(expansion.cards.energyCard.length, 0);
    countBySetByRarity = {};
  }

  bool hasEnergy() {
    for(int e in countEnergy ) {
      if(e > 0) {
        return true;
      }
    }
    return false;
  }

  void addBoosterDraw(PokeExpansionDraw edc, int anomaly) {
    if( edc.drawCards.length > expansion.cards.cards.length) {
      throw StatitikException(ErrorCode.unknown, 'Corruption des données de tirages');
    }

    computeStatsBySet(PokeCardInExpansion cardInfo, PokeCardDraw code) {
      for(final set in cardInfo.setInfo.keys) {
        var countSet = code.countBySet(set);
        if(countBySet.containsKey(set)) {
          countBySet[set] = countBySet[set]! + countSet;
        } else {
          countBySet[set] = countSet;}

        if(!countBySetByRarity.containsKey(set)) {
          countBySetByRarity[set] = {};
        }
        if(!countBySetByRarity[set]!.containsKey(cardInfo.rarity)) {
          countBySetByRarity[set]![cardInfo.rarity] = countSet;
        } else {
          countBySetByRarity[set]![cardInfo.rarity] = countBySetByRarity[set]![cardInfo.rarity]! + countSet;
        }
      }
    }

    anomaly += anomaly;
    nbBoosters += 1;

    assert(countEnergy.length == expansion.cards.energyCard.length);
    assert(countEnergy.length >= edc.drawEnergies.length);

    var idEnergy = 0;
    var energyCard = expansion.cards.energyCard.iterator;
    for (var code in edc.drawEnergies) {
      if(energyCard.moveNext()) {
        var count = code.count();
        if(count > 0) {
          var cardInfo = energyCard.current;
          countEnergy[idEnergy]                 += count;
          countByType[cardInfo.card.type.index] += count;

          if(countByRarity.containsKey(cardInfo.rarity)) {
            countByRarity[cardInfo.rarity] = countByRarity[cardInfo.rarity]! + count;
          } else {
            countByRarity[cardInfo.rarity] = count;
          }
          // Energy can be reversed
          computeStatsBySet(cardInfo, code);
        }
      }
      idEnergy += 1;
    }

    var noNumberCards = expansion.cards.noNumberedCard.iterator;
    for (var code in edc.drawNoNumber) {
      if(noNumberCards.moveNext()) {
        var count = code.count();
        if(count > 0) {
          var cardInfo = noNumberCards.current;
          countByType[cardInfo.card.type.index] += count;

          if(countByRarity.containsKey(cardInfo.rarity)) {
            countByRarity[cardInfo.rarity] = countByRarity[cardInfo.rarity]! + count;
          } else {
            countByRarity[cardInfo.rarity] = count;
          }
          // No Number can be reversed
          computeStatsBySet(cardInfo, code);
        }
      }
    }

    int cardsId=0;
    for(List<PokeCardDraw> cards in edc.drawCards) {
      int cardId=0;
      for(final code in cards) {
        int nbCard = code.count();
        if( nbCard > 0 ) {
          cardByBooster += nbCard;
          if(expansion.cards.isValid()) {
            var cardInfo = expansion.cards.cards[cardsId][cardId];
            // Count
            countByType[cardInfo.card.type.index] += nbCard;
            if(countByRarity.containsKey(cardInfo.rarity)) {
              countByRarity[cardInfo.rarity] = countByRarity[cardInfo.rarity]! + nbCard;
            } else {
              countByRarity[cardInfo.rarity] = nbCard;
            }

            computeStatsBySet(cardInfo, code);
          } else {
            for(final set in code.data().keys) {
              final countSet = code.countBySet(set);
              if(countBySet.containsKey(set)) {
                countBySet[set] = countBySet[set]! + countSet;
              } else {
                countBySet[set] = countSet;
              }
            }
          }
          totalCards             += nbCard;
          count[cardsId][cardId] += nbCard;
        }
        cardId += 1;
      }
      cardsId += 1;
    }
  }
}