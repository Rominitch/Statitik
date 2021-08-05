import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

const double iconSize = 25.0;

final Color greenValid = Colors.green[500]!;

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
  int    id;
  String name;
  int    idLanguage;

  Extension({ required this.id, required this.name, required this.idLanguage });
}

enum Validator {
  Valid,
  ErrorReverse,
  ErrorEnergy,
  ErrorTooManyGood,
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
  Prism,
  Chromatique,
  Turbo,
  V, // or GX /Ex
  JRR,
  VMax,
  JRRR,
  BrillantRare, //PB
  UltraRare,
  ChromatiqueRare,
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
  // Green Green[600] Green[700]
  Colors.green, Colors.green, Color(0xFF43A047), Color(0xFF43A047), Color(0xFF388E3C), Color(0xFF388E3C),  // C JC P JU R JR
  // Blue Blue[600] Blue[700] Blue[800]
  Colors.blue, Color(0xFF1E88E5), Color(0xFF1976D2), Color(0xFF1565C0),                  // H M P C
  //purple 600 700 800
  Colors.purple, Colors.purple, Color(0xFF8E24AA), Color(0xFF8E24AA), Color(0xFF7B1FA2), Color(0xFF6A1B9A), Color(0xFF6A1B9A),         // Ch T V JRR Vm JRRR PB
  // Yellow 600 700 800
  Colors.yellow, Color(0xFFFDD835), Color(0xFFFDD835), Color(0xFFFBC02D), Color(0xFFFBC02D), Color(0xFFF9A825), Color(0xFFF9A825), Color(0xFFF9A825),           // ChR S JSR A JHR G HS JUR
  Colors.black // unknown
];

