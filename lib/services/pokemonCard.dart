import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/CardTitleData.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

/// Pokemon region
class Region {
  final MultiLanguageString _fullName;
  final MultiLanguageString _applyPokemonName;

  const Region(this._fullName, this._applyPokemonName);

  String name(Language l) {
    return _fullName.name(l);
  }

  String applyToPokemonName(Language l) {
    return _applyPokemonName.name(l);
  }
}

/// Special name to give (flying pikachu, ...)
class Forme
{
  final MultiLanguageString _applyPokemonName;

  const Forme(this._applyPokemonName);

  String applyToPokemonName(Language l) {
    return _applyPokemonName.name(l);
  }
}

/// Full pokemon definition
class Pokemon {
  CardTitleData   name;
  Region?     region;
  Forme?      forme;

  Pokemon(this.name, {this.region, this.forme});

  static Pokemon fromBytes(ByteParser parser, collection) {
    int idName = parser.extractInt16();
    assert(idName != 0);

    Pokemon p = Pokemon(idName < 10000
              ? collection.getPokemonID(idName)
              : collection.getNamedID(idName));
    int idRegion = parser.extractInt8();
    if(idRegion > 0)
      p.region = collection.regions[idRegion];

    int idForme  = parser.extractInt8();
    if(idForme > 0)
      p.forme = collection.formes[idForme];
    return p;
  }

  List<int> toBytes(collection) {
    int id=0;
    if (name.isPokemon()) {
      assert(collection.rPokemon.containsKey(name), name.defaultName());
      id = collection.rPokemon[name];
    } else {
      assert(collection.rOther.containsKey(name), name.defaultName());
      id = collection.rOther[name];
    }
    assert(id != 0);

    var bytes = <int>
    [
      (id & 0xFF00) >> 8,
      id & 0xFF,
      region != null ? collection.rRegions[region] : 0,
      forme  != null ? collection.rFormes[forme]   : 0,
    ];
    assert((bytes[0] | bytes[1]) != 0);
    assert(bytes[0] <= 0xFF && bytes[1] <= 0xFF);
    return bytes;
  }

  String titleOfCard(Language l) {
    String title = name.name(l);
    if(forme != null) {
      title = sprintf(forme!._applyPokemonName.name(l), [title]);
    }
    if(region != null) {
      title = sprintf(region!._applyPokemonName.name(l), [title]);
    }
    return title;
  }
}

class Illustrator {
  final String name;

  const Illustrator(this.name);
}

class EnergyValue {
  TypeCard energy;
  int  value;

  EnergyValue(this.energy, this.value);

  EnergyValue.fromBytes(bytes) :
    energy = TypeCard.values[bytes[0]],
    value = (bytes[1] << 8) | bytes[2];

  List<int> toBytes() {
    return <int>[
      energy.index,
      (value & 0xFF00) >> 8,
      value & 0xFF
    ];
  }
}

enum AlternativeDesign {
  Basic,
  HolographicHorizontalLine,
  HolographicVerticalLine,
  HolographicStarDot,
}

enum Design {
  Basic,
  Holographic,
  ArcEnCiel,
  Gold,
}

Widget icon(Design design) {
  switch(design) {
    case Design.Basic:
      return Icon(Icons.article_outlined);
    case Design.Holographic:
      return Icon(Icons.article);
    case Design.ArcEnCiel:
      return Icon(Icons.looks);
    case Design.Gold:
      return Icon(Icons.stars_rounded, color: Colors.yellow.shade700);
    default:
      return Icon(Icons.help_outline);
  }
}

/// Full card definition except Number/Extension/Rarity
class PokemonCardData {
  List<Pokemon>    title;
  Level            level;
  TypeCard         type;
  TypeCard?        typeExtended; //Double energy can exists but less than 20 card !
  Illustrator?     illustrator;
  CardMarkers      markers;
  CardEffects      cardEffects = CardEffects();
  int              life;
  int              retreat;
  EnergyValue?     resistance;
  EnergyValue?     weakness;
  Design           design = Design.Basic;

  PokemonCardData(this.title, this.level, this.type, this.markers, [this.design = Design.Basic, this.life=0, this.retreat=0, this.resistance, this.weakness]) {
    if( this.retreat > 5)
      this.retreat = 0;
  }

