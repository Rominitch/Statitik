import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return AssetImage('assets/$image.png');
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
const String emptyMode = '_';

String modeToString(Mode mode) {
  return convertMode.keys.firstWhere(
          (k) => convertMode[k] == mode, orElse: () => emptyMode);
}

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
  Type.Energy: ''
};
const List<Type> energies = [Type.Plante,  Type.Feu,  Type.Eau,
  Type.Electrique,  Type.Psy,  Type.Combat,  Type.Obscurite,  Type.Metal,
  Type.Incolore,  Type.Fee,  Type.Dragon];

List<Color> energiesColors = [Colors.green, Colors.red, Colors.blue,
  Colors.yellow, Colors.purple[800], Colors.deepOrange[800], Colors.deepPurple[900], Colors.white12,
  Colors.white70, Colors.pinkAccent, Colors.orange
];

Widget energyImage(Type type) {
  return CachedNetworkImage(
      imageUrl: 'https://www.pokecardex.com/forums/images/smilies/energy-types_${imageCode[type]}.png',
      errorWidget: (context, url, error) => Icon(Icons.error),
      placeholder: (context, url) => CircularProgressIndicator(),
      width: 20
  );
}

String typeToString(Type type) {
  return convertType.keys.firstWhere(
          (k) => convertType[k] == type, orElse: () => emptyMode);
}

List<Widget> getImageRarity(Rarity rarity) {
  //star_border
  switch(rarity) {
    case Rarity.Commune:
      return [Icon(Icons.circle)];
    case Rarity.PeuCommune:
      return [Transform.rotate(
          angle: pi / 4.0,
          child: Icon(Icons.stop))];
    case Rarity.Rare:
      return [Icon(Icons.star)];
    case Rarity.V:
      return [Icon(Icons.star_border)];
    case Rarity.VMax:
      return [Icon(Icons.star), Text('X', style: TextStyle(fontSize: 12.0))];
    case Rarity.HoloRare:
      return [Icon(Icons.star), Text('H', style: TextStyle(fontSize: 12.0))];
    case Rarity.UltraRare:
      return [Icon(Icons.star), Text('U', style: TextStyle(fontSize: 12.0))];
    case Rarity.Magnifique:
      return [Icon(Icons.star), Text('M', style: TextStyle(fontSize: 12.0))];
    case Rarity.ArcEnCiel:
      return [Icon(Icons.looks)];
    case Rarity.Gold:
      return [Icon(Icons.local_play, color: Colors.yellow[300])];
  }
  throw Exception("Unknown rarity: $rarity");
}

class PokeCard
{
  Type   type;
  Rarity rarity;

  PokeCard({this.type, this.rarity});

  List<Widget> imageRarity() {
    return getImageRarity(rarity);
  }

  Widget imageType()
  {
    //star_border
    switch(type) {
      case Type.Objet:
        return Icon(Icons.build);
      case Type.Stade:
        return Icon(Icons.landscape);
      case Type.Supporter:
        return Icon(Icons.accessibility_new);
      case Type.Energy:
        return Icon(Icons.battery_charging_full);
      default:
        return CachedNetworkImage(
            imageUrl: 'https://www.pokecardex.com/forums/images/smilies/energy-types_${imageCode[type]}.png',
            errorWidget: (context, url, error) => Icon(Icons.error),
            placeholder: (context, url) => CircularProgressIndicator(),
            width: 20
        );
    }
  }

  bool hasAnotherRendering() {
    return rarity == Rarity.Commune || rarity == Rarity.PeuCommune || rarity == Rarity.Rare;
  }

}

class SubExtension
{
  int    id;
  String name;
  String icon;
  List<PokeCard> cards = [];
  int    idExtension;

  SubExtension({ this.id, this.name, this.icon, this.idExtension });

  void extractCard(String code)
  {
      if(code.length % 2 == 1)
      {
        throw Exception('Corrupt database code');
      }

      cards.clear();
      for(int i=0; i<code.length; i+=2) {
          Type t = convertType[code[i]];
          if( t == null)
            throw Exception('"Data card list corruption: $i was found with type ${code[i]}');
          Rarity r = convertRarity[code[i + 1]];
          if( r == null)
            throw Exception('Data card list corruption: $i was found with rarity ${code[i+1]}');
          cards.add(PokeCard(type: t, rarity: r));
      }
  }

  CachedNetworkImage image()
  {
    return CachedNetworkImage(
        imageUrl: 'https://www.pokecardex.com/assets/images/symboles/$icon.png',
        //imageUrl: 'https://assets.pokemon.com/assets/cms-fr-fr/img/tcg/expansion-symbols/$icon-expansion-symbol.png',
        errorWidget: (context, url, error) => Icon(Icons.error),
        placeholder: (context, url) => CircularProgressIndicator(),
        width: 20
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

  List buildBoosterDraw() {
    List list = [];
    int id=1;
    boosters.forEach((key, value) {
      for( int i=0; i < value; i+=1) {
        list.add(new BoosterDraw(subExtension: Environment.instance.collection.getSubExtensionID(key), id: id));
        id += 1;
      }
    });
    return list;
  }
}

class BoosterDraw {
  int id;
  String energyCode = emptyMode;  ///< Code of energy inside booster.
  List<String> card;              ///< All card select by extension.
  SubExtension subExtension;
  int count = 0;
  int nbCards = 10;               ///< Number of cards inside booster
  bool abnormal = false;          ///< Packaging error

  // Event
  final StreamController onEnergyChanged = new StreamController.broadcast();

  BoosterDraw({this.subExtension, this.id })
  {
    card = new List<String>.filled(subExtension.cards.length, emptyMode);
  }

  bool isFinished() {
    return count >= nbCards;
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
    return [idAchat, subExtension.id, card.join(), abnormal ? 1 : 0, energyCode];
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
    if( draw.length != subExt.cards.length)
      throw StatitikException('Corruption des données de tirages');

    this.anomaly += anomaly;
    nbBoosters += 1;

    countEnergy[convertType[energy].index] += 1;

    for(int cardI=0; cardI < draw.length; cardI +=1) {
      String c = draw[cardI];
      if( c != emptyMode) {
        cardByBooster += 1;
        // Count
        countByType[subExt.cards[cardI].type.index] += 1;
        countByRarity[subExt.cards[cardI].rarity.index] += 1;
        count[cardI] += 1;
        countByMode[convertMode[c].index] += 1;
      }
    }
  }



}