import 'dart:io';

import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/models/database/poke_db_cards_blob.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeExpansionCards {
  List<CodeNaming>                 codeNaming     = [];
  List<List<PokeCardInExpansion>>  cards;           ///< Main Card of set (numbered)
  List<PokeCardInExpansion>        energyCard     = []; ///< Energy card design
  List<PokeCardInExpansion>        noNumberedCard = []; ///< Card without number

  int                              configuration;

  static const int                 dummyID = 0;

  PokeExpansionCards.fromDB(this.codeNaming, this.cards, this.energyCard, this.noNumberedCard, this.configuration);

  PokeExpansionCards.fromBytes(int version, BinaryReader r, PokeCollection collection) :
    cards          = PokeDbCardsBlob.readCards(version,r, collection),
    codeNaming     = r.readList((r) => CodeNaming.fromBytes(r)),
    energyCard     = PokeDbCardsBlob.readOther(version,r, collection),
    noNumberedCard = PokeDbCardsBlob.readOther(version,r, collection),
    configuration  = r.readInt32();

  void toBytes(BinaryWriter w) {
    PokeDbCardsBlob.writeCard(w, cards);
    w.writeList(codeNaming, (w, CodeNaming e) => e.toBytes(w));
    PokeDbCardsBlob.writeOther(w, energyCard);
    PokeDbCardsBlob.writeOther(w, noNumberedCard);
    w.writeInt32(configuration);
  }

  static const int codeHasBoosterEnergy  = 1;
  static const int codeHasAlternativeSet = 2;
  static const int codeNotInsideRandom   = 4;

  //static const int version = 9;

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

  bool isValid() { return cards.isNotEmpty; }

  int countNbLists() {
    int count = 0;
    if(cards.isNotEmpty) {
      count += 1;
    }
    if(energyCard.isNotEmpty) {
      count += 1;
    }
    if(noNumberedCard.isNotEmpty) {
      count += 1;
    }
    return count;
  }
/*
  PokemonCardExtension extractCard(int currentVersion, parser, Map cardCollection, Map allSets, Map rarities) {
    try {
      if(currentVersion == 9) {
        return PokemonCardExtension.fromBytesDB(parser, cardCollection, allSets, rarities);
      } else if(currentVersion == 8) {
        return PokemonCardExtension.fromBytesV8(parser, cardCollection, allSets, rarities);
      } else if(currentVersion == 7) {
        return PokemonCardExtension.fromBytesV7(parser, cardCollection, allSets, rarities);
      } else if(currentVersion == 6) {
        return PokemonCardExtension.fromBytesV6(parser, cardCollection, allSets, rarities);
      } else if(currentVersion == 5) {
        return PokemonCardExtension.fromBytesV5(parser, cardCollection, allSets, rarities);
      } else if(currentVersion == 4) {
        return PokemonCardExtension.fromBytesV4(parser, cardCollection, allSets, rarities);
      } else if (currentVersion == 3) {
        return PokemonCardExtension.fromBytesV3(parser, cardCollection, allSets, rarities);
      } else {
        throw StatitikException("Unknown version of card");
      }
    }
    catch(error) {
      printOutput("Extract card error: version $currentVersion : ${error.toString()}");
      rethrow;
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
            var newCard = extractCard( currentVersion, parser, cardCollection, allSets, rarities);
            listCards.add(newCard);
          } catch (e, callStack) {
            printOutput("OtherCard issue: Skip card\n$e\n$callStack");
          }
        }
      } else {
        throw StatitikException("SubExtensionCards: need migration ($currentVersion < $version");
      }
    }
    return listCards;
  }
 */
  /*
  PokeExpansionCards.build(this.id, List<int> bytes, this.codeNaming, Map cardCollection, Map allSets, Map rarities, this.configuration, List<int>? energy, List<int>? noNumber) :
        cards=[], isValid = bytes.isNotEmpty {
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
    } else {
      throw StatitikException("SubExtensionCards: need migration ($currentVersion < $version");
    }

    energyCard     = extractOtherCards(energy,   cardCollection, allSets, rarities);
    noNumberedCard = extractOtherCards(noNumber, cardCollection, allSets, rarities);
  }

  PokeExpansionCards.emptyDraw(this.id, this.codeNaming, this.configuration, Map allSets) : cards = [], isValid=false {
    // Build pre-publication: 300 card max
    for (int i = 0; i < 300; i += 1) {
      var card = PokemonCardExtension.empty(PokemonCardData.empty(), Environment.instance.collection.unknownRarity!);
      card.sets.add(allSets[0]);
      card.sets.add(allSets[2]);

      cards.add([card]);
    }
  }
  */

  bool hasBoosterEnergy() {
    return mask(configuration, codeHasBoosterEnergy) && energyCard.isNotEmpty;
  }

  bool hasAlternativeSet() {
    return mask(configuration, codeHasAlternativeSet);
  }

  /// Booster of this extension can't be found any random product
  bool notInsideRandom() {
    return mask(configuration, codeNotInsideRandom);
  }

  PokeCardInExpansion cardFromId(CardIdentifier cardId) {
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

  CardIdentifier? computeIdCard(PokeCardInExpansion card) {
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
    if(isValid() && id < cards.length && cards[id][0].specialID.isNotEmpty ) {
      return cards[id][0].specialID;
    } else {
      CodeNaming cn = CodeNaming();
      if (codeNaming.isNotEmpty) {
        for (var element in codeNaming) {
          if (id >= element.idStart) {
            cn = element;
          }
        }
      }
      if (cn.naming.contains("%s")) {
        return sprintf(cn.naming, [(id - cn.idStart + 1).toString()]);
      } else {
        return sprintf(cn.naming, [(id - cn.idStart + 1)]);
      }
    }
  }

  String titleOfCard(PokeLangage l, int idCard, [int idAlternative=0]) {
    return idCard < cards.length
        ? cards[idCard][idAlternative].card.titleOfCard(l)
        : "";
  }

  String readTitleOfCard(PokeLangage l, CardIdentifier idCard) {
    return cardFromId(idCard).card.titleOfCard(l);
  }
/*
  List<int> toBytesLocal(Map collectionCards, Map allSets, Map rarities) {
    List<int> cardBytes = [];
    for (var cardById in cards) {
      // Add nb cards by number
      cardBytes.add(cardById.length);
      // Add card code
      for (var card in cardById) {
        cardBytes += card.toBytesDB(collectionCards, allSets, rarities);
      }
    }

    List<int> finalBytes = [version];
    finalBytes += gzip.encode(cardBytes);

    printOutput("SubExtensionCards: data: ${cardBytes.length+1} compressed: ${finalBytes.length}");
    return finalBytes;
  }
*/
  /*
  List<int> otherToBytes(List otherCards, Map collectionCards, Map allSets, Map rarities) {
    List<int> cardBytes = [];
    for (var card in otherCards) {
      cardBytes += card.toBytes(collectionCards, allSets, rarities);
    }

    List<int> finalBytes = [version];
    finalBytes += gzip.encode(cardBytes);

    printOutput("SubExtensionCards: other Card data: ${cardBytes.length+1} compressed: ${finalBytes.length}");
    return finalBytes;
  }
  */

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