  String titleOfCard(Language l) {
    List<String> name = [];
    title.forEach((pokemon) {
      name.add(pokemon.titleOfCard(l));
    });
    return name.join("&");
  }

  PokemonCardData.empty() : title=[], level=Level.Base, type=TypeCard.Unknown, markers=CardMarkers(), life=0, retreat=0;
}

class PokemonCardExtension {
  PokemonCardData  data;
  Rarity           rarity;
  String           image = "";
  int              jpDBId = 0;
  String           specialID = ""; /// For card without number or special (like energy, celebration card, ...)
  List<CardSet>    sets=[];
  bool             isSecret = false;
  String           finalImage = ""; /// Cached to retrive final image when found

  String numberOfCard(int id) {
    return specialID.isNotEmpty ? specialID : (id + 1).toString();
  }

  bool hasMultiSet() {
    return sets.length > 1;
  }

  PokemonCardExtension.empty(this.data, this.rarity, {this.image="", this.jpDBId=0, this.specialID="", this.isSecret=false});

  PokemonCardExtension.creation(this.data, this.rarity, Map allSets, {this.image="", this.jpDBId=0, this.specialID="", this.isSecret=false}) {
    computeDefaultSet(allSets);
  }

  void computeDefaultSet(Map allSets) {
    if(Environment.instance.collection.japanRarity.contains(rarity)) {
      sets.add(allSets[0]);
    } else {
      if( rarity.id < 6 )
        sets.add(allSets[0]);
      else
        sets.add(allSets[1]);

      if( rarity.id <= 6 )
        sets.add(allSets[2]);
    }
  }

  PokemonCardExtension.fromBytesV3(ByteParser parser, Map collection, Map allSets, Map allRarities) :
    data   = collection[parser.extractInt16()],
    rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e){

    }
    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV4(ByteParser parser, Map collection, Map allSets, Map allRarities) :
    data   = collection[parser.extractInt16()],
    rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e){

    }
    image  = parser.decodeString16();
    int otherData = parser.extractInt8();
    assert(otherData == 0); //Not used

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV5(ByteParser parser, Map collection, Map allSets, Map allRarities) :
    data   = collection[parser.extractInt16()],
    rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e){

    }
    image  = parser.decodeString16();
    jpDBId = parser.extractInt32();

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV6(ByteParser parser, Map collection, Map allSets, Map allRarities) :
    data   = collection[parser.extractInt16()],
    rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e){

    }

    image     = parser.decodeString16();
    jpDBId    = parser.extractInt32();
    specialID = parser.decodeString16();

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytes(ByteParser parser, Map collection, Map allSets, Map allRarities) :
    data   = collection[parser.extractInt16()],
    rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e, callStack){
      printOutput("Card info unknown: $e\n$callStack");
    }

    image     = parser.decodeString16();
    jpDBId    = parser.extractInt32();
    specialID = parser.decodeString16();

    var nbSets = parser.extractInt8();
    for(int i = 0; i < nbSets; i +=1){
      sets.add(allSets[parser.extractInt8()]);
    }
    isSecret = parser.extractInt8() == 1;
  }

  List<int> toBytes(Map rCollection, Map rSet, Map rRarity) {
    assert(rCollection.isNotEmpty); // Admin condition

    int idCard = rCollection[data];
    assert(idCard != 0);

    var imageCode    = ByteEncoder.encodeString16(image.codeUnits);
    var specialImage = ByteEncoder.encodeString16(specialID.codeUnits);
    var setsInfo     = [sets.length];
    for(var s in sets) {
      setsInfo.add(rSet[s]);
    }

    return ByteEncoder.encodeInt16(idCard) +
        <int>[rRarity[rarity]] +
        imageCode +
        ByteEncoder.encodeInt32(jpDBId) +
        specialImage +
        setsInfo + <int>[isSecret ? 1 : 0];
  }

  bool isValid() {
    return data.type!= TypeCard.Unknown && rarity != Environment.instance.collection.unknownRarity;
  }

  List<Widget> imageRarity(Language l) {
    return getImageRarity(rarity, l);
  }

  Widget imageType({bool generate=false, double? sizeIcon}) {
    return getImageType(data.type, generate: generate, sizeIcon: sizeIcon);
  }
  Widget? imageTypeExtended({bool generate=false, double? sizeIcon}) {
    return data.typeExtended != null ? getImageType(data.typeExtended!, generate: generate, sizeIcon: sizeIcon) : null;
  }

  bool hasAnotherRendering() {
    return !isValid() || hasMultiSet();
  }

  /*
  Mode defaultMode() {
    return data.design == Design.Holographic ? Mode.Halo : Mode.Normal;
  }
   */

  bool isForReport() {
    return Environment.instance.collection.goodCard.contains(rarity);
  }

  Widget? showImportantMarker(Language l, {double? height}) {
    for(var m in data.markers.markers) {
      if(m.toTitle) {
        return pokeMarker(l, m, height: height);
      }
    }
    return null;
  }

  bool isGoodCard() {
    return isValid() && Environment.instance.collection.goodCard.contains(rarity);
  }
}

