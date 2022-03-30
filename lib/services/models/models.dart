import 'dart:core';
import 'package:flutter/material.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/CardTitleData.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

final Color greenValid = Colors.green[500]!;

const int minLife = 0;
const int maxLife = 400;

const int minAttackPower = 0;
const int maxAttackPower = 400;

const int minAttackEnergy = 0;
const int maxAttackEnergy = 5;

const int minRetreat = 0;
const int maxRetreat = 5;

const int minResistance = 0;
const int maxResistance = 60;

const int minWeakness = 0;
const int maxWeakness = 5;

class UserPoke {
  int       idDB;
  String    uid       = "";
  bool      admin     = false;
  PokeSpace pokeSpace = PokeSpace();

  UserPoke(this.idDB);
}


enum Validator {
  Valid,
  ErrorReverse,
  ErrorEnergy,
  ErrorTooManyGood,
}

enum Level {
  Base,
  Level1,
  Level2,
}

const List<String> levelString = ['LEVEL_0', 'LEVEL_1', 'LEVEL_2'];
String getLevelText(context, Level element) {
  return StatitikLocale.of(context).read(levelString[element.index]);
}



/*
enum Mode {
  Normal,
  Reverse,
  Halo,
}

const Map modeImgs   = {Mode.Normal: "normal", Mode.Reverse: "reverse", Mode.Halo: "halo", };
const Map modeNames  = {Mode.Normal: "SET_0", Mode.Reverse: "SET_1", Mode.Halo: "SET_2"};
const Map modeColors = {Mode.Normal: Colors.green, Mode.Reverse: Colors.blueAccent, Mode.Halo: Colors.purple};

const String emptyMode = '_';
*/


enum DescriptionEffect {
  Unknown,          // 0
  Attack,           // 1
  Draw,             // 2
  FlipCoin,         // 4
  Poison,           // 8
  Burn,             // 16
  Sleep,            // 32
  Paralyzed,        // 64
  Search,           // 128
  Heal,             // 256
  Mix,              // 512
  Confusion,        // 1024
}

String labelDescriptionEffect(BuildContext context, DescriptionEffect de) {
  return StatitikLocale.of(context).read("STATE_${de.index}");
}

Widget getDescriptionEffectWidget(DescriptionEffect de, {size}) {
  switch(de) {
    case DescriptionEffect.Attack:
      return Icon(StatitikFont.font_09_attack, size: size);
    case DescriptionEffect.Draw:
      return Icon(StatitikFont.font_02_pioche, size: size);
    case DescriptionEffect.FlipCoin:
      return Icon(StatitikFont.font_03_coin, size: size);
    case DescriptionEffect.Poison:
      return Icon(StatitikFont.font_05_poison, size: size);
    case DescriptionEffect.Burn:
      return Icon(StatitikFont.font_04_burn, size: size);
    case DescriptionEffect.Sleep:
      return Icon(StatitikFont.font_07_sleep, size: size);
    case DescriptionEffect.Paralyzed:
      return Icon(StatitikFont.font_06_paralized, size: size);
    case DescriptionEffect.Search:
      return Icon(StatitikFont.font_08_search, size: size);
    case DescriptionEffect.Heal:
      return Icon(StatitikFont.font_12_heal, size: size);
    case DescriptionEffect.Mix:
      return Icon(StatitikFont.font_10_mix, size: size);
    case DescriptionEffect.Confusion:
      return Icon(StatitikFont.font_11_confusion, size: size);
    default:
      return Icon(Icons.help_outline, size: size);
  }
}

class StatsBooster {
  final SubExtension subExt;
  int nbBoosters = 0;
  int cardByBooster = 0;
  int anomaly = 0;
  late List<List<int>> count;   /// Card count into extension list
  int totalCards = 0;

  // Cached
  late List<int>        countByType;
  late Map<Rarity, int> countByRarity;
  late Map<CardSet,int> countBySet;
  late List<int>        countEnergy;

  late Map<CardSet, Map<Rarity, int>> countBySetByRarity;

