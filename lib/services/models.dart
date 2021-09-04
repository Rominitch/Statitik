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

import 'connection.dart';

const double iconSize = 25.0;

final Color greenValid = Colors.green[500]!;

class ByteParser
{
  int       pointer=0;
  List<int> byteArray;

  ByteParser(this.byteArray);
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

// Fr type / rarity
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
}

const List<Color> rarityColors =
[
  Colors.green, Colors.green, Color(0xFF43A047), Color(0xFF43A047), Color(0xFF388E3C), Color(0xFF388E3C),  // C JC P JU R JR
  Colors.blue, Color(0xFF1E88E5), Color(0xFF1E88E5), Color(0xFF1976D2), Color(0xFF1565C0),                  // H M JA P C
  Colors.purple, Colors.purple, Colors.purple, Color(0xFF8E24AA), Color(0xFF8E24AA), Color(0xFF7B1FA2), Color(0xFF6A1B9A), Color(0xFF6A1B9A),         // Ch JS T V JRR Vm JRRR PB
  Colors.yellow, Colors.yellow, Color(0xFFFDD835), Color(0xFFFDD835), Color(0xFFFBC02D), Color(0xFFFBC02D), Color(0xFFF9A825), Color(0xFFF9A825), Color(0xFFF9A825),           // ChR JSSR S JSR A JHR G HS JUR
  Colors.black // unknown
];

const List<Rarity> worldRarity = [Rarity.Commune, Rarity.PeuCommune, Rarity.Rare,
  Rarity.HoloRare, Rarity.Magnifique, Rarity.Prism, Rarity.Chromatique, Rarity.Turbo,
  Rarity.V, Rarity.VMax, Rarity.BrillantRare, Rarity.UltraRare,
  Rarity.ChromatiqueRare, Rarity.Secret, Rarity.ArcEnCiel, Rarity.Gold, Rarity.HoloRareSecret,
];
const List<Rarity> japanRarity = [Rarity.JC, Rarity.JU, Rarity.JR, Rarity.JRR,
  Rarity.JRRR, Rarity.JSR, Rarity.JHR, Rarity.JUR, Rarity.JA, Rarity.JS, Rarity.JSSR
];

const Map convertType =
{
  'P': Type.Plante,
  'R': Type.Feu,
  'E': Type.Eau,
  'W': Type.Electrique,
  'Y': Type.Psy,
  'C': Type.Combat,
  'O': Type.Obscurite,
  'M': Type.Metal,
  'I': Type.Incolore,
  'F': Type.Fee,
  'D': Type.Dragon,
  'o': Type.Objet,
  'd': Type.Supporter,
  's': Type.Stade,
  'e': Type.Energy,
};

const Map convertRarity =
{
  'c': Rarity.Commune,
  'p': Rarity.PeuCommune,
  'r': Rarity.Rare,
  'H': Rarity.HoloRare,
  'U': Rarity.UltraRare,
  'M': Rarity.Magnifique,
  'P': Rarity.Prism,
  'q': Rarity.Chromatique,
  'Q': Rarity.ChromatiqueRare,
  'T': Rarity.Turbo,
  'v': Rarity.V, // or GX /Ex
  'V': Rarity.VMax,
  'S': Rarity.Secret,
  'A': Rarity.ArcEnCiel,
  'G': Rarity.Gold,
  'B': Rarity.BrillantRare,
  'h': Rarity.HoloRareSecret,
  //Japon
  'C': Rarity.JC,
  '0': Rarity.JU,
  '1': Rarity.JR,
  '2': Rarity.JRR,
  '3': Rarity.JRRR,
  '4': Rarity.JSR,
  '5': Rarity.JHR,
  '6': Rarity.JUR,
  '7': Rarity.JA,
  '8': Rarity.JS,
  '9': Rarity.JSSR,
};

enum Mode {
  Normal,
  Reverse,
  Halo,
  Alternative,
}

