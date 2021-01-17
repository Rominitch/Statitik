import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:cached_network_image/cached_network_image.dart';

double iconSize = 25.0;

class UserPoke {
  int idDB;
  String uid;

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
  Incolore,
  Fee,
  Dragon,
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
  V,
  VMax,
  UltraRare,
  ArcEnCiel,
  Gold,
  Unknown,
}

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
  'v': Rarity.V,
  'V': Rarity.VMax,
  'A': Rarity.ArcEnCiel,
  'G': Rarity.Gold,
};

enum Mode {
  Normal,
  Reverse,
  Halo,
}
const Map convertMode =
{
  'n': Mode.Normal,
  'r': Mode.Reverse,
  'h': Mode.Halo,
};

const Map modeImgs   = {Mode.Normal: "normal", Mode.Reverse: "reverse", Mode.Halo: "halo"};
const Map modeNames  = {Mode.Normal: "Normal", Mode.Reverse: "Reverse", Mode.Halo: "Halo"};
const Map modeColors = {Mode.Normal: Colors.green, Mode.Reverse: Colors.blueAccent, Mode.Halo: Colors.orange};

const String emptyMode = '_';

String modeToString(Mode mode) {
  return convertMode.keys.firstWhere(
          (k) => convertMode[k] == mode, orElse: () => emptyMode);
}

Map imageName = {
  Type.Plante: 'plante',
  Type.Feu: 'feu',
  Type.Eau: 'eau',
  Type.Electrique: 'electrique',
  Type.Psy: '',
  Type.Combat: '',
  Type.Obscurite: '',
  Type.Metal: '',
  Type.Incolore: '',
  Type.Fee: '',
  Type.Dragon: '',
  Type.Objet: '',
  Type.Supporter: '',
  Type.Stade: '',
  Type.Energy: '',
  Type.Unknown: '',
};

Map imageCode = {
  Type.Plante: '10',
  Type.Feu: '01',
  Type.Eau: '12',
  Type.Electrique: '06',
  Type.Psy: '08',
  Type.Combat: '07',
  Type.Obscurite: '09',
  Type.Metal: '04',
  Type.Incolore: '02',
  Type.Fee: '03',
  Type.Dragon: '05',
  Type.Objet: '',
  Type.Supporter: '',
  Type.Stade: '',
  Type.Energy: '',
  Type.Unknown: '',
};
const List<Type> energies = [Type.Plante,  Type.Feu,  Type.Eau,
  Type.Electrique,  Type.Psy,  Type.Combat,  Type.Obscurite,  Type.Metal,
  Type.Incolore,  Type.Fee,  Type.Dragon];

List<Color> energiesColors = [Colors.green, Colors.red, Colors.blue,
  Colors.yellow, Colors.purple[800], Colors.deepOrange[800], Colors.deepPurple[900], Colors.white12,
  Colors.white70, Colors.pinkAccent, Colors.orange
];

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
    } else {
      cachedEnergies[type.index] = CachedNetworkImage(
        imageUrl: 'https://www.pokecardex.com/forums/images/smilies/energy-types_${imageCode[type]}.png',
        errorWidget: (context, url, error) => Icon(Icons.error),
        placeholder: (context, url) => CircularProgressIndicator(),
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

  Widget imageType()
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

  bool hasAnotherRendering() {
    return !isValid() || rarity == Rarity.Commune || rarity == Rarity.PeuCommune || rarity == Rarity.Rare;
  }

}

class SubExtension
{
  int    id;
  String name;
  String icon;
  List<PokeCard> cards = [];
  int    idExtension;
  bool   validCard = true;

  SubExtension({ this.id, this.name, this.icon, this.idExtension });

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
                '"Data card list corruption: $i was found with type ${code[i]}');
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
    bool network = true;

    String path = 'assets/extensions/$icon.png';
    try {
      rootBundle.loadString(path);
    } catch (Exception) {
      network = true;
    }

    if(!network)
      return Image(
        image: AssetImage(path),
        width: wSize,
        height: hSize,
      );
    else
      return CachedNetworkImage(
        imageUrl: 'https://www.pokecardex.com/assets/images/symboles/$icon.png',
        errorWidget: (context, url, error) => Icon(Icons.error),
        placeholder: (context, url) => CircularProgressIndicator(),
        width: wSize,
        height: hSize,
      );
  }
}

