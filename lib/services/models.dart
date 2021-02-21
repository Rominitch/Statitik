import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:cached_network_image/cached_network_image.dart';

double iconSize = 25.0;

final Color greenValid = Colors.green[500];

class UserPoke {
  int idDB;
  String uid;
  bool admin = false;

  UserPoke({this.idDB});
}

class Language
{
  int id;
  String image;

  Language({this.id, this.image});

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

  Extension({ this.id, this.name, this.idLanguage });
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
  PeuCommune,
  Rare,
  HoloRare,
  Magnifique,
  Prism,
  Chromatique,
  ChromatiqueRare,
  V,
  VMax,
  UltraRare,
  Secret,
  ArcEnCiel,
  Gold,
  Unknown,
}

List<Color> rarityColors = [Colors.green, Colors.green, Colors.green,
  Colors.blue, Colors.blue, Colors.blue, Colors.blue, Colors.blue,
  Colors.purple, Colors.purple, Colors.purple,
  Colors.yellow, Colors.yellow, Colors.yellow
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
  'v': Rarity.V, // or GX
  'V': Rarity.VMax,
  'S': Rarity.Secret,
  'A': Rarity.ArcEnCiel,
  'G': Rarity.Gold,
};

enum Mode {
  Normal,
  Reverse,
  Halo,
}

const Map modeImgs   = {Mode.Normal: "normal", Mode.Reverse: "reverse", Mode.Halo: "halo"};
const Map modeNames  = {Mode.Normal: "Normal", Mode.Reverse: "Reverse", Mode.Halo: "Halo"};
const Map modeColors = {Mode.Normal: Colors.green, Mode.Reverse: Colors.blueAccent, Mode.Halo: Colors.purple};

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
  Colors.yellow, Colors.purple[600], Colors.deepOrange[800], Colors.deepPurple[900],
  Colors.grey[400],  Colors.pinkAccent, Colors.orange, Colors.white70,
];

List<Color> typeColors = energiesColors + [Colors.blue[700], Colors.red[800], Colors.greenAccent[100], Colors.yellowAccent[100]];

List<Widget> cachedEnergies = List.filled(energies.length, null);

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
  return cachedEnergies[type.index];
}

String typeToString(Type type) {
  return convertType.keys.firstWhere(
          (k) => convertType[k] == type, orElse: () => emptyMode);
}

List<List<Widget>> cachedImageRarity = List.filled(Rarity.values.length, null);


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
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('CH', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.ChromatiqueRare:
        cachedImageRarity[rarity.index] = [Icon(Icons.star_border), Text('CH', style: TextStyle(fontSize: 12.0))];
        break;
      case Rarity.V:
        cachedImageRarity[rarity.index] = [Icon(Icons.star_border)];
        break;
      case Rarity.VMax:
        cachedImageRarity[rarity.index] = [Icon(Icons.star), Text('X', style: TextStyle(fontSize: 12.0))];
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
      default:
        throw Exception("Unknown rarity: $rarity");
    }
  }
  return cachedImageRarity[rarity.index];
}

List<Widget> cachedImageType = List.filled(Type.values.length, null);

Widget getImageType(Type type)
{
  if(cachedImageType[type.index] == null) {
    switch(type) {
      case Type.Objet:
        cachedImageType[type.index] = Icon(Icons.build);
        break;
      case Type.Stade:
        cachedImageType[type.index] = Icon(Icons.landscape);
        break;
      case Type.Supporter:
        cachedImageType[type.index] = Icon(Icons.accessibility_new);
        break;
      case Type.Energy:
        cachedImageType[type.index] = Icon(Icons.battery_charging_full);
        break;
      default:
        cachedImageType[type.index] = energyImage(type);
    }
  }
  return cachedImageType[type.index];
}

class PokeCard
{
  Type   type;
  Rarity rarity;

  PokeCard({this.type, this.rarity});

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

class SubExtension
{
  int    id;
  String name;
  String icon;
  List<PokeCard> cards = [];
  int    idExtension;
  int    year;
  bool   validCard = true;
  int    chromatique;

  SubExtension({ this.id, this.name, this.icon, this.idExtension, this.year, this.chromatique });

  void extractCard(String code)
  {
      cards.clear();
      validCard = true;

      if(code.isEmpty) {
        validCard=false;
        // Build pre-publication: 300 card max
        for (int i = 0; i < 300; i += 1) {
          cards.add(PokeCard(type: Type.Unknown, rarity: Rarity.Unknown));
        }
      } else {
        if (code.length % 2 == 1) {
          throw Exception('Corrupt database code');
        }

        for (int i = 0; i < code.length; i += 2) {
          Type t = convertType[code[i]];
          if (t == null)
            throw Exception(
                'Data card list corruption: $i was found with type ${code[i]}');
          Rarity r = convertRarity[code[i + 1]];
          if (r == null)
            throw Exception(
                'Data card list corruption: $i was found with rarity ${code[i +
                    1]}');
          cards.add(PokeCard(type: t, rarity: r));
        }
      }
  }