const Map modeImgs   = {Mode.Normal: "normal", Mode.Reverse: "reverse", Mode.Halo: "halo", Mode.Alternative: 'alternative'};
const Map modeNames  = {Mode.Normal: "SET_0", Mode.Reverse: "SET_1", Mode.Halo: "SET_2", Mode.Alternative: 'Alternative'};
const Map modeColors = {Mode.Normal: Colors.green, Mode.Reverse: Colors.blueAccent, Mode.Halo: Colors.purple, Mode.Alternative: Colors.deepOrange};

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

String typeToString(Type type) {
  return convertType.keys.firstWhere(
          (k) => convertType[k] == type, orElse: () => emptyMode);
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

class PokeCard
{
  Type           type;
  Rarity         rarity;
  List<CardName> names = [];
  CardInfo       info = CardInfo();
  bool           hasAlternative;

  PokeCard({required this.type, required this.rarity, required this.hasAlternative});

  bool isValid() {
    return type!= Type.Unknown && rarity != Rarity.Unknown;
  }

  List<Widget> imageRarity() {
    return getImageRarity(rarity);
  }

  Widget imageType() {
    return getImageType(type);
  }

  bool hasAnotherRendering() {
    return !isValid() || rarity == Rarity.Commune || rarity == Rarity.PeuCommune || rarity == Rarity.Rare
        || rarity == Rarity.HoloRare;
  }

  Mode defaultMode() {
    return rarity == Rarity.HoloRare ? Mode.Halo : Mode.Normal;
  }

  int extractNameByte(int id, byteData) {
    assert(id+1 <= byteData.length);
    int nbNames = byteData[id];
    id += 1;
    for(var i=0; i < nbNames; i+=1) {
      assert(id+3 <= byteData.length);
      // Decode
      int codeName   = byteData[id] << 8 | byteData[id+1];
      int codeRegion = byteData[id+2];
      id += 3;

      // Build name
      CardName cname = CardName.from(codeRegion);
      if( codeName != 0 ) {
        if( codeName >= 10000 ) {
          cname.name = Environment.instance.collection.getNamedID(codeName);
        } else {
          cname.name = Environment.instance.collection.getPokemonID(codeName);
        }
      }
      names.add(cname);
    }
    return id;
  }

  List<int> nameByte() {
    List<int> b = [];

    // Clean invalid name
    names.removeWhere((element) => element.name==null);

    //2 Bytes
    b.add(names.length);
    for(var n in names) {
      int id=0;
      if (n.name.isPokemon()) {
        var rPokemon = Environment.instance.collection.pokemons.map((k, v) =>
            MapEntry(v, k));
        id = rPokemon[n.name];
      } else {
        var rOther = Environment.instance.collection.otherNames.map((k, v) =>
            MapEntry(v, k));
        id = rOther[n.name];
      }

      //2 Bytes
      b.add((id & 0xFF00) >> 8);
      b.add(id & 0xFF);
      b.add(n.toCode());
    }
    return b;
  }

  int extractInfoByte3(int id, byteData) {
    assert(id+3 <= byteData.length);

    List<int> fullcode =
    [
      0,
      ((byteData[id] << 8) | byteData[id+1]) << 8 | byteData[id+2]
    ];
    info = CardInfo.from(fullcode);
    return id + 3;
  }

  int extractInfoByte5(int id, byteData) {
    assert(id+5 <= byteData.length);

    List<int> fullcode =
    [
      byteData[id],
      ((byteData[id+1] << 8 | byteData[id+2]) << 8 | byteData[id+3]) << 8 | byteData[id+4]
    ];
    info = CardInfo.from(fullcode);
    return id + 5;
  }

  List<int> infoByte() {
    List<int> b = [];
    var i = info.toCode();

    assert(i[0] == 0); // Not reach
    //5 Bytes
    b.add(i[0] & 0xFF);

    //4 Bytes
    b.add((i[1] & 0xFF000000) >> 24);
    b.add((i[1] & 0xFF0000) >> 16);
    b.add((i[1] & 0xFF00) >> 8);
    b.add(i[1] & 0xFF);

    return b;
  }

  Widget? showImportantMarker(BuildContext context, {double? height}) {
    var importantMarkers = [CardMarker.Escouade, CardMarker.EX, CardMarker.GX, CardMarker.V, CardMarker.VMAX];
    for(var m in importantMarkers) {
      if(info.markers.contains(m)) {
        return pokeMarker(context, m, height: height);
      }
    }
    return null;
  }
}

class NamedInfo
{
  List<String> _names;
  NamedInfo(this._names){
    assert(_names.length == 3);
  }

  String fullname(Language l) {
    return name(l);
  }

  String defaultName() {
    return _names[0];
  }

  String name(Language l) {
    assert(0 <= l.id-1 && l.id-1 < _names.length);
    return _names[l.id-1];
  }

  bool isPokemon() {
    return false;
  }
}

class PokemonInfo extends NamedInfo
{
  int         generation;
  int         idPokedex;

  PokemonInfo({required List<String> names, required this.generation, required this.idPokedex}) :
  super(names)
  {
    assert(names.length == 3);
  }

  @override
  String fullname(Language l) {
    return name(l) + " - n°" + idPokedex.toString();
  }

  @override
  bool isPokemon() {
    return true;
  }
}

class ListCards
{
  List<PokeCard> cards = [];
  bool validCard = true;
  bool hasAdditionnalInfo = false;

  void extractCard(String? code)
  {
    cards.clear();
    validCard = true;

    if(code == null || code.isEmpty) {
      validCard=false;
      // Build pre-publication: 300 card max
      for (int i = 0; i < 300; i += 1) {
        cards.add(PokeCard(type: Type.Unknown, rarity: Rarity.Unknown, hasAlternative: true));
      }
    } else {
      assert(code.length % 2 != 1 || code.contains('*'));

      for (int i = 0; i < code.length; i += 2) {
        Type t   = Type.Unknown;
        Rarity r = Rarity.Unknown;
        if (!convertType.containsKey(code[i])) {
          if(local)
            throw Exception('Data card list corruption: $i was found with type ${code[i]}');
        } else {
          t = convertType[code[i]];
        }

        if (!convertRarity.containsKey(code[i+1])) {
          if (local)
            throw Exception('Data card list corruption: $i was found with rarity ${code[i + 1]}');
        } else {
          r = convertRarity[code[i + 1]];
        }

        //Special alternative case
        bool alternative = false;
        if((i + 2) < code.length && code[i + 2] == '*') {
          i += 1;
          alternative = true;
        }
        cards.add(PokeCard(type: t, rarity: r, hasAlternative: alternative));
      }
    }
  }

  String getName(Language l, int id) {
    if(id < cards.length ) {
      List<String> names = [];
      cards[id].names.forEach((element) {
        if(element.name != null) {
          names.add(element.name.name(l));
        }
      });
      return names.join("&");
    }
    return "";
  }
}

class CodeNaming
{
  int    idStart = 0;
  String naming = "%d";

  CodeNaming([this.idStart=0, this.naming="%d"]);
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

  void addBoosterDraw(List<List<int>> draw, List<int> energy , int anomaly) {
    if( draw.length > subExt.seCards.cards.length)
      throw StatitikException('Corruption des données de tirages');

    anomaly += anomaly;
    nbBoosters += 1;

    for(int energyI=0; energyI < energy.length; energyI +=1) {
      CodeDraw c = CodeDraw.fromInt(energy[energyI]);
      countEnergy[energyI] += c.count();
      // Energy can be reverse
      countByMode[Mode.Reverse.index] += c.countReverse;
      assert((c.countHalo + c.countAlternative) == 0);
    }

    for(int cardsId=0; cardsId < draw.length; cardsId +=1) {
      for(int card=0; card < draw[cardsId].length; card +=1) {
        CodeDraw c = CodeDraw.fromInt(draw[cardsId][card]);
        int nbCard = c.count();
        if( nbCard > 0 ) {
          cardByBooster += nbCard;
          if(subExt.seCards.isValid) {
            // Count
            countByType[subExt.seCards.cards[cardsId][card].data.type.index] += nbCard;
            countByRarity[subExt.seCards.cards[cardsId][card].rarity.index]  += nbCard;
          }
          totalCards           += nbCard;
          count[cardsId][card] += nbCard;
          countByMode[Mode.Normal.index]      += c.countNormal;
          countByMode[Mode.Reverse.index]     += c.countReverse;
          countByMode[Mode.Halo.index]        += c.countHalo;
          countByMode[Mode.Alternative.index] += c.countAlternative;
        }
      }
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

enum PokeRegion {
  Nothing,
  Kanto,
  Johto,
  Hoenn,
  Sinnoh,
  Unova,
  Kalos,
  Alola,
  Galar,
  //Limited 16 values (Number 1/2 byte)
}

const List<Color> regionColors = [
  Colors.white70, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
];

String regionName(BuildContext context, PokeRegion id) {
  return StatitikLocale.of(context).read('REG_${id.index}');
}

enum PokeSpecial {
  Nothing,
  FormeEau,
  FormeFeu,
  FormeFroid,
  FormePsy,
  Noir,
  Blanc
  //Limited 16 values (Number 1/2 byte)
}

String specialName(BuildContext context, PokeSpecial id) {
  return StatitikLocale.of(context).read('SPE_${id.index}');
}

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

class CardName {
  dynamic     name; // PokemonInfo or NamedInfo
  PokeRegion  region  = PokeRegion.Nothing;
  PokeSpecial special = PokeSpecial.Nothing;

  CardName([this.region = PokeRegion.Nothing, this.special = PokeSpecial.Nothing]);

  CardName.from(int code) {
    region  = PokeRegion.values[code & 0xF];
    special = PokeSpecial.values[(code>>4 & 0xF)];
  }

  int toCode() {
    return region.index + (special.index<<4);
  }
}

class CardInfo {
  List<CardMarker> markers = [];

  CardInfo([markers = const []]) : this.markers = List.from(markers);

  CardInfo.from(List<int> fullcode) {
    int id = 1;
    fullcode.reversed.forEach((code) {
    while(code > 0)
      {
        if((code & 0x1) == 0x1) {
          markers.add(CardMarker.values[id]);
        }
        id = id+1;
        code = code >> 1;
      }
    });
  }

  List<int> toCode() {
    List<int> codeMarkers = [0, 0];
    markers.forEach((element) {
      if(element != CardMarker.Nothing) {
        if(element.index < 32) {
          codeMarkers[1] |= (1<<(element.index-1));
        } else {
          codeMarkers[0] |= (1<<(element.index-32-1));
        }
      }
    });
    return codeMarkers;
  }
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

class CardResults {
  NamedInfo?  specificCard;
  CardMarkers filter = CardMarkers.from([]);
  Region?     filterRegion;
  CardStats?  stats;

  bool isSelected(PokemonCardExtension card){
    bool select = true;
    if(specificCard != null) {
      select = false;
      for(var n in card.data.title) {
        select |= (n.name == specificCard);
      }
    }
    if(select && filterRegion != null) {
      select = false;
      for(var n in card.data.title) {
        select |= (n.region == filterRegion);
      }
    }
    if(select && filter.markers.isNotEmpty) {
      select = false;
      filter.markers.forEach((marker) {
        select |= card.data.markers.markers.contains(marker);
      });
    }
    return select;
  }

  bool isSpecific() {
    return specificCard != null;
  }

  bool isFiltered() {
    return filter.markers.isNotEmpty || filterRegion != null;
  }

  bool hasStats() {
    return stats != null;
  }
}