import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:cached_network_image/cached_network_image.dart';

double iconSize = 25.0;

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
  UltraRare,
  ChromatiqueRare,
  Secret,
  JSR,
  ArcEnCiel,
  JHR,
  Gold,
  JUR,
  Unknown,
}

List<Color> rarityColors = [Colors.green, Colors.green, Colors.green[600]!, Colors.green[600]!, Colors.green[700]!, Colors.green[700]!,  // C JC P JU R JR
  Colors.blue, Colors.blue[600]!, Colors.blue[700]!, Colors.blue[800]!,                  // H M P C
  Colors.purple, Colors.purple, Colors.purple[600]!, Colors.purple[600]!, Colors.purple[700]!, Colors.purple[800]!,         // Ch T V JRR Vm JRRR
  Colors.yellow, Colors.yellow[600]!, Colors.yellow[600]!, Colors.yellow[700]!, Colors.yellow[700]!, Colors.yellow[800]!, Colors.yellow[800]!           // ChR S JSR A JHR G JUR
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

Map imageName = {
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

List<Color> energiesColors = [Colors.green, Colors.red, Colors.blue,
  Colors.yellow, Colors.purple[600]!, Colors.deepOrange[800]!, Colors.deepPurple[900]!,
  Colors.grey[400]!,  Colors.pinkAccent, Colors.orange, Colors.white70,
];

List<Color> typeColors = energiesColors + [Colors.blue[700]!, Colors.red[800]!, Colors.greenAccent[100]!, Colors.yellowAccent[100]!];

List<Widget?> cachedEnergies = List.filled(energies.length, null);

Widget energyImage(Type type) {
  if(cachedEnergies[type.index] == null) {
    if (type == Type.Unknown)
      cachedEnergies[type.index] = Icon(Icons.help_outline);
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

List<Widget> getImageRarity(Rarity rarity) {
  if(cachedImageRarity[rarity.index] == null) {
    //star_border
    switch(rarity) {
      case Rarity.Commune:
        cachedImageRarity[rarity.index] = [Icon(Icons.circle)];
        break;
      case Rarity.PeuCommune:
        cachedImageRarity[rarity.index] = [Transform.rotate(
            angle: pi / 4.0,
            child: Icon(Icons.stop))];
        break;
      case Rarity.Rare:
        cachedImageRarity[rarity.index] = [Icon(Icons.star)];
        break;
      case Rarity.Prism:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('P', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.Chromatique:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('CH', style: TextStyle(fontSize: 10.0))];
        break;
      case Rarity.ChromatiqueRare:
        cachedImageRarity[rarity.index] = [Icon(Icons.star_border), Text('CH', style: TextStyle(fontSize: 10.0))];
        break;
      case Rarity.V:
        cachedImageRarity[rarity.index] = [Icon(Icons.star_border)];
        break;
      case Rarity.VMax:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('X', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.Turbo:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('T', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.HoloRare:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('H', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.UltraRare:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('U', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.Magnifique:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('M', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.Secret:
        cachedImageRarity[rarity.index] = [Icon(Icons.star_border), Text('S', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.ArcEnCiel:
        cachedImageRarity[rarity.index] = [Icon(Icons.looks)];
        break;
      case Rarity.Gold:
        cachedImageRarity[rarity.index] = [Icon(Icons.local_play, color: Colors.yellow[300])];
        break;
      case Rarity.Unknown:
        cachedImageRarity[rarity.index] = [Icon(Icons.help_outline)];
        break;

      case Rarity.JC:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('C', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JU:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('U', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JR:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('R', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JRR:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('RR', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JRRR:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('RRR', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JSR:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('SR', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JHR:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('HR', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.JUR:
        cachedImageRarity[rarity.index] = [SizedBox(width: 4), Text('UR', style: TextStyle(fontSize: 12.0))];
        break;

      default:
        throw Exception("Unknown rarity: $rarity");
    }
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
      default:
        cachedImageType[type.index] = energyImage(type);
    }
  }
  return cachedImageType[type.index]!;
}

class PokeCard
{
  Type   type;
  Rarity rarity;
  bool   hasAlternative;

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
}

class NamedInfo
{
  List<String> names;

  NamedInfo({required this.names});
}

class PokemonInfo extends NamedInfo
{
  int          generation;

  PokemonInfo({required List<String> names, required this.generation}) :
  super(names: names)
  {
   assert(names.length == 3);
  }
}

class ListCards
{
  List<PokeCard>    cards    = [];
  List              pokemons = [];
  bool   validCard = true;

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

  void extractNamed(List<int> pokeList) {
    for( int pokeID in pokeList ) {
      var poke;
      if( pokeID >= 10000 ) {
        poke = Environment.instance.collection.getNamedID(pokeID);

      } else {
        poke = Environment.instance.collection.getPokemonID(pokeID);
      }

      assert(poke != null); // Missing item into DB
      pokemons.add(poke);
    }

    /*
    if(local && pokemons.length != cards.length) {
      pokemons.forEach((element) { print( element.names[0] );});

      print('Named: ${pokemons.length} != Code ${cards.length}');
    }
    assert(pokemons.length == cards.length);
    */
  }

  String getName(Language l, int id) {
    if(id < pokemons.length ) {
      return pokemons[id].names[l.id-1];
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
  int    year;
  int?   chromatique;

  SubExtension({ required this.id, required this.name, required this.icon, required this.idExtension, required this.year, required this.chromatique, required this.cards });

  ListCards info() {
    return cards!;
  }

  Widget image({double? wSize, double? hSize})
  {
    return CachedNetworkImage(imageUrl: '$adresseHTML/StatitikCard/extensions/$icon.png',
      errorWidget: (context, url, error) => Icon(Icons.help_outline),
      placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
      width:  wSize,
      height: hSize,
    );
  }

  String nameCard(int id) {
    if(chromatique != null) {
      return id < chromatique! ? (id+1).toString() : 'SV' + (id-chromatique!+1).toString();
    } else {
      return (id + 1).toString();
    }
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
  Map<int,ProductBooster> boosters;
  Color color;
  int count;

  Product({required this.idDB, required this.name, required this.imageURL, required this.count, required this.boosters, required this.color});

  bool hasImages() {
    return imageURL.isNotEmpty;
  }

  CachedNetworkImage image()
  {
    return CachedNetworkImage(imageUrl: Environment.instance.serverImages+imageURL,
      errorWidget: (context, url, error) => Icon(Icons.error),
      placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
      height: 70,
    );
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
        SubExtension? se = key != null ? Environment.instance.collection.getSubExtensionID(key) : null;
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
  late List<BoosterDraw> boosterDraws;

  SessionDraw({required this.product, required this.language})
  {
    boosterDraws = product.buildBoosterDraw();
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