  Widget image({double wSize, double hSize})
  {
    return CachedNetworkImage(imageUrl: '$adresseHTML/StatitikCard/extensions/$icon.png',
      errorWidget: (context, url, error) => Icon(Icons.help_outline),
      placeholder: (context, url) => CircularProgressIndicator(),
      width:  wSize,
      height: hSize,
    );
  }
}

class ProductBooster
{
  int nbBoosters;
  int nbCardsPerBooster;

  ProductBooster({this.nbBoosters, this.nbCardsPerBooster});
}

class Product
{
  int idDB;
  String name;
  String imageURL;
  Map<int,ProductBooster> boosters;
  Color color;

  Product({this.idDB, this.name, this.imageURL, this.boosters, this.color});

  bool hasImages() {
    return imageURL.isNotEmpty;
  }

  CachedNetworkImage image()
  {
    return CachedNetworkImage(imageUrl: Environment.instance.serverImages+imageURL,
      errorWidget: (context, url, error) => Icon(Icons.error),
      placeholder: (context, url) => CircularProgressIndicator(),
      height: 70,
    );
  }

  int countBoosters() {
    int count=0;
    boosters.forEach((key, value) { count += value.nbBoosters; });
    return count;
  }

  List buildBoosterDraw() {
    List list = [];
    int id=1;
    boosters.forEach((key, value) {
      for( int i=0; i < value.nbBoosters; i+=1) {
        SubExtension se = key != null ? Environment.instance.collection.getSubExtensionID(key) : null;
        list.add(new BoosterDraw(creation: se, id: id, nbCards: value.nbCardsPerBooster));
        id += 1;
      }
    });
    return list;
  }

  Future<int> countProduct() async {
    int count=0;
    await Environment.instance.db.transactionR((connection) async {
      var req = await connection.query('SELECT count(idProduit) FROM `UtilisateurProduit` WHERE idProduit = $idDB;');
      for (var row in req) {
        count = row[0];
      }
    });
    return count;
  }
}

class CodeDraw {
  int countNormal;
  int countReverse;
  int countHalo;

  CodeDraw(this.countNormal, this.countReverse, this.countHalo){
    assert(this.countNormal <= 7);
    assert(this.countReverse <= 7);
    assert(this.countHalo <= 7);
  }

  CodeDraw.fromInt(int code) {
    countNormal  = code & 0x07;
    countReverse = (code>>3) & 0x07;
    countHalo    = (code>>6) & 0x07;
  }

  int getCountFrom(Mode mode) {
    List<int> byMode = [countNormal, countReverse, countHalo];
    return byMode[mode.index];
  }

  int toInt() {
    int code = countNormal
             + (countReverse<<3)
             + (countHalo   <<6);
    return code;
  }
  int count() {
    return countNormal+countReverse+countHalo;
  }

  bool isEmpty() {
    return count()==0;
  }

  Color color() {
    return countHalo > 0
          ? modeColors[Mode.Halo]
          : (countReverse > 0
              ?modeColors[Mode.Reverse]
              : (countNormal > 0
                 ? modeColors[Mode.Normal]
                 : Colors.grey[900]));
  }

  void increase(Mode mode) {
    if( mode == Mode.Normal)
      countNormal = min(countNormal + 1, 7);
    else if( mode == Mode.Reverse)
      countReverse = min(countReverse + 1, 7);
    else
      countHalo = min(countHalo + 1, 7);
  }

  void decrease(Mode mode) {
    if( mode == Mode.Normal)
      countNormal = max(countNormal - 1, 0);
    else if( mode == Mode.Reverse)
      countReverse = max(countReverse - 1, 0);
    else
      countHalo = max(countHalo - 1, 0);
  }
}

class BoosterDraw {
  final int id;
  final SubExtension creation;    ///< Keep product extension.
  final int nbCards;              ///< Number of cards inside booster
  ///
  List<CodeDraw> energiesBin;     ///< Energy inside booster.
  List<CodeDraw> cardBin;         ///< All card select by extension.
  SubExtension subExtension;      ///< Current extensions.
  int count = 0;
  bool abnormal = false;          ///< Packaging error

  // Event
  final StreamController onEnergyChanged = new StreamController.broadcast();