class SubExtensionCards {
  List<List<PokemonCardExtension>> cards;           ///< Main Card of set (numbered)
  List<CodeNaming>                 codeNaming = [];
  bool                             isValid;         ///< Data exists (Not waiting fill)

  List<PokemonCardExtension>       energyCard     = []; ///< Energy card design
  List<PokemonCardExtension>       noNumberedCard = []; ///< Card without number

  int                              configuration;

  SubExtensionCards(List<List<PokemonCardExtension>> cards, this.codeNaming, this.configuration) : this.cards = cards, this.isValid = cards.length > 0;

  static const int _hasBoosterEnergy  = 1;
  static const int _hasAlternativeSet = 2;
  static const int _notInsideRandom   = 4;

  static const int version = 7;

  String tcgImage(idCard) {
    if(codeNaming.isNotEmpty) {
      for(var element in codeNaming) {
        if( idCard >= element.idStart) {
          if(element.naming.contains("%s")) {
            if (element.naming.startsWith("SV")) {
              String val = (idCard - element.idStart + 1).toString().padLeft(3, '0');
              return sprintf(element.naming, [val]);
            }
          } else {
            return sprintf(element.naming, [(idCard - element.idStart + 1)]);
          }
        }
      }
    }
    return (idCard+1).toString();
  }

  PokemonCardExtension extractCard(int currentVersion, parser, Map cardCollection, Map allSets, Map rarities) {
    if(currentVersion == 7)
      return PokemonCardExtension.fromBytes(parser, cardCollection, allSets, rarities);
    if(currentVersion == 6)
      return PokemonCardExtension.fromBytesV6(parser, cardCollection, allSets, rarities);
    else if(currentVersion == 5)
      return PokemonCardExtension.fromBytesV5(parser, cardCollection, allSets, rarities);
    else if(currentVersion == 4)
      return PokemonCardExtension.fromBytesV4(parser, cardCollection, allSets, rarities);
    else if (currentVersion == 3)
      return PokemonCardExtension.fromBytesV3(parser, cardCollection, allSets, rarities);
    else
      throw StatitikException("Unknown version of card");
  }

  List<PokemonCardExtension> extractOtherCards(List<int>? byteCard, Map cardCollection, Map allSets, Map rarities) {
    List<PokemonCardExtension> listCards = [];
    if(byteCard != null) {
      final currentVersion = byteCard[0];
      if(6 <= currentVersion && currentVersion <= 7) {
        List<int> binary = gzip.decode(byteCard.sublist(1));
        var parser = ByteParser(binary);

        // Extract card
        while(parser.canParse) {
          try {
            var newCard = extractCard(currentVersion, parser, cardCollection, allSets, rarities);
            listCards.add(newCard);
          } catch (e, callStack) {
            printOutput("OtherCard issue: Skip card\n$e\n$callStack");
          }
        }
      } else
        throw StatitikException("Bad SubExtensionCards version : need migration !");
    }
    return listCards;
  }