const List<Rarity> worldRarity = [Rarity.Commune, Rarity.PeuCommune, Rarity.Rare,
  Rarity.HoloRare, Rarity.Magnifique, Rarity.Prism, Rarity.Chromatique, Rarity.Turbo,
  Rarity.V, Rarity.VMax, Rarity.BrillantRare, Rarity.UltraRare,
  Rarity.ChromatiqueRare, Rarity.Secret, Rarity.ArcEnCiel, Rarity.Gold, Rarity.HoloRareSecret,
];
const List<Rarity> japanRarity = [Rarity.JC, Rarity.JU, Rarity.JR, Rarity.JRR,
  Rarity.JRRR, Rarity.JSR, Rarity.JHR, Rarity.JUR
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
  '6': Rarity.JUR
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
  Color(0xFFBDBDBD),  Colors.pinkAccent, Colors.orange, Colors.white70,
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
        rendering = [SizedBox(width: 4), Text('C', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JU:
        rendering = [SizedBox(width: 4), Text('U', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JR:
        rendering = [SizedBox(width: 4), Text('R', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JRR:
        rendering = [SizedBox(width: 4), Text('RR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JRRR:
        rendering = [SizedBox(width: 4), Text('RRR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JSR:
        rendering = [SizedBox(width: 4), Text('SR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JHR:
        rendering = [SizedBox(width: 4), Text('HR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JUR:
        rendering = [SizedBox(width: 4), Text('UR', style: TextStyle(fontSize: fontSize))];
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
    assert(id+4 <= byteData.length);
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

  int extractInfoByte(int id, byteData) {
    assert(id+3 <= byteData.length);

    int code = ((byteData[id] << 8) | byteData[id+1]) << 8 | byteData[id+2];
    info = CardInfo.from(code);
    return id + 3;
  }

  List<int> infoByte() {
    List<int> b = [];
    var i = info.toCode();
    //4 Bytes
    b.add((i & 0xFF0000) >> 16);
    b.add((i & 0xFF00) >> 8);
    b.add(i & 0xFF);
    return b;
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
        if (!convertType.containsKey(code[i]))
          throw Exception(
              'Data card list corruption: $i was found with type ${code[i]}');

        if (!convertRarity.containsKey(code[i+1]))
          throw Exception(
              'Data card list corruption: $i was found with rarity ${code[i +
                  1]}');
        Type t   = convertType[code[i]];
        Rarity r = convertRarity[code[i + 1]];

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

class SubExtension
{
  int    id;
  String name;
  String icon;
  ListCards? cards;
  int    idExtension;
  DateTime out;
  int?   chromatique;

  SubExtension({ required this.id, required this.name, required this.icon, required this.idExtension, required this.out, required this.chromatique, required this.cards });

  ListCards info() {
    return cards!;
  }

  Widget image({double? wSize, double? hSize})
  {
    return drawCachedImage('extensions', icon, width: wSize, height: hSize);
  }

  String nameCard(int id) {
    if(chromatique != null) {
      return id < chromatique! ? (id+1).toString() : 'SV' + (id-chromatique!+1).toString();
    } else {
      return (id + 1).toString();
    }
  }

  String outDate() {
    return DateFormat('yyyy-MM-dd').format(out);
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
        SubExtension? se = Environment.instance.collection.getSubExtensionID(key);
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

class CodeDraw {
  late int countNormal;
  late int countReverse;
  late int countHalo;
  late int countAlternative;

  CodeDraw(this.countNormal, this.countReverse, this.countHalo, this.countAlternative){
    assert(this.countNormal <= 7);
    assert(this.countReverse <= 7);
    assert(this.countHalo <= 7);
    assert(this.countAlternative <= 7);
  }

  CodeDraw.fromInt(int code) {
    countNormal      = code & 0x07;
    countReverse     = (code>>3) & 0x07;
    countHalo        = (code>>6) & 0x07;
    countAlternative = (code>>9) & 0x07;
  }

  int getCountFrom(Mode mode) {
    List<int> byMode = [countNormal, countReverse, countHalo, countAlternative];
    return byMode[mode.index];
  }

  int toInt() {
    int code = countNormal
             + (countReverse<<3)
             + (countHalo   <<6)
             + (countAlternative <<9);
    return code;
  }
  int count() {
    return countNormal+countReverse+countHalo+countAlternative;
  }

  bool isEmpty() {
    return count()==0;
  }

  Color color() {
    return countHalo > 0
      ? modeColors[Mode.Halo]
      : (countReverse > 0
        ?modeColors[Mode.Reverse]
        : (countAlternative > 0
          ? modeColors[Mode.Alternative]
          :(countNormal > 0
            ? modeColors[Mode.Normal]
            : Colors.grey[900])));
  }

  void increase(Mode mode) {
    if( mode == Mode.Normal)
      countNormal = min(countNormal + 1, 7);
    else if( mode == Mode.Reverse)
      countReverse = min(countReverse + 1, 7);
    else if( mode == Mode.Alternative)
      countAlternative = min(countAlternative + 1, 7);
    else
      countHalo = min(countHalo + 1, 7);
  }

  void decrease(Mode mode) {
    if( mode == Mode.Normal)
      countNormal = max(countNormal - 1, 0);
    else if( mode == Mode.Reverse)
      countReverse = max(countReverse - 1, 0);
    else if( mode == Mode.Alternative)
      countAlternative = max(countAlternative - 1, 0);
    else
      countHalo = max(countHalo - 1, 0);
  }
}

class BoosterDraw {
  late int id;
  final SubExtension? creation;    ///< Keep product extension.
  final int nbCards;               ///< Number of cards inside booster
  ///
  late List<CodeDraw> energiesBin;     ///< Energy inside booster.
  late List<CodeDraw>? cardBin;         ///< All card select by extension.
  late SubExtension? subExtension;     ///< Current extensions.
  int count = 0;
  bool abnormal = false;          ///< Packaging error

  // Event
  final StreamController onEnergyChanged = new StreamController.broadcast();

  BoosterDraw({this.creation, required this.id, required this.nbCards })
  {
    assert(this.nbCards > 0);
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(0,0,0,0); });
    subExtension = creation;
    if(hasSubExtension()) {
      fillCard();
    }
  }

  void closeStream() {
    onEnergyChanged.close();
  }

  bool isRandom() {
    return creation == null;
  }

  String nameCard(int id) {
    if(subExtension != null && subExtension!.chromatique != null) {
      return id < subExtension!.chromatique! ? (id+1).toString() : 'SV' + (id-subExtension!.chromatique!+1).toString();
    } else {
      return (id + 1).toString();
    }
  }

  void resetBooster() {
    count    = 0;
    abnormal = false;
    cardBin  = null;
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(0,0,0,0); });
  }

  void resetExtensions() {
    resetBooster();
    cardBin  = null;
    subExtension = null;
  }

  void fillCard() {
      cardBin = List<CodeDraw>.generate(subExtension!.info().cards.length, (index) { return CodeDraw(0,0,0,0); });
  }

  bool isFinished() {
    return abnormal ? count >=1 : count == nbCards;
  }

  bool hasSubExtension() {
    return subExtension != null;
  }

  bool canAdd() {
    return abnormal ? true : count < nbCards;
  }

  int countEnergy() {
    int count=0;
    for( CodeDraw c in energiesBin ){
      count += c.count();
    }
    return count;
  }

  void toggleCard(CodeDraw code, Mode mode) {
    count -= code.count();
    if(code.isEmpty()) {
      if(canAdd()) {
        code.countNormal      = mode==Mode.Normal      ? 1 : 0;
        code.countReverse     = mode==Mode.Reverse     ? 1 : 0;
        code.countHalo        = mode==Mode.Halo        ? 1 : 0;
        code.countAlternative = mode==Mode.Alternative ? 1 : 0;
      }
    } else {
      code.countNormal      = 0;
      code.countReverse     = 0;
      code.countHalo        = 0;
      code.countAlternative = 0;
    }
    count += code.count();
  }

  void increase(CodeDraw code, Mode mode) {
    if(canAdd()) {
      count -= code.count();
      code.increase(mode);
      count += code.count();
    }
  }

  void decrease(CodeDraw code, Mode mode) {
    if(count > 0) {
      count -= code.count();
      code.decrease(mode);
      count += code.count();
    }
  }

  void setOtherRendering(CodeDraw code, Mode mode) {
    if(canAdd()) {
      count -= code.count();

      code.countNormal      = mode==Mode.Normal      ? 1 : 0;
      code.countReverse     = mode==Mode.Reverse     ? 1 : 0;
      code.countHalo        = mode==Mode.Halo        ? 1 : 0;
      code.countAlternative = mode==Mode.Alternative ? 1 : 0;

      count += code.count();
    }
  }

  bool needReset() {
    return true;
  }

  void revertAnomaly() {
    resetBooster();
    fillCard();
  }

  List<Object> buildQuery(int idAchat) {
    // Clean code to minimal binary data
    List<int> elements = [];
    for(CodeDraw c in cardBin!) {
      elements.add(c.toInt());
    }
    while(elements.isNotEmpty && elements.last == 0) {
      elements.removeLast();
    }

    List<int> energyCode = [];
    for(CodeDraw c in energiesBin) {
      energyCode.add(c.toInt());
    }
    while(energyCode.isNotEmpty && energyCode.last == 0) {
      energyCode.removeLast();
    }

    return [idAchat, subExtension!.id, abnormal ? 1 : 0, Int8List.fromList(energyCode), Int8List.fromList(elements)];
  }

  Validator validationWorld(final Language language) {
    if(abnormal)
      return Validator.Valid;

    // Fr and US
    if(language.id == 1 || language.id == 2) {
      int count = 0;
      energiesBin.forEach((element) {
        count += element.count();
      });
      if (count != 1 && count != 2)
        return Validator.ErrorEnergy;

      int goodCard = 0;
      int reverse = 0;
      int id = 0;
      cardBin!.forEach((element) {
        if (subExtension!.info().cards.isNotEmpty) {
          count = element.count();
          if (count > 0 &&
              subExtension!.info().cards[id].rarity.index > Rarity.Rare.index)
            goodCard += count;
        }
        reverse += element.countReverse;
        id += 1;
      });
      if (reverse != 1 && reverse != 2)
        return Validator.ErrorReverse;
      if (goodCard > 3)
        return Validator.ErrorTooManyGood;
    }
    return Validator.Valid;
  }

  void fill(SubExtension newSubExtension, bool abnormalBooster, List<int> newCardBin, List<int> newEnergiesBin)
  {
    subExtension = newSubExtension;
    abnormal     = abnormalBooster;
    count = 0;

    fillCard();
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(0,0,0,0); });

    int id=0;
    newCardBin.forEach((element) {
      cardBin![id] = CodeDraw.fromInt(element);
      count += cardBin![id].count();
      id +=1;
    });

    id=0;
    newEnergiesBin.forEach((element) {
      energiesBin[id] = CodeDraw.fromInt(element);
      count += energiesBin[id].count();
      id += 1;
    });
  }
}

class Stats {
  final SubExtension subExt;
  int nbBoosters = 0;
  int cardByBooster = 0;
  int anomaly = 0;
  late List<int> count;
  int totalCards = 0;

  // Cached
  late List<int> countByType;
  late List<int> countByRarity;
  late List<int> countByMode;

  late List<int> countEnergy;

  Stats({required this.subExt}) {
    count         = List<int>.filled(subExt.info().cards.length, 0);
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

  void addBoosterDraw(List<int> draw, List<int> energy , int anomaly) {
    if( draw.length > subExt.info().cards.length)
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

    for(int cardI=0; cardI < draw.length; cardI +=1) {
      CodeDraw c = CodeDraw.fromInt(draw[cardI]);
      int nbCard = c.count();
      if( nbCard > 0 ) {
        cardByBooster += nbCard;
        if(subExt.info().validCard) {
          // Count
          countByType[subExt.info().cards[cardI].type.index] += nbCard;
          countByRarity[subExt.info().cards[cardI].rarity.index] += nbCard;
        }
        totalCards   += nbCard;
        count[cardI] += nbCard;
        countByMode[Mode.Normal.index]      += c.countNormal;
        countByMode[Mode.Reverse.index]     += c.countReverse;
        countByMode[Mode.Halo.index]        += c.countHalo;
        countByMode[Mode.Alternative.index] += c.countAlternative;
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

    for(PokeCard c in subExt.info().cards) {
      countByType[c.type.index]     += 1;
      countByRarity[c.rarity.index] += 1;
    }
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
  UltraChimere
  //Limited 24 values (Bit 3 bytes)
}

const List<Color> markerColors = [
  Colors.white70, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal,
  Colors.indigo, Colors.deepOrange, Colors.lime, Colors.purpleAccent,
  //Colors.greenAccent
];

List<Widget?> cachedMarkers = List.filled(CardMarker.values.length, null);
Widget pokeMarker(CardMarker marker, {double? height}) {
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
        cachedMarkers[marker.index] = Text('Legende', style: TextStyle(fontSize: 9));
        break;
      case CardMarker.Restaure:
        cachedMarkers[marker.index] = Text('Restaure', style: TextStyle(fontSize: 9));
        break;
      case CardMarker.Mega:
        cachedMarkers[marker.index] = Text('Mega', style: TextStyle(fontSize: 12));
        break;
      case CardMarker.UltraChimere:
        cachedMarkers[marker.index] = Text('Ultra', style: TextStyle(fontSize: 12));
        break;
      default:
        cachedMarkers[marker.index] = Text('Unknown', style: TextStyle(fontSize: 12));
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

  CardInfo.from(int code) {
    int id = 1;
    while(code > 0)
    {
      if((code & 0x1) == 0x1) {
        markers.add(CardMarker.values[id]);
      }
      id = id+1;
      code = code >> 1;
    }
  }

  int toCode() {
    int marker = 0;
    markers.forEach((element) {
      if(element != CardMarker.Nothing)
        marker |= (1<<(element.index-1));
    });
    return marker;
  }
}

class CardStats {
  int count = 0;
  List<int>              countRegion = List.filled(PokeRegion.values.length, 0);
  Map<SubExtension, List<int>> countSubExtension = {};
  Map<CardMarker, int>   countMarker = {};
  Map<Rarity, int>       countRarity = {};
  Map<Type, int>         countType   = {};

  bool hasData() {
    return countSubExtension.isNotEmpty;
  }

  int nbCards() {
    return count;
  }

  void add(SubExtension se, PokeCard card, int idCard) {
    count += 1;
    for(var n in card.names) {
      countRegion[n.region.index] += 1;
    }
    countRarity[card.rarity] = countRarity[card.rarity] != null ? countRarity[card.rarity]! + 1 : 1;
    countType[card.type]     = countType[card.type]     != null ? countType[card.type]! + 1     : 1;
    if(countSubExtension[se] != null) {
      countSubExtension[se]!.add(idCard);
    } else {
      countSubExtension[se] = [idCard];
    }
    card.info.markers.forEach((marker) {
      countMarker[marker] = countMarker[marker] != null ? countMarker[marker]! + 1 : 1;
    });
  }
}

class CardResults {
  NamedInfo? specificCard;
  CardInfo   filter = CardInfo();
  PokeRegion filterRegion = PokeRegion.Nothing;
  CardStats? stats;

  bool isSelected(PokeCard card){
    bool select = true;
    if(specificCard != null) {
      select = false;
      for(var n in card.names) {
        select |= (n.name == specificCard);
      }
    }
    if(select && filterRegion != PokeRegion.Nothing) {
      select = false;
      for(var n in card.names) {
        select |= (n.region == filterRegion);
      }
    }
    if(select && filter.markers.isNotEmpty) {
      select = false;
      filter.markers.forEach((element) {
        select |= card.info.markers.contains(element);
      });
    }
    return select;
  }

  bool isSpecific() {
    return specificCard != null;
  }

  bool isFiltered() {
    return filter.markers.isNotEmpty || filterRegion != PokeRegion.Nothing;
  }

  bool hasStats() {
    return stats != null;
  }
}