class Product
{
  int idDB;
  String name;
  String imageURL;
  Map boosters;

  Product({this.idDB, this.name, this.imageURL, this.boosters});

  CachedNetworkImage image()
  {
    return CachedNetworkImage(imageUrl: '$imageURL',
      errorWidget: (context, url, error) => Icon(Icons.error),
      placeholder: (context, url) => CircularProgressIndicator(),
      height: 70,
    );
  }

  int countBoosters() {
    int count=0;
    boosters.forEach((key, value) { count += value; });
    return count;
  }

  List buildBoosterDraw() {
    List list = [];
    int id=1;
    boosters.forEach((key, value) {
      for( int i=0; i < value; i+=1) {
        SubExtension se = key != null ? Environment.instance.collection.getSubExtensionID(key) : null;
        list.add(new BoosterDraw(creation: se, id: id));
        id += 1;
      }
    });
    return list;
  }
}

class BoosterDraw {
  int id;
  SubExtension creation;          ///< Keep product extension.

  String energyCode = emptyMode;  ///< Code of energy inside booster.
  List<String> card;              ///< All card select by extension.
  SubExtension subExtension;      ///< Current extensions.
  int count = 0;
  int nbCards = 10;               ///< Number of cards inside booster
  bool abnormal = false;          ///< Packaging error

  // Event
  final StreamController onEnergyChanged = new StreamController.broadcast();

  BoosterDraw({this.creation, this.id })
  {
    subExtension = creation;
    if(hasSubExtension()) {
      fillCard();
    }
  }
  bool isRandom() {
    return creation == null;
  }

  void resetExtensions() {
    energyCode = emptyMode;
    count    = 0;
    nbCards  = 10;
    abnormal = false;
    card = null;
    subExtension = null;
  }

  void fillCard() {
      card = new List<String>.filled(subExtension.cards.length, emptyMode);
  }

  bool isFinished() {
    return count >= nbCards;
  }

  bool hasSubExtension() {
    return subExtension != null;
  }

  bool hasAllCards() {
    return count >= (nbCards-((energyCode == emptyMode) ? 1 : 0));
  }

  void toggleCard(int id, Mode mode) {
    if(card[id] == emptyMode) {
      if(!hasAllCards()) {
        card[id] = modeToString(mode);
        count += 1;
      }
    } else {
      card[id] = emptyMode;
      count -= 1;
    }
  }

  void setOtherRendering(int id, Mode mode) {
    if(!hasAllCards()) {
      count += card[id] == emptyMode ? 1 : 0;
      card[id] = modeToString(mode);
    }
  }

  void setEnergy(Type type) {
    int state = energyCode == emptyMode ? 1 : 0;
    energyCode = convertType[energyCode] == type ? emptyMode : typeToString(type);
    count += energyCode == emptyMode ? -1 : state;

    onEnergyChanged.add(true);
  }

  List buildQuery(int idAchat) {
    // Clean code to minimal string
    var newCard = new List<String>.from(card);
    while(newCard.last == emptyMode) {
      newCard.removeLast();
    }
    return [idAchat, subExtension.id, newCard.join(), abnormal ? 1 : 0, energyCode];
  }
}

class Stats {
  final SubExtension subExt;
  int nbBoosters = 0;
  int cardByBooster = 0;
  int anomaly = 0;
  List<int> count;

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

  void addBoosterDraw(String draw, String energy, int anomaly) {
    if( draw.length > subExt.cards.length)
      throw StatitikException('Corruption des données de tirages');

    this.anomaly += anomaly;
    nbBoosters += 1;

    countEnergy[convertType[energy].index] += 1;

    for(int cardI=0; cardI < draw.length; cardI +=1) {
      String c = draw[cardI];
      if( c != emptyMode) {
        cardByBooster += 1;
        if(subExt.validCard) {
          // Count
          countByType[subExt.cards[cardI].type.index] += 1;
          countByRarity[subExt.cards[cardI].rarity.index] += 1;
        }
        count[cardI] += 1;
        countByMode[convertMode[c].index] += 1;
      }
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