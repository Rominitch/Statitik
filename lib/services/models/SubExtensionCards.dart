import 'dart:io';

import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/models.dart';

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

  static const int version = 8;

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

  int countNbLists() {
    int count = 0;
    if(cards.isNotEmpty)
      count += 1;
    if(energyCard.isNotEmpty)
      count += 1;
    if(noNumberedCard.isNotEmpty)
      count += 1;
    return count;
  }

  PokemonCardExtension extractCard(int currentVersion, parser, Map cardCollection, Map allSets, Map rarities) {
    try {
      if(currentVersion == 8)
        return PokemonCardExtension.fromBytes(parser, cardCollection, allSets, rarities);
      else if(currentVersion == 7)
        return PokemonCardExtension.fromBytesV7(parser, cardCollection, allSets, rarities);
      else if(currentVersion == 6)
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
    catch(error) {
      printOutput("Extract card error: version $currentVersion : ${error.toString()}");
      throw error;
    }
  }

  List<PokemonCardExtension> extractOtherCards(List<int>? byteCard, Map cardCollection, Map allSets, Map rarities) {
    List<PokemonCardExtension> listCards = [];
    if(byteCard != null) {
      final currentVersion = byteCard[0];
      if(6 <= currentVersion && currentVersion <= version) {
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
        throw StatitikException("SubExtensionCards: need migration ($currentVersion < $version");
    }
    return listCards;
  }

  SubExtensionCards.build(List<int> bytes, this.codeNaming, Map cardCollection, Map allSets, Map rarities, this.configuration, List<int>? energy, List<int>? noNumber) : this.cards=[], this.isValid = (bytes.length > 0) {
    final currentVersion = bytes[0];
    if(3 <= currentVersion && currentVersion <= version) {
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
      throw StatitikException("SubExtensionCards: need migration ($currentVersion < $version");

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

  PokemonCardExtension cardFromId(CardIdentifier cardId) {
    switch(cardId.listId){
      case 0: {
        return cards[cardId.numberId][cardId.alternativeId];
      }
      case 1: {
        return energyCard[cardId.numberId];
      }
      case 2: {
        return noNumberedCard[cardId.numberId];
      }
      default:
        throw StatitikException("Unknown list");
    }
  }

  CardIdentifier? computeIdCard(PokemonCardExtension card) {
    int id=0;
    for(var subCards in cards) {
      int subId=0;
      for(var subCard in subCards) {
        if (subCard == card) {
          return CardIdentifier.from([0, id, subId]);
        }
        subId +=1;
      }
      id += 1;
    }
    id=0;
    for(var subCard in energyCard) {
      if (subCard == card) {
        return CardIdentifier.from([1, id]);
      }
      id += 1;
    }
    id=0;
    for(var subCard in noNumberedCard) {
      if (subCard == card) {
        return CardIdentifier.from([2, id]);
      }
      id += 1;
    }
    return null;
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

  String readTitleOfCard(Language l, CardIdentifier idCard) {
    return cardFromId(idCard).data.titleOfCard(l);
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

  CardIdentifier? nextId(CardIdentifier id) {
    int nextId = id.numberId+1;
    switch(id.listId){
      case 0: {
        return nextId < cards.length ? CardIdentifier.from([id.listId, nextId, 0]): null;
      }
      case 1: {
        return nextId < energyCard.length ? CardIdentifier.from([id.listId, nextId]): null;
      }
      case 2: {
        return nextId < noNumberedCard.length ? CardIdentifier.from([id.listId, nextId]): null;
      }
      default:
        throw StatitikException("Unknown list");
    }
  }

  cardList(CardIdentifier id) {
    switch(id.listId){
      case 0: {
        return cards;
      }
      case 1: {
        return energyCard;
      }
      case 2: {
        return noNumberedCard;
      }
      default:
        throw StatitikException("Unknown list");
    }
  }
}