  BoosterDraw({this.creation, this.id, this.nbCards })
  {
    assert(nbCards != null);
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(0,0,0); });
    subExtension = creation;
    if(hasSubExtension()) {
      fillCard();
    }
  }
  bool isRandom() {
    return creation == null;
  }

  String nameCard(int id) {
    if(subExtension != null && subExtension.chromatique != null) {
      return id < subExtension.chromatique ? (id+1).toString() : 'SV' + (id-subExtension.chromatique+1).toString();
    } else {
      return (id + 1).toString();
    }
  }

  void resetBooster() {
    count    = 0;
    abnormal = false;
    cardBin  = null;
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(0,0,0); });
  }

  void resetExtensions() {
    resetBooster();
    cardBin  = null;
    subExtension = null;
  }

  void fillCard() {
      cardBin = List<CodeDraw>.generate(subExtension.cards.length, (index) { return CodeDraw(0,0,0); });
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
        code.countNormal  = mode==Mode.Normal  ? 1 : 0;
        code.countReverse = mode==Mode.Reverse ? 1 : 0;
        code.countHalo    = mode==Mode.Halo    ? 1 : 0;
      }
    } else {
      code.countNormal  = 0;
      code.countReverse = 0;
      code.countHalo    = 0;
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

      code.countNormal  = mode==Mode.Normal  ? 1 : 0;
      code.countReverse = mode==Mode.Reverse ? 1 : 0;
      code.countHalo    = mode==Mode.Halo    ? 1 : 0;

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

  List buildQuery(int idAchat) {
    // Clean code to minimal binary data
    //Int8List bin = new Int8List(cardBin.length);
    List<int> elements = [];
    for(CodeDraw c in cardBin) {
      elements.add(c.toInt());
    }
    while(elements.last == 0) {
      elements.removeLast();
    }

    List<int> energyCode = [];
    for(CodeDraw c in energiesBin) {
      energyCode.add(c.toInt());
    }
    while(energyCode.last == 0) {
      energyCode.removeLast();
    }

    return [idAchat, subExtension.id, abnormal ? 1 : 0, Int8List.fromList(energyCode), Int8List.fromList(elements)];
  }
}

class Stats {
  final SubExtension subExt;
  int nbBoosters = 0;
  int cardByBooster = 0;
  int anomaly = 0;
  List<int> count;
  int totalCards = 0;

  // Cached
  List<int> countByType;
  List<int> countByRarity;
  List<int> countByMode;

  List<int> countEnergy;

  Stats({this.subExt}) {
    count         = List<int>.filled(subExt.cards.length, 0);
    countByType   = List<int>.filled(Type.values.length, 0);
    countByRarity = List<int>.filled(Rarity.values.length, 0);
    countByMode   = List<int>.filled(Mode.values.length, 0);
    countEnergy   = List<int>.filled(energies.length, 0);
  }

  void addBoosterDraw(List<int> draw, List<int> energy , int anomaly) {
    if( draw.length > subExt.cards.length)
      throw StatitikException('Corruption des données de tirages');

    anomaly += anomaly;
    nbBoosters += 1;

    for(int energyI=0; energyI < energy.length; energyI +=1) {
      CodeDraw c = CodeDraw.fromInt(energy[energyI]);
      countEnergy[energyI] += c.count();
    }

    for(int cardI=0; cardI < draw.length; cardI +=1) {
      CodeDraw c = CodeDraw.fromInt(draw[cardI]);
      int nbCard = c.count();
      if( nbCard > 0 ) {
        cardByBooster += nbCard;
        if(subExt.validCard) {
          // Count
          countByType[subExt.cards[cardI].type.index] += nbCard;
          countByRarity[subExt.cards[cardI].rarity.index] += nbCard;
        }
        totalCards   += nbCard;
        count[cardI] += nbCard;
        countByMode[Mode.Normal.index]  += c.countNormal;
        countByMode[Mode.Reverse.index] += c.countReverse;
        countByMode[Mode.Halo.index]    += c.countHalo;
      }
    }
  }
}

class StatsExtension {
  final SubExtension subExt;

  List<int> countByType;
  List<int> countByRarity;

  StatsExtension({this.subExt}) {
    countByType   = List<int>.filled(Type.values.length, 0);
    countByRarity = List<int>.filled(Rarity.values.length, 0);

    for(PokeCard c in subExt.cards) {
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
  List boosterDraws;

  SessionDraw({this.product, this.language})
  {
    boosterDraws = product.buildBoosterDraw();
  }

  void addNewBooster() {
    BoosterDraw booster = boosterDraws.last;

    boosterDraws.add(new BoosterDraw(creation: booster.subExtension, id: booster.id+1) );
  }

  void deleteBooster(int id) {
    if( id >= boosterDraws.length || id < 0 )
      throw StatitikException("Impossible de trouver le booster $id");
    // Delete
    boosterDraws.removeAt(id);
    // Change Label ID
    id = 1;
    boosterDraws.forEach((element) {element.id = id; id += 1; });
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