import 'dart:io';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';

class StatsCardUser {
  int                  countOfficial = 0;
  int                  countSecret   = 0;
  Map<Rarity,  int>    countByRarity = {};
  Map<CardSet, int>    countBySet    = {};

  void computeStats(SubExtension subExtension, List<List<CodeDraw>> cards) {
    countOfficial = 0;
    countSecret   = 0;
    countByRarity = {};
    countBySet    = {};

    // Security
    assert(subExtension.seCards.cards.length == cards.length);

    var userCards = cards.iterator;
    subExtension.seCards.cards.forEach((subCards) {
      if(userCards.moveNext()) {
        assert(userCards.current.length == subCards.length);
        var userSubCards = userCards.current.iterator;
        subCards.forEach((card) {
          if(userSubCards.moveNext()) {
            if(userSubCards.current.count() > 0) {
              if(countByRarity.containsKey(card.rarity))
                countByRarity[card.rarity] = countByRarity[card.rarity]! + 1;
              else
                countByRarity[card.rarity] = 1;

              if(card.isSecret)
                countSecret += 1;
              else
                countOfficial += 1;

              var itUserSet = userSubCards.current.countBySet.iterator;
              card.sets.forEach((set) {
                if(itUserSet.moveNext()) {
                  if(itUserSet.current > 0) {
                    if(countBySet.containsKey(set))
                      countBySet[set] = countBySet[set]! + 1;
                    else
                      countBySet[set] = 1;
                  }
                }
              });
            }
          }
        });
      }
    });
  }
}

class UserCardCounter
{
  SubExtension         subExtension;
  List<List<CodeDraw>> cards     = [];
  List<CodeDraw>       energies  = [];
  List<CodeDraw>       noNumbers = [];

  StatsCardUser        statsCards = StatsCardUser();

  // Stats part
  UserCardCounter.fromSubExtension(this.subExtension) {
    cards = List<List<CodeDraw>>.generate(subExtension.seCards.cards.length, (index) {
      return List<CodeDraw>.generate(subExtension.seCards.cards[index].length, (subIndex) {
        return CodeDraw.fromSet(subExtension.seCards.cards[index][subIndex].sets.length);
      });
    });

    energies = List<CodeDraw>.generate(subExtension.seCards.energyCard.length, (index) {
      return CodeDraw.fromSet(subExtension.seCards.energyCard[index].sets.length);
    });

    noNumbers = List<CodeDraw>.generate(subExtension.seCards.noNumberedCard.length, (index) {
      return CodeDraw.fromSet(subExtension.seCards.noNumberedCard[index].sets.length);
    });
  }

  void fill(ByteParser parser) {
    int countCards = parser.extractInt16();
    for(var idCards = 0; idCards < countCards; idCards += 1) {
      int countSub  = parser.extractInt8();
      for(var idSubCards = 0; idSubCards < countSub; idSubCards += 1) {
        var code = CodeDraw.fromBytes(parser);
        // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
        if(idCards < cards.length && idSubCards < cards[idCards].length)
          cards[idCards][idSubCards] = code;
      }
    }

    countCards = parser.extractInt16();
    for(var idCards = 0; idCards < countCards; idCards += 1) {
      var code = CodeDraw.fromBytes(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < energies.length )
        energies[idCards] = code;
    }

    countCards = parser.extractInt16();
    for(var idCards = 0; idCards < countCards; idCards += 1) {
      var code = CodeDraw.fromBytes(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < noNumbers.length )
        noNumbers[idCards] = code;
    }

    computeStats();
  }

  void computeStats() {
    statsCards.computeStats(subExtension, cards);
  }

  List<int> toBytes() {
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt16(cards.length);
    cards.forEach((subCard) {
      bytes += ByteEncoder.encodeInt8(subCard.length);
      subCard.forEach((code) {
        bytes += code.toBytes();
      });
    });

    bytes += ByteEncoder.encodeInt16(cards.length);
    energies.forEach((code) {
      bytes += code.toBytes();
    });

    bytes += ByteEncoder.encodeInt16(cards.length);
    noNumbers.forEach((code) {
      bytes += code.toBytes();
    });
    return bytes;
  }

  void add(ExtensionDrawCards edc) {
    var subCard = cards.iterator;
    edc.drawCards.forEach((element) {
      if(subCard.moveNext()) {
        addList(element, subCard.current);
      }
    });

    addList(edc.drawEnergies, energies);
  }

  void addList(List<CodeDraw> from, List<CodeDraw> to) {
    var dstCode = to.iterator;
    from.forEach((cardCode) {
      if(dstCode.moveNext()) {
        dstCode.current.add(cardCode);
      }
    });
  }

  void addProductCard(ProductCard productCard, [int mulFactor=1]) {
    assert(productCard.subExtension == subExtension);
    var idCards = subExtension.seCards.computeIdCard(productCard.card);
    switch(idCards[0]) {
      case 0:
        assert(idCards.length == 3);
        if(idCards[1] < cards.length && idCards[2] < cards[idCards[1]].length)
          cards[idCards[1]][idCards[2]].add(productCard.counter, mulFactor);
      break;
      case 1:
        assert(idCards.length == 2);
        if(idCards[1] < energies.length)
          energies[idCards[1]].add(productCard.counter, mulFactor);
      break;
      case 2:
        assert(idCards.length == 2);
        if(idCards[1] < noNumbers.length)
          noNumbers[idCards[1]].add(productCard.counter, mulFactor);
      break;
      default:
        throw StatitikException("Unknown List");
    }
  }
}

