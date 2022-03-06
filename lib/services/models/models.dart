import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/Rarity.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/pokemonCard.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
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

class ByteEncoder
{
  static List<int> encodeInt32(int value) {
    return <int>[
      (value & 0xFF000000) >> 24,
      (value & 0xFF0000) >> 16,
      (value & 0xFF00) >> 8,
      (value & 0xFF)
    ];
  }

  static List<int> encodeInt8(int value) {
    assert(value < 256);
    return <int>[
      (value & 0xFF)
    ];
  }

  static List<int> encodeInt16(int value) {
    assert(value < 65536);
    return <int>[
      (value & 0xFF00) >> 8,
      (value & 0xFF)
    ];
  }

  static List<int> encodeString16(List<int> stringInfo) {
    assert(stringInfo.length * 2 <= 255);
    var imageCode = <int>[
      stringInfo.length * 2, // Not more than 256
    ];
    stringInfo.forEach((element) {
      assert(element < 65536);
      imageCode += ByteEncoder.encodeInt16(element);
    });
    assert(imageCode[0] == imageCode.length-1);
    return imageCode;
  }

  static List<int> encodeBytesArray(List<int> byteArray) {
    assert(byteArray.length < 65536);
    return encodeInt16(byteArray.length) + byteArray;
  }

  static List<int> encodeBool(bool value) {
    return <int>[value ? 1 : 0];
  }
}

class ByteParser
{
  List<int> byteArray;
  Iterator<int>  it;
  late bool canParse;

  ByteParser(this.byteArray) : it = byteArray.iterator {
    canParse = it.moveNext();
  }

  String decodeString16() {
    List<int> charCodes = [];
    int length = extractInt8();
    assert(length % 2 == 0);
    for(int i = 0; i < length/2; i +=1) {
      charCodes.add(extractInt16());
    }
    return String.fromCharCodes(charCodes);
  }

  int extractInt32() {
    int v = it.current << 24;
    canParse = it.moveNext();
    v |= it.current << 16;
    canParse = it.moveNext();
    v |= it.current << 8;
    canParse = it.moveNext();
    v |= it.current;
    canParse = it.moveNext();
    return v;
  }
  int extractInt16() {
    int v = it.current << 8;
    canParse = it.moveNext();
    v |= it.current;
    canParse = it.moveNext();
    return v;
  }
  int extractInt8() {
    int v = it.current;
    canParse = it.moveNext();
    return v;
  }

  bool extractBool() {
    int v = it.current;
    canParse = it.moveNext();
    return v != 0;
  }

  List<int> extractBytesArray() {
    int nbItems = extractInt16();
    List<int> extract = [];
    for(int i = 0 ; i < nbItems; i +=1) {
      extract.add(extractInt8());
    }
    return extract;
  }
}

class UserPoke {
  int       idDB;
  String    uid       = "";
  bool      admin     = false;
  PokeSpace pokeSpace = PokeSpace();

  UserPoke(this.idDB);
}

class Language
{
  int id;
  String image;

  Language({required this.id, required this.image});

  AssetImage create()
  {
    return AssetImage('assets/langue/$image.png');
  }

  Image barIcon() {
    return Image(
    image: create(),
    height: AppBar().preferredSize.height * 0.4,
    );
  }

  bool isWorld() {
    return id != 3;
  }

  bool isJapanese() {
    return id == 3;
  }
}

class Extension
{
  int      id;
  String   name;
  Language language;

  Extension(this.id, this.name, this.language);
}

enum SerieType {
  Normal,
  Promo,
  Deck,
}
const List<String> seTypeString = ['SE_TYPE_0', 'SE_TYPE_1', 'SE_TYPE_2'];

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

class MultiLanguageString {
  List<String> _names;

  MultiLanguageString(this._names){
    assert(_names.length == 3, "MultiLanguageString Error: $_names");
  }

  String defaultName([separator='\n']) {
    return _names.join(separator);
  }

  String name(Language l) {
    assert(0 <= l.id-1 && l.id-1 < _names.length);
    return _names[l.id-1];
  }

  bool search(Language? l, String searchPart) {
    if(l != null) {
      return name(l).toLowerCase().contains(searchPart.toLowerCase());
    } else {
      for( var name in _names) {
        if( name.toLowerCase().contains(searchPart.toLowerCase()))
          return true;
      }
      return false;
    }
  }
}

class CardTitleData
{
  MultiLanguageString _names;

  CardTitleData(this._names);

  String fullname(Language l) {
    return _names.name(l);
  }

  String defaultName([separator='\n']) {
    return _names.defaultName(separator);
  }

  String name(Language l) {
    return _names.name(l);
  }

  bool isPokemon() {
    return false;
  }

  bool search(Language? l, String searchPart) {
    return _names.search(l, searchPart);
  }
}

class PokemonInfo extends CardTitleData
{
  int         generation;
  int         idPokedex;

  PokemonInfo(MultiLanguageString names, this.generation, this.idPokedex) :
  super(names);

  @override
  String fullname(Language l) {
    return name(l) + " - n°" + idPokedex.toString();
  }

  @override
  bool isPokemon() {
    return true;
  }
}

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

  StatsBooster({required this.subExt}) {
    count         = List<List<int>>.generate(subExt.seCards.cards.length, (id) {
      return List<int>.filled(subExt.seCards.cards[id].length, 0);
    });
    countByType   = List<int>.filled(TypeCard.values.length, 0);
    countByRarity = {};
    countBySet    = {};
    countEnergy   = List<int>.filled(subExt.seCards.energyCard.length, 0);
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

    anomaly += anomaly;
    nbBoosters += 1;

    assert(countEnergy.length == subExt.seCards.energyCard.length);
    assert(countEnergy.length >= edc.drawEnergies.length);

    var idEnergy = 0;
    var energyCard = subExt.seCards.energyCard.iterator;
    edc.drawEnergies.forEach((code) {
      if(energyCard.moveNext()) {
        var count = code.count();
        countEnergy[idEnergy]                           += count;
        countByType[energyCard.current.data.type.index] += count;

        // Energy can be reversed
        int setId=0;
        code.countBySet.forEach((element) {
          var setCard = energyCard.current.sets[setId];
          if(countBySet.containsKey(setCard))
            countBySet[setCard] = countBySet[setCard]! + element;
          else
            countBySet[setCard] = element;

          setId += 1;
        });
      }
      idEnergy += 1;
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

            var setInfo = cardInfo.sets.iterator;
            code.countBySet.forEach((countPerSet) {
              if(setInfo.moveNext()) {
                if(countBySet.containsKey(setInfo.current))
                  countBySet[setInfo.current] = countBySet[setInfo.current]! + countPerSet;
                else
                  countBySet[setInfo.current] = countPerSet;
              }
            });
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

class StatsExtension {
  final SubExtension      subExt;

  late List<Rarity>       rarities;
  late List<CardSet>      allSets;

  late List<int>          countByType;
  late Map<Rarity, int>   countByRarity;
  late Map<CardSet, int>  countBySet;
  late int                countSecret;

  StatsExtension.from(this.subExt) {
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
  Map<SubExtension, List<int>> countSubExtension = {};
  Map<CardMarker, int>         countMarker = {};
  Map<Rarity, int>             countRarity = {};
  Map<TypeCard, int>           countType   = {};

  bool hasData() {
    return countSubExtension.isNotEmpty;
  }

  int nbCards() {
    return count;
  }

  void add(SubExtension se, PokemonCardExtension card, int idCard) {
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