  SubExtensionCards.build(List<int> bytes, this.codeNaming, Map cardCollection, Map allSets, Map rarities, this.configuration, List<int>? energy, List<int>? noNumber) : this.cards=[], this.isValid = (bytes.length > 0) {
    final currentVersion = bytes[0];
    if(3 <= currentVersion && currentVersion <= 7) {
      var parser = ByteParser(gzip.decode(bytes.sublist(1)));
      // Extract card
      while(parser.canParse) {
        List<PokemonCardExtension> numberedCard = [];
        int nbTitle = parser.extractInt8();
        for( int cardId=0; cardId < nbTitle; cardId +=1) {
          numberedCard.add(extractCard(currentVersion, parser, cardCollection, allSets, rarities));
        }
        cards.add(numberedCard);
      }
    } else
      throw StatitikException("Bad SubExtensionCards version : need migration !");

    energyCard     = extractOtherCards(energy,   cardCollection, allSets, rarities);
    noNumberedCard = extractOtherCards(noNumber, cardCollection, allSets, rarities);
  }

  SubExtensionCards.emptyDraw(this.codeNaming, this.configuration, Map allSets) : cards = [], isValid=false {
    // Build pre-publication: 300 card max
    for (int i = 0; i < 300; i += 1) {
      var card = PokemonCardExtension.empty(PokemonCardData.empty(), Environment.instance.collection.unknownRarity!);
      card.sets.add(allSets[0]);
      card.sets.add(allSets[2]);

      cards.add([card]);
    }
  }

  bool hasBoosterEnergy() {
    return mask(configuration, _hasBoosterEnergy) && energyCard.isNotEmpty;
  }

  bool hasAlternativeSet() {
    return mask(configuration, _hasAlternativeSet);
  }

  /// Booster of this extension can't be found any random product
  bool notInsideRandom() {
    return mask(configuration, _notInsideRandom);
  }

  List<int> computeIdCard(PokemonCardExtension card) {
    int id=0;
    for(var subCards in cards) {
      int subId=0;
      for(var subCard in subCards) {
        if (subCard == card) {
          return [0, id, subId];
        }
        subId +=1;
      }
      id += 1;
    }
    id=0;
    for(var subCard in energyCard) {
      if (subCard == card) {
        return [1, id];
      }
      id += 1;
    }
    id=0;
    for(var subCard in noNumberedCard) {
      if (subCard == card) {
        return [2, id];
      }
      id += 1;
    }
    return [];
  }

  String numberOfCard(int id) {
    if(isValid && id < cards.length && cards[id][0].specialID.isNotEmpty ) {
      return cards[id][0].specialID;
    } else {
      CodeNaming cn = CodeNaming();
      if (codeNaming.isNotEmpty) {
        codeNaming.forEach((element) {
          if (id >= element.idStart)
            cn = element;
        });
      }
      if (cn.naming.contains("%s"))
        return sprintf(cn.naming, [(id - cn.idStart + 1).toString()]);
      else
        return sprintf(cn.naming, [(id - cn.idStart + 1)]);
    }
  }

  String titleOfCard(Language l, int idCard, [int idAlternative=0]) {
    return idCard < cards.length
    ? cards[idCard][idAlternative].data.titleOfCard(l)
    : "";
  }

  List<int> toBytes(Map collectionCards, Map allSets, Map rarities) {
    List<int> cardBytes = [];
    cards.forEach((cardById) {
      // Add nb cards by number
      cardBytes.add(cardById.length);
      // Add card code
      cardById.forEach((card) {
        cardBytes += card.toBytes(collectionCards, allSets, rarities);
      });
    });

    List<int> finalBytes = [version];
    finalBytes += gzip.encode(cardBytes);

    printOutput("SubExtensionCards: data: ${cardBytes.length+1} compressed: ${finalBytes.length}");
    return finalBytes;
  }

  List<int> otherToBytes(List otherCards, Map collectionCards, Map allSets, Map rarities) {
    List<int> cardBytes = [];
    otherCards.forEach((card) {
      cardBytes += card.toBytes(collectionCards, allSets, rarities);
    });

    List<int> finalBytes = [version];
    finalBytes += gzip.encode(cardBytes);

    printOutput("SubExtensionCards: other Card data: ${cardBytes.length+1} compressed: ${finalBytes.length}");
    return finalBytes;
  }
}