  StatsBooster({required this.subExt}) {
    count         = List<List<int>>.generate(subExt.seCards.cards.length, (id) {
      return List<int>.filled(subExt.seCards.cards[id].length, 0);
    });
    countByType   = List<int>.filled(TypeCard.values.length, 0);
    countByRarity = {};
    countBySet    = {};
    countEnergy   = List<int>.filled(subExt.seCards.energyCard.length, 0);
    countBySetByRarity = {};
  }

  bool hasEnergy() {
    for(int e in countEnergy ) {
      if(e > 0)
        return true;
    }
    return false;
  }

  void addBoosterDraw(ExtensionDrawCards edc, int anomaly) {
    if( edc.drawCards.length > subExt.seCards.cards.length)
      throw StatitikException('Corruption des données de tirages');

    var computeStatsBySet = (cardInfo, CodeDraw code) {
      int setId=0;
      code.countBySet.forEach((element) {
        var setCard = cardInfo.sets[setId];
        if(countBySet.containsKey(setCard))
          countBySet[setCard] = countBySet[setCard]! + element;
        else
          countBySet[setCard] = element;

        if(!countBySetByRarity.containsKey(setCard))
          countBySetByRarity[setCard] = {};

        if(!countBySetByRarity[setCard]!.containsKey(cardInfo.rarity))
          countBySetByRarity[setCard]![cardInfo.rarity] = element;
        else
          countBySetByRarity[setCard]![cardInfo.rarity] = countBySetByRarity[setCard]![cardInfo.rarity]! + element;

        setId += 1;
      });
    };

    anomaly += anomaly;
    nbBoosters += 1;

    assert(countEnergy.length == subExt.seCards.energyCard.length);
    assert(countEnergy.length >= edc.drawEnergies.length);

    var idEnergy = 0;
    var energyCard = subExt.seCards.energyCard.iterator;
    edc.drawEnergies.forEach((code) {
      if(energyCard.moveNext()) {
        var count = code.count();
        if(count > 0) {
          var cardInfo = energyCard.current;
          countEnergy[idEnergy]                 += count;
          countByType[cardInfo.data.type.index] += count;

          if(countByRarity.containsKey(cardInfo.rarity))
            countByRarity[cardInfo.rarity] = countByRarity[cardInfo.rarity]! + count;
          else
            countByRarity[cardInfo.rarity] = count;

          // Energy can be reversed
          computeStatsBySet(cardInfo, code);
        }
      }
      idEnergy += 1;
    });

    var noNumberCards = subExt.seCards.noNumberedCard.iterator;
    edc.drawNoNumber.forEach((code) {
      if(noNumberCards.moveNext()) {
        var count = code.count();
        if(count > 0) {
          var cardInfo = noNumberCards.current;
          countByType[cardInfo.data.type.index] += count;

          if(countByRarity.containsKey(cardInfo.rarity))
            countByRarity[cardInfo.rarity] = countByRarity[cardInfo.rarity]! + count;
          else
            countByRarity[cardInfo.rarity] = count;

          // No Number can be reversed
          computeStatsBySet(cardInfo, code);
        }
      }
    });

    int cardsId=0;
    for(List<CodeDraw> cards in edc.drawCards) {
      int cardId=0;
      for(CodeDraw code in cards) {
        int nbCard = code.count();
        if( nbCard > 0 ) {
          cardByBooster += nbCard;
          if(subExt.seCards.isValid) {
            var cardInfo = subExt.seCards.cards[cardsId][cardId];
            // Count
            countByType[cardInfo.data.type.index] += nbCard;
            if(countByRarity.containsKey(cardInfo.rarity))
              countByRarity[cardInfo.rarity] = countByRarity[cardInfo.rarity]! + nbCard;
            else
              countByRarity[cardInfo.rarity] = nbCard;

            computeStatsBySet(cardInfo, code);
          } else {
            int setId=0;
            code.countBySet.forEach((element) {
              var setCard = Environment.instance.collection.sets[setId];
              if(countBySet.containsKey(setCard))
                countBySet[setCard] = countBySet[setCard]! + element;
              else
                countBySet[setCard] = element;

              setId += 1;
            });
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

class StatsData {
  Language?         language;
  SubExtension?     subExt;
  ProductRequested? pr;
  ProductCategory?  category;
  StatsBooster?     stats;
  StatsBooster?     userStats;
  CardResults       cardStats = CardResults();

  bool isValid() {
    return language != null && subExt != null && stats != null;
  }
}

const List<Color> regionColors = [
  Colors.white70, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
];

class CodeNaming
{
  int    idStart = 0;
  String naming = "%d";

  CodeNaming([this.idStart=0, this.naming="%s"]);
}

class CardStats {
  int count = 0;
  Map<Region, int>             countRegion = {};
  Map<SubExtension, List<CardIdentifier>> countSubExtension = {};
  Map<CardMarker, int>         countMarker = {};
  Map<Rarity, int>             countRarity = {};
  Map<TypeCard, int>           countType   = {};

  bool hasData() {
    return countSubExtension.isNotEmpty;
  }

  int nbCards() {
    return count;
  }

  void add(SubExtension se, PokemonCardExtension card, CardIdentifier idCard) {
    count += 1;

    var d = card.data;
    for(var pokemon in d.title) {
      if(pokemon.region != null) {
        countRegion[pokemon.region!] = countRegion[pokemon.region!] != null ? countRegion[pokemon.region!]! + 1 : 1;
      }
    }
    countRarity[card.rarity] = countRarity[card.rarity] != null ? countRarity[card.rarity]! + 1 : 1;
    countType[d.type]        = countType[d.type]        != null ? countType[d.type]!        + 1 : 1;
    if(countSubExtension[se] != null) {
      countSubExtension[se]!.add(idCard);
    } else {
      countSubExtension[se] = [idCard];
    }
    d.markers.markers.forEach((marker) {
      countMarker[marker] = countMarker[marker] != null ? countMarker[marker]! + 1 : 1;
    });
  }
}

class TriState {
  bool? value;

  void set(bool v) {
    if(value==null)
      value = v;
    else
      value = value! | v;
  }
  bool isCheck() {
    if( value == null)
      return true;
    return value!;
  }
}

class CardResults {
  static RangeValues defaultLife       = RangeValues(minLife.toDouble(), maxLife.toDouble());
  static RangeValues defaultWeakness   = RangeValues(minWeakness.toDouble(), maxWeakness.toDouble());
  static RangeValues defaultResistance = RangeValues(minResistance.toDouble(), maxResistance.toDouble());
  static RangeValues defaultAttack     = RangeValues(minAttackPower.toDouble(), maxAttackPower.toDouble());
  static RangeValues defaultEnergyAttack = RangeValues(minAttackEnergy.toDouble(), maxAttackEnergy.toDouble());

  CardTitleData?  specificCard;
  CardMarkers     filter = CardMarkers();
  Region?         filterRegion;
  CardStats?      stats;
  List<TypeCard>  types    = [];
  List<Rarity>    rarities = [];

  MultiLanguageString? effectName;

  // Attack
  TypeCard?       attackType   = TypeCard.Unknown;
  RangeValues     attackEnergy = defaultEnergyAttack;
  RangeValues     attackPower  = defaultAttack;
  List<DescriptionEffect> effects = [];

  // Pokémon card
  RangeValues     life           = defaultLife;
  TypeCard        weaknessType   = TypeCard.Unknown;
  RangeValues     weakness       = defaultWeakness;
  TypeCard        resistanceType = TypeCard.Unknown;
  RangeValues     resistance     = defaultResistance;

  bool isSelected(PokemonCardExtension card){
    bool select = true;
    if(specificCard != null) {
      select = false;
      for(var n in card.data.title) {
        select |= (n.name == specificCard);
      }
    }
    if(select && hasRegionFilter()) {
      select = false;
      for(var n in card.data.title) {
        select |= (n.region == filterRegion);
      }
    }
    if(select && hasMarkersFilter()) {
      select = false;
      filter.markers.forEach((marker) {
        select |= card.data.markers.markers.contains(marker);
      });
    }
    if(select && types.isNotEmpty) {
      select = types.contains(card.data.type);
    }
    if(select && rarities.isNotEmpty) {
      select = rarities.contains(card.rarity);
    }
    if(select && life != defaultLife) {
      select = life.start.round() <= card.data.life && card.data.life <= life.end.round();
    }
    if(select && (resistance != defaultResistance || resistanceType != TypeCard.Unknown)) {
      select = card.data.resistance != null;
      if(select) {
        var res = card.data.resistance!;
        if(resistanceType != TypeCard.Unknown)
          select = res.energy == resistanceType;
        if(select && resistance != defaultResistance)
          select = resistance.start.round() <= res.value && res.value <= resistance.end.round();
      }
    }
    if(select && (weakness != defaultWeakness || weaknessType != TypeCard.Unknown)) {
      select = card.data.weakness != null;
      if(select) {
        var weak = card.data.weakness!;
        if(weaknessType != TypeCard.Unknown)
          select = weak.energy == weaknessType;
        if(select && weakness != defaultWeakness)
          select = weakness.start.round() <= weak.value && weak.value <= weakness.end.round();
      }
    }

    if(select && hasAttackFilter()) {
      List<TriState> count = List.filled(4, TriState());
      List<bool> checkDescriptions = List.filled(effects.length, false);

      if(card.data.cardEffects.effects.isNotEmpty) {
        // Parse each effect to find filter item at least one time.
        //card.data.cardEffects.effects.forEach((effect) {
        for(var effect in card.data.cardEffects.effects) {
          if(attackType != TypeCard.Unknown)
            count[0].set(effect.attack.contains(attackType));
          if(attackEnergy != defaultEnergyAttack) {
            var attackCount = effect.attack.length;
            count[1].set(attackEnergy.start.round() <= attackCount && attackCount <= attackEnergy.end.round());
          }
          if(attackPower != defaultAttack)
            count[2].set(attackPower.start.round() <= effect.power && effect.power <= attackPower.end.round());
          if(effects.isNotEmpty) {
            if(effect.description != null) {
              // Check we find at least each effect demanded (on the card).
              int idDes = 0;
              for (var e in effects) {
                checkDescriptions[idDes] |=
                    effect.description!.effects.contains(e);
                idDes += 1;
              }
              // Compile all result
              bool allCheck = true;
              checkDescriptions.forEach((element) {
                allCheck &= element;
              });
              count[3].set(allCheck);
            } else {
              count[3].set(false);
            }
          }
        }
        //});

        // Compile final result
        select = true;
        for(var value in count) {
          select &= value.isCheck();
        }
      } else select = false;
    }
    return select;
  }

  bool isSpecific() {
    return specificCard != null;
  }

  bool isFiltered() {
    return hasMarkersFilter() || hasRegionFilter()
    || hasTypeRarityFilter() || hasGeneralityFilter()
    || hasAttackFilter();
  }

  bool hasStats() {
    return stats != null;
  }

  bool hasRegionFilter() {
    return filterRegion != null;
  }
  void clearRegionFilter() {
    filterRegion = null;
  }
  bool hasTypeRarityFilter() {
    return types.isNotEmpty || rarities.isNotEmpty;
  }
  void clearTypeRarityFilter() {
    types.clear();
    rarities.clear();
  }
  bool hasMarkersFilter() {
    return filter.markers.isNotEmpty;
  }
  void clearMarkersFilter() {
    filter.markers.clear();
  }

  bool hasWeaknessFilter() {
    return weaknessType != TypeCard.Unknown
        || weakness != defaultWeakness;
  }

  bool hasResistanceFilter() {
    return resistanceType != TypeCard.Unknown
        || resistance != defaultResistance;
  }

  bool hasGeneralityFilter() {
    return hasWeaknessFilter()
    || hasResistanceFilter()
    || life != defaultLife;
  }

  void clearGeneralityFilter() {
    life           = defaultLife;
    weaknessType   = TypeCard.Unknown;
    weakness       = defaultWeakness;
    resistanceType = TypeCard.Unknown;
    resistance     = defaultResistance;
  }

  bool hasAttackFilter() {
    return attackType != TypeCard.Unknown
        || attackEnergy != defaultEnergyAttack
        || attackPower != defaultAttack
        || effects.isNotEmpty;
  }

  void clearAttackFilter() {
    attackType   = TypeCard.Unknown;
    attackEnergy  = defaultEnergyAttack;
    attackPower  = defaultAttack;
    effects.clear();
  }
}