class UserProductCounter
{
  int opened = 0;
  int seal   = 0;

  UserProductCounter.fromOpened([this.opened = 1]);

  UserProductCounter.fromBytes(ByteParser parser):
    opened = parser.extractInt8(),
    seal   = parser.extractInt8();

  void cumulate(UserProductCounter counter) {
    opened += counter.opened;
    seal   += counter.seal;
  }

  List<int> toBytes() {
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt8(opened);
    bytes += ByteEncoder.encodeInt8(seal);
    return bytes;
  }
}

class PokeSpace
{
  Map<SubExtension, UserCardCounter>    myCards        = {};
  Map<Product,      UserProductCounter> myProducts     = {};
  Map<ProductSide,  UserProductCounter> mySideProducts = {};

  bool outOfDate = false;
  static const int version = 1;

  PokeSpace();

  List<Language> myLanguagesCard() {
    List<Language> languages = [];
    myCards.keys.forEach((subExtension) {
      if(!languages.contains(subExtension.extension.language)) {
        languages.add(subExtension.extension.language);
      }
    });
    return languages;
  }

  /// Build space from database
  PokeSpace.fromBytes(List<int> data, Map subExtensions, Map products, Map sideProducts)
  {
    if(data[0] != version)
      throw StatitikException("Unknown Product version: ${data[0]}");

    // Is Zip ?
    List<int> bytes = (data[1] == 1) ? gzip.decode(data.sublist(2)) : data.sublist(2);
    ByteParser parser = ByteParser(bytes);

    int nbSubExtensions = parser.extractInt16();
    for(var id=0; id < nbSubExtensions; id +=1) {
      var subExtension = subExtensions[parser.extractInt16()]!;
      insertSubExtension(subExtension);
      myCards[subExtension]!.fill(parser);
    }

    int nbProducts = parser.extractInt16();
    for(var id=0; id < nbProducts; id +=1) {
      var product = products[parser.extractInt16()]!;
      insertProduct(product, UserProductCounter.fromBytes(parser));
    }

    int nbSideProducts = parser.extractInt16();
    for(var id=0; id < nbSideProducts; id +=1) {
      var product = sideProducts[parser.extractInt16()]!;
      insertSideProduct(product, UserProductCounter.fromBytes(parser));
    }

    // Finally compute all stats
    computeStats();
  }

  // Save in binary
  List<int> toBytes() {
    List<int> bytes = [];

    bytes += ByteEncoder.encodeInt16(myCards.length);
    myCards.forEach((subExt, counter) {
      bytes += ByteEncoder.encodeInt16(subExt.id);
      bytes += counter.toBytes();
    });

    bytes += ByteEncoder.encodeInt16(myProducts.length);
    myProducts.forEach((product, counter) {
      bytes += ByteEncoder.encodeInt16(product.idDB);
      bytes += counter.toBytes();
    });

    bytes += ByteEncoder.encodeInt16(mySideProducts.length);
    mySideProducts.forEach((product, counter) {
      bytes += ByteEncoder.encodeInt16(product.idDB);
      bytes += counter.toBytes();
    });

    // Save final data
    assert(version <= 255);
    List<int> zipBytes = gzip.encode(bytes);

    bool needZip = bytes.length < zipBytes.length;
    return [version, needZip ? 1 : 0] + (needZip ? zipBytes : bytes);
  }

  void insertSubExtension(SubExtension subExtension) {
    if( !myCards.containsKey(subExtension) ) {
      myCards[subExtension] = UserCardCounter.fromSubExtension(subExtension);
    }
  }

  void insertProduct(Product product, UserProductCounter counter) {
    // Added new product
    if( myProducts.containsKey(product) ) {
      myProducts[product]!.cumulate(counter);
    } else {
      myProducts[product] = counter;
    }

    // Fill container if opened
    if(counter.opened > 0) {
      // Side product
      product.sideProducts.forEach((sideProduct, count) {
        insertSideProduct(sideProduct, UserProductCounter.fromOpened( counter.opened * count));
      });
      // Cards
      product.otherCards.forEach((productCard) {
        insertSubExtension(productCard.subExtension);
        myCards[productCard.subExtension]!.addProductCard(productCard, counter.opened);
      });

      outOfDate |= product.otherCards.isNotEmpty;
    }
  }

  void insertSideProduct( ProductSide product, UserProductCounter counter) {
    if( mySideProducts.containsKey(product) ) {
      mySideProducts[product]!.cumulate(counter);
    } else {
      mySideProducts[product] = counter;
    }
  }

  void add(SubExtension subExt, ExtensionDrawCards edc) {
    insertSubExtension(subExt);
    myCards[subExt]!.add(edc);
  }

  void computeStats() {
    myCards.forEach((key, value) {
      value.computeStats();
    });
    outOfDate = false;
  }

  Map<SubExtension, UserCardCounter> getBy(Language? currentValue) {
    if(currentValue != null && myCards.isNotEmpty)
      return Map.from(myCards)..removeWhere((subExt, v) => subExt.extension.language != currentValue );
    else
      return {};
  }
}