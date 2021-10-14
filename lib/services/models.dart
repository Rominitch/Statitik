import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/pokemonCard.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

const double iconSize = 25.0;

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

class ByteParser
{
  List<int> byteArray;
  Iterator<int>  it;
  late bool canParse;

  ByteParser(this.byteArray) : it = byteArray.iterator {
    canParse = it.moveNext();
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
}

class UserPoke {
  int idDB;
  late String uid;
  bool admin = false;

  UserPoke({required this.idDB});
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
}

class Extension
{
  int      id;
  String   name;
  Language language;

  Extension(this.id, this.name, this.language);
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

// Fr type / rarity -> NEVER CHANGED ORDER
enum Type {
  Plante,
  Feu,
  Eau,
  Electrique,
  Psy,
  Combat,
  Obscurite,
  Metal,
  Fee,
  Dragon,
  Incolore,
  Objet,
  Supporter,
  Stade,
  Energy,
  Unknown,
}
const List<Type> orderedType = const[
  Type.Unknown, Type.Plante, Type.Feu, Type.Eau, Type.Electrique, Type.Psy, Type.Combat, Type.Obscurite, Type.Metal, Type.Fee,
  Type.Dragon, Type.Incolore, Type.Objet, Type.Supporter, Type.Stade, Type.Energy,
];

// NEVER CHANGED ORDER
enum Rarity {
  Commune,
  JC,
  PeuCommune,
  JU,
  Rare,
  JR,
  HoloRare,
  Magnifique,
  JA,
  Prism,
  Chromatique,
  JS,
  Turbo,
  V, // or GX /Ex
  JRR,
  VMax,
  JRRR,
  BrillantRare, //PB
  UltraRare,
  ChromatiqueRare,
  JSSR,
  Secret,
  JSR,
  ArcEnCiel,
  JHR,
  Gold,
  HoloRareSecret,
  JUR,
  Unknown,
  Empty,
  JCHR,
}

const List<Rarity> orderedRarity = const[
  Rarity.Empty, Rarity.Unknown,
  Rarity.Commune, Rarity.JC, Rarity.PeuCommune, Rarity.JU, Rarity.Rare, Rarity.JR,
  Rarity.HoloRare, Rarity.Magnifique, Rarity.JA, Rarity.Prism,
  Rarity.Chromatique,  Rarity.JS,  Rarity.Turbo,  Rarity.V, // or GX /Ex
  Rarity.JRR,  Rarity.VMax,  Rarity.JRRR,  Rarity.BrillantRare, //PB
  Rarity.UltraRare,  Rarity.ChromatiqueRare,  Rarity.JSSR,  Rarity.Secret, Rarity.JCHR,
  Rarity.JSR,  Rarity.ArcEnCiel,  Rarity.JHR,  Rarity.Gold,  Rarity.HoloRareSecret,  Rarity.JUR,
];

bool isPokemonType(type) {
  return type != Type.Energy
      && type != Type.Objet
      && type != Type.Supporter
      && type != Type.Stade;
}

const List<Color> rarityColors =
[
  Colors.green, Colors.green, Color(0xFF43A047), Color(0xFF43A047), Color(0xFF388E3C), Color(0xFF388E3C),  // C JC P JU R JR
  Colors.blue, Color(0xFF1E88E5), Color(0xFF1E88E5), Color(0xFF1976D2), Color(0xFF1565C0),                  // H M JA P C
  Colors.purple, Colors.purple, Colors.purple, Color(0xFF8E24AA), Color(0xFF8E24AA), Color(0xFF7B1FA2), Color(0xFF6A1B9A), Color(0xFF6A1B9A),         // Ch JS T V JRR Vm JRRR PB
  Colors.yellow, Colors.yellow, Color(0xFFFDD835), Color(0xFFFDD835), Color(0xFFFBC02D), Color(0xFFFBC02D), Color(0xFFF9A825), Color(0xFFF9A825), Color(0xFFF9A825),           // ChR JSSR S JSR A JHR G HS JUR
  Colors.black, Colors.green, // unknown, Empty
  Color(0xFFFDD835),
];

const List<Rarity> worldRarity = [Rarity.Empty, Rarity.Commune, Rarity.PeuCommune, Rarity.Rare,
  Rarity.HoloRare, Rarity.Magnifique, Rarity.Prism, Rarity.Chromatique, Rarity.Turbo,
  Rarity.V, Rarity.VMax, Rarity.BrillantRare, Rarity.UltraRare,
  Rarity.ChromatiqueRare, Rarity.Secret, Rarity.ArcEnCiel, Rarity.Gold, Rarity.HoloRareSecret
];
const List<Rarity> japanRarity = [Rarity.Empty, Rarity.JC, Rarity.JU, Rarity.JR, Rarity.JRR,
  Rarity.JRRR, Rarity.JSR, Rarity.JHR, Rarity.JUR, Rarity.JCHR, Rarity.JA, Rarity.JS, Rarity.JSSR
];

const List<Rarity> goodCard = [
  Rarity.HoloRare,
  Rarity.Magnifique,
  Rarity.JA,
  Rarity.Prism,
  Rarity.Chromatique,
  Rarity.JS,
  Rarity.Turbo,
  Rarity.V,
  Rarity.JRR,
  Rarity.VMax,
  Rarity.JRRR,
  Rarity.BrillantRare,
  Rarity.UltraRare,
  Rarity.ChromatiqueRare,
  Rarity.JSSR,
  Rarity.Secret,
  Rarity.JSR,
  Rarity.ArcEnCiel,
  Rarity.JHR,
  Rarity.Gold,
  Rarity.HoloRareSecret,
  Rarity.JUR,
  Rarity.JCHR,
];

enum Mode {
  Normal,
  Reverse,
  Halo,
}

const Map modeImgs   = {Mode.Normal: "normal", Mode.Reverse: "reverse", Mode.Halo: "halo", };
const Map modeNames  = {Mode.Normal: "SET_0", Mode.Reverse: "SET_1", Mode.Halo: "SET_2"};
const Map modeColors = {Mode.Normal: Colors.green, Mode.Reverse: Colors.blueAccent, Mode.Halo: Colors.purple};

const String emptyMode = '_';

const Map imageName = {
  Type.Plante: 'plante',
  Type.Feu: 'feu',
  Type.Eau: 'eau',
  Type.Electrique: 'electrique',
  Type.Psy: 'psy',
  Type.Combat: 'combat',
  Type.Obscurite: 'obscure',
  Type.Metal: 'metal',
  Type.Incolore: 'incolore',
  Type.Fee: 'fee',
  Type.Dragon: 'dragon',
};

const List<Type> energies = [Type.Plante,  Type.Feu,  Type.Eau,
  Type.Electrique,  Type.Psy,  Type.Combat,  Type.Obscurite,
  Type.Metal, Type.Fee,  Type.Dragon, Type.Incolore];

const List<Color> energiesColors = [Colors.green, Colors.red, Colors.blue,
  Colors.yellow, Color(0xFF8E24AA), Color(0xFFD84315), Color(0xFF311B92),
  Color(0xFF7D7D7D),  Colors.pinkAccent, Colors.orange, Colors.white70,
];

const List<Color> generationColor = [
  Colors.black, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
];

List<Color> typeColors = energiesColors + [Color(0xFF1976D2), Color(0xFFC62828), Color(0xFFB9F6CA), Color(0xFFFFFF8D), Colors.black];

List<Widget?> cachedEnergies = List.filled(energies.length, null);

Widget energyImage(Type type) {
  assert (type != Type.Unknown);
  if(cachedEnergies[type.index] == null) {
    if (imageName[type].isNotEmpty) {
      cachedEnergies[type.index] = Image(
        image: AssetImage('assets/energie/${imageName[type]}.png'),
        width: iconSize,
      );
    }
  }
  return cachedEnergies[type.index]!;
}

List<List<Widget>?> cachedImageRarity = List.filled(Rarity.values.length, null);

List<Widget> getImageRarity(Rarity rarity, {fontSize=12.0, generate=false}) {
  if(generate || cachedImageRarity[rarity.index] == null) {
    List<Widget> rendering;
    //star_border
    switch(rarity) {
      case Rarity.Commune:
        rendering = [Icon(Icons.circle)];
        break;
      case Rarity.PeuCommune:
        rendering = [Transform.rotate(
            angle: pi / 4.0,
            child: Icon(Icons.stop))];
        break;
      case Rarity.Rare:
        rendering = [Icon(Icons.star)];
        break;
      case Rarity.Prism:
        rendering = [Icon(Icons.star), Text('P', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Chromatique:
        rendering = [Icon(Icons.star), Text('CH', style: TextStyle(fontSize: fontSize-2.0))];
        break;
      case Rarity.ChromatiqueRare:
        rendering = [Icon(Icons.star_border), Text('CH', style: TextStyle(fontSize: fontSize-2.0))];
        break;
      case Rarity.V:
        rendering = [Icon(Icons.star_border)];
        break;
      case Rarity.VMax:
        rendering = [Icon(Icons.star), Text('X', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Turbo:
        rendering = [Icon(Icons.star), Text('T', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.HoloRare:
        rendering = [Icon(Icons.star), Text('H', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.BrillantRare:
        rendering = [Icon(Icons.star), Text('PB', style: TextStyle(fontSize: fontSize-2.0))];
        break;
      case Rarity.UltraRare:
        rendering = [Icon(Icons.star), Text('U', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Magnifique:
        rendering = [Icon(Icons.star), Text('M', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Secret:
        rendering = [Icon(Icons.star_border), Text('S', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.HoloRareSecret:
        rendering = [Icon(Icons.star_border), Text('H', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.ArcEnCiel:
        rendering = [Icon(Icons.looks)];
        break;
      case Rarity.Gold:
        rendering = [Icon(Icons.local_play, color: Colors.yellow[300])];
        break;
      case Rarity.Unknown:
        rendering = [Icon(Icons.help_outline)];
        break;

      case Rarity.JC:
        rendering = [Text('C', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JU:
        rendering = [Text('U', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JR:
        rendering = [Text('R', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JRR:
        rendering = [Text('RR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JRRR:
        rendering = [Text('RRR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JSR:
        rendering = [Text('SR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JHR:
        rendering = [Text('HR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JUR:
        rendering = [Text('UR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JA:
        rendering = [drawCachedImage('logo', 'a', height: 20)];
        break;
      case Rarity.JS:
        rendering = [Text('S', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JSSR:
        rendering = [Text('SSR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JCHR:
        rendering = [Text('CHR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Empty:
        rendering = [Text('')];
      break;
      default:
        throw Exception("Unknown rarity: $rarity");
    }
    if(generate)
      return rendering;
    else
      cachedImageRarity[rarity.index] = rendering;
  }
  return cachedImageRarity[rarity.index]!;
}

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

List<Widget?> cachedImageType = List.filled(Type.values.length, null);

Widget getImageType(Type type)
{
  if(cachedImageType[type.index] == null) {
    switch(type) {
      case Type.Objet:
        cachedImageType[type.index] = Icon(Icons.build, color: Colors.blueAccent,);
        break;
      case Type.Stade:
        cachedImageType[type.index] = Icon(Icons.landscape, color: Colors.green[700]);
        break;
      case Type.Supporter:
        cachedImageType[type.index] = Icon(Icons.accessibility_new, color: Colors.red[900]);
        break;
      case Type.Energy:
        cachedImageType[type.index] = Icon(Icons.battery_charging_full);
        break;
      case Type.Unknown:
        cachedImageType[type.index] = Icon(Icons.help_outline);
        break;
      default:
        cachedImageType[type.index] = energyImage(type);
    }
  }
  return cachedImageType[type.index]!;
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
  int               id;           ///< ID into database
  String            name;         ///< Name of extension (translate)
  String            icon;         ///< Path to extension's icon
  DateTime          out;
  SubExtensionCards seCards;
  Extension         extension;

  SubExtension(this.id, this.name, this.icon, this.extension, this.out, this.seCards);

  /// Show Extension image
  Widget image({double? wSize, double? hSize}) {
    return drawCachedImage('extensions', icon, width: wSize, height: hSize);
  }

  /// Get formated release date of product
  String outDate() {
    return DateFormat('yyyyMMdd').format(out);
  }
}

class ProductBooster
{
  int nbBoosters;
  int nbCardsPerBooster;

  ProductBooster({required this.nbBoosters, required this.nbCardsPerBooster});
}

class Product
{
  int idDB;
  String name;
  String imageURL;
  Map<int, ProductBooster> boosters;
  Color color;
  int count;

  Product({required this.idDB, required this.name, required this.imageURL, required this.count, required this.boosters, required this.color});

  bool hasImages() {
    return imageURL.isNotEmpty;
  }

  CachedNetworkImage image()
  {
    return drawCachedImage('products', imageURL, height: 70);
  }

  int countBoosters() {
    int count=0;
    boosters.forEach((key, value) { count += value.nbBoosters; });
    return count;
  }

  List<BoosterDraw> buildBoosterDraw() {
    var list = <BoosterDraw>[];
    int id=1;
    boosters.forEach((key, value) {
      for( int i=0; i < value.nbBoosters; i+=1) {
        SubExtension? se = Environment.instance.collection.subExtensions[key];
        list.add(new BoosterDraw(creation: se, id: id, nbCards: value.nbCardsPerBooster));
        id += 1;
      }
    });
    return list;
  }

  int countProduct() {
    return count;
  }
}

class Stats {
  final SubExtension subExt;
  int nbBoosters = 0;
  int cardByBooster = 0;
  int anomaly = 0;
  late List<List<int>> count;
  int totalCards = 0;

  // Cached
  late List<int> countByType;
  late List<int> countByRarity;
  late List<int> countByMode;

  late List<int> countEnergy;

  Stats({required this.subExt}) {
    count         = List<List<int>>.generate(subExt.seCards.cards.length, (id) {
      return List<int>.filled(subExt.seCards.cards[id].length, 0);
    });
    countByType   = List<int>.filled(Type.values.length, 0);
    countByRarity = List<int>.filled(Rarity.values.length, 0);
    countByMode   = List<int>.filled(Mode.values.length, 0);
    countEnergy   = List<int>.filled(energies.length, 0);
  }

  bool hasEnergy() {
    for(int e in countEnergy ) {
      if(e > 0)
        return true;
    }
    return false;
  }

  void addBoosterDraw(ExtensionDrawCards edc, List<int> energy , int anomaly) {
    if( edc.draw.length > subExt.seCards.cards.length)
      throw StatitikException('Corruption des données de tirages');

    anomaly += anomaly;
    nbBoosters += 1;

    for(int energyI=0; energyI < energy.length; energyI +=1) {
      CodeDraw c = CodeDraw.fromInt(energy[energyI]);
      countEnergy[energyI] += c.count();
      // Energy can be reverse
      countByMode[Mode.Reverse.index] += c.countReverse;
      assert((c.countHalo) == 0);
    }

    int cardsId=0;
    for(List<CodeDraw> cards in edc.draw) {
      int cardId=0;
      for(CodeDraw card in cards) {
        int nbCard = card.count();
        if( nbCard > 0 ) {
          cardByBooster += nbCard;
          if(subExt.seCards.isValid) {
            // Count
            countByType[subExt.seCards.cards[cardsId][cardId].data.type.index] += nbCard;
            countByRarity[subExt.seCards.cards[cardsId][cardId].rarity.index]  += nbCard;
          }
          totalCards             += nbCard;
          count[cardsId][cardId] += nbCard;
          countByMode[Mode.Normal.index]      += card.countNormal;
          countByMode[Mode.Reverse.index]     += card.countReverse;
          countByMode[Mode.Halo.index]        += card.countHalo;
        }
        cardId += 1;
      }
      cardsId += 1;
    }
  }
}

class StatsExtension {
  final SubExtension subExt;

  late List<int> countByType;
  late List<int> countByRarity;

  StatsExtension({required this.subExt}) {
    countByType   = List<int>.filled(Type.values.length, 0);
    countByRarity = List<int>.filled(Rarity.values.length, 0);

    subExt.seCards.cards.forEach((cards) {
      cards.forEach((c) {
        countByType[c.data.type.index] += 1;
        countByRarity[c.rarity.index]  += 1;
      });
    });
  }
}

class SessionDraw
{
  Language language;
  Product product;
  bool productAnomaly=false;
  List<BoosterDraw> boosterDraws;

  SessionDraw({required this.product, required this.language}):
        boosterDraws = product.buildBoosterDraw();

  void closeStream() {
    boosterDraws.forEach((booster) {
      booster.closeStream();
    });
  }

  void addNewBooster() {
    BoosterDraw booster = boosterDraws.last;

    boosterDraws.add(new BoosterDraw(creation: booster.subExtension, id: booster.id+1, nbCards: booster.nbCards) );
  }

  void deleteBooster(int id) {
    if( id >= boosterDraws.length || id < 0 )
      throw StatitikException("Impossible de trouver le booster $id");
    // Delete
    boosterDraws.removeAt(id);
    // Change Label ID
    id = 1;
    boosterDraws.forEach((BoosterDraw element) {element.id = id; id += 1; });
  }

  bool canDelete() {
    return boosterDraws.length > 1;
  }

  void revertAnomaly()
  {
    //Brutal reset
    boosterDraws = product.buildBoosterDraw();
    productAnomaly = false;
  }

  bool needReset() {
    bool editedBooster = false;
    for(BoosterDraw b in boosterDraws){
      if(b.creation != null && b.creation != b.subExtension)
        editedBooster |= true;
    }

    return editedBooster || boosterDraws.length != product.countBoosters();
  }
}

class StatsData {
  Language?         language;
  SubExtension?     subExt;
  Product?          product;
  int               category = -1;
  Stats?            stats;
  Stats?            userStats;
  CardResults       cardStats = CardResults();

  bool isValid() {
    return language != null && subExt != null && stats != null;
  }
}

const List<Color> regionColors = [
  Colors.white70, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
];

enum CardMarker {
  Nothing,
  Escouade,
  V,
  VMAX,
  GX,
  MillePoint,
  PointFinal,
  Turbo,
  EX,
  Mega,
  Legende,
  Restaure,
  Ultra,
  UltraChimere,
  Talent,
  PrismStar,
  Fusion,
  OutilsPokemon,
  Primal,
  TeamPlasma,
  TeamFlare,
  PlusDelta,
  EvolutionDelta,
  BarriereOmega,
  OffensiveOmega,
  CroissanceAlpha,
  RegenerationAlpha,
  CapSpe,
  PokePower,
  PokeBody,
  TeamGalaxy,
  PokemonChampion,
  SP,
  Yon,
  EspeceDelta,
  TeamRocket,
  //First Limited 24 values (Bit 3 bytes)
  //Limited 40 values (Bit 5 bytes)
}

const List<Color> markerColors = [
  Colors.white70, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal,
  Colors.indigo, Colors.deepOrange, Colors.lime, Colors.purpleAccent,
  Colors.greenAccent, Colors.blueGrey, Colors.deepPurple, Colors.pinkAccent,
  Colors.lightBlue, Colors.black26, Colors.redAccent, Colors.redAccent,
  Color(0xFF558B2F),Color(0xFF558B2F), Color(0xFFB71C1C), Color(0xFFB71C1C),
  Color(0xFF0D47A1), Color(0xFF0D47A1), Colors.redAccent, Color(0xFFB71C1C),
  Color(0xFF558B2F), Colors.amber, Colors.brown, Colors.deepPurpleAccent,
  Colors.teal, Colors.lightGreen, Colors.deepPurpleAccent,
];

const List longMarker = [CardMarker.Escouade, CardMarker.UltraChimere, CardMarker.Talent, CardMarker.MillePoint, CardMarker.PointFinal, CardMarker.Fusion];

List<Widget?> cachedMarkers = List.filled(CardMarker.values.length, null);
Widget pokeMarker(BuildContext context, CardMarker marker, {double? height=15.0}) {
  if( cachedMarkers[marker.index] == null ) {
    switch(marker) {
      case CardMarker.Escouade:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'escouade', height: height);
      break;
      case CardMarker.V:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'v', height: height);
        break;
      case CardMarker.VMAX:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'vmax', height: height);
        break;
      case CardMarker.GX:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'gx', height: height);
        break;
      case CardMarker.MillePoint:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'millepoint', height: height);
        break;
      case CardMarker.PointFinal:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'pointfinal', height: height);
        break;
      case CardMarker.Turbo:
        var newheight = (height != null) ? height-7 : null;
        cachedMarkers[marker.index] = drawCachedImage('logo', 'turbo', height: newheight);
        break;
      case CardMarker.EX:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'ex', height: height);
        break;
      case CardMarker.Legende:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_0'), style: TextStyle(fontSize: 9));
        break;
      case CardMarker.Restaure:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_1'), style: TextStyle(fontSize: 9));
        break;
      case CardMarker.Mega:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_2'), style: TextStyle(fontSize: 12));
        break;
      case CardMarker.Ultra:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_3'), style: TextStyle(fontSize: 12));
        break;
      case CardMarker.UltraChimere:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'ultra-chimere', height: height);
        break;
      case CardMarker.Talent:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'talent', height: height);
        break;
      case CardMarker.PrismStar:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'prismstar', height: height);
        break;
      case CardMarker.Fusion:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'fusion', height: height);
        break;
      case CardMarker.OutilsPokemon:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_4'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.Primal:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_5'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.TeamFlare:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_6'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.PlusDelta:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_7'), style: TextStyle(fontSize: 8, color: Color(0xFF1B5E20)));
        break;
      case CardMarker.EvolutionDelta:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_8'), style: TextStyle(fontSize: 8, color: Color(0xFF1B5E20)));
        break;
      case CardMarker.BarriereOmega:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_9'), style: TextStyle(fontSize: 8, color: Color(0xFFB71C1C)));
        break;
      case CardMarker.OffensiveOmega:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_10'), style: TextStyle(fontSize: 8, color: Color(0xFFB71C1C)));
        break;
      case CardMarker.CroissanceAlpha:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_11'), style: TextStyle(fontSize: 8, color: Color(0xFF0D47A1)));
        break;
      case CardMarker.RegenerationAlpha:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_12'), style: TextStyle(fontSize: 8, color: Color(0xFF0D47A1)));
        break;
      case CardMarker.TeamPlasma:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_13'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.CapSpe:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_14'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.PokePower:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_15'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.PokeBody:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_16'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.TeamGalaxy:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'teamGalaxy', height: height);
        break;
      case CardMarker.PokemonChampion:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'pokeChampion', height: height);
        break;
      case CardMarker.SP:
        cachedMarkers[marker.index] = drawCachedImage('logo', 'SP', height: height);
        break;
      case CardMarker.Yon:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_17'), style: TextStyle(fontSize: 20));
        break;
      case CardMarker.EspeceDelta:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_18'), style: TextStyle(fontSize: 8));
        break;
      case CardMarker.TeamRocket:
        cachedMarkers[marker.index] = Text(StatitikLocale.of(context).read('MARK_19'), style: TextStyle(fontSize: 8));
        break;
      default:
        cachedMarkers[marker.index] = Icon(Icons.help_outline);
    }
  }
  return cachedMarkers[marker.index]!;
}

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
  Map<Type, int>               countType   = {};

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
  List<Type>      types    = [];
  List<Rarity>    rarities = [];

  MultiLanguageString? effectName;

  // Attack
  Type?           attackType   = Type.Unknown;
  RangeValues     attackEnergy = defaultEnergyAttack;
  RangeValues     attackPower  = defaultAttack;
  List<DescriptionEffect> effects = [];

  // Pokémon card
  RangeValues     life           = defaultLife;
  Type            weaknessType   = Type.Unknown;
  RangeValues     weakness       = defaultWeakness;
  Type            resistanceType = Type.Unknown;
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
      select = life.start <= card.data.life.toDouble() && card.data.life.toDouble() <= life.end;
    }
    if(select && (resistance != defaultResistance || resistanceType != Type.Unknown)) {
      select = card.data.resistance != null;
      if(select) {
        var res = card.data.resistance!;
        if(resistanceType != Type.Unknown)
          select = res.energy == resistanceType;
        if(select && resistance != defaultResistance)
          select = resistance.start <= res.value.toDouble() && res.value.toDouble() <= resistance.end;
      }
    }
    if(select && (weakness != defaultWeakness || weaknessType != Type.Unknown)) {
      select = card.data.weakness != null;
      if(select) {
        var weak = card.data.weakness!;
        if(weaknessType != Type.Unknown)
          select = weak.energy == weaknessType;
        if(select && weakness != defaultWeakness)
          select = weakness.start <= weak.value.toDouble() && weak.value.toDouble() <= weakness.end;
      }
    }

    if(select && hasAttackFilter()) {
      List<TriState> count = List.filled(4, TriState());
      List<bool> checkDescriptions = List.filled(effects.length, false);

      if(card.data.cardEffects.effects.isNotEmpty) {


        // Parse each effect to find filter item at least one time.
        card.data.cardEffects.effects.forEach((effect) {
          if(attackType != Type.Unknown)
            count[0].set(effect.attack.contains(attackType));
          if(select && attackEnergy != defaultEnergyAttack)
            count[1].set(attackEnergy.start <= effect.power.toDouble() && effect.power.toDouble() <= attackEnergy.end);
          if(select && attackPower != defaultAttack)
            count[2].set(attackPower.start <= effect.power.toDouble() && effect.power.toDouble() <= attackPower.end);
          if(select && effects.isNotEmpty) {
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
        });

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
    return weaknessType != Type.Unknown
        || weakness != defaultWeakness;
  }

  bool hasResistanceFilter() {
    return resistanceType != Type.Unknown
        || resistance != defaultResistance;
  }

  bool hasGeneralityFilter() {
    return hasWeaknessFilter()
    || hasResistanceFilter()
    || life != defaultLife;
  }

  void clearGeneralityFilter() {
    life           = defaultLife;
    weaknessType   = Type.Unknown;
    weakness       = defaultWeakness;
    resistanceType = Type.Unknown;
    resistance     = defaultResistance;
  }

  bool hasAttackFilter() {
    return attackType != Type.Unknown
        || attackEnergy != defaultEnergyAttack
        || attackPower != defaultAttack
        || effects.isNotEmpty;
  }

  void clearAttackFilter() {
    attackType   = Type.Unknown;
    attackEnergy  = defaultEnergyAttack;
    attackPower  = defaultAttack;
    effects.clear();
  }
}