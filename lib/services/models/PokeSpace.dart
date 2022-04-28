import 'dart:io';

import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Draw/SessionDraw.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/NewCardsReport.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
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
            if( userSubCards.current.count() > 0) {
              if(countByRarity.containsKey(card.rarity))
                countByRarity[card.rarity] = countByRarity[card.rarity]! + 1;
              else
                countByRarity[card.rarity] = 1;

              if(card.isSecret)
                countSecret += 1;
              else
                countOfficial += 1;

              int idSet=0;
              card.sets.forEach((set) {
                if(idSet < userSubCards.current.nbSetsRegistred()) {
                  if(userSubCards.current.countBySet(idSet) > 0) {
                    if(countBySet.containsKey(set))
                      countBySet[set] = countBySet[set]! + 1;
                    else
                      countBySet[set] = 1;
                  }
                }
                idSet += 1;
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
        return CodeDraw.fromPokeCardExtension(subExtension.seCards.cards[index][subIndex]);
      });
    });

    energies = List<CodeDraw>.generate(subExtension.seCards.energyCard.length, (index) {
      return CodeDraw.fromPokeCardExtension(subExtension.seCards.energyCard[index]);
    });

    noNumbers = List<CodeDraw>.generate(subExtension.seCards.noNumberedCard.length, (index) {
      return CodeDraw.fromPokeCardExtension(subExtension.seCards.noNumberedCard[index]);
    });
  }

  void fromByte(ByteParser parser) {
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

    var countECards = parser.extractInt16();
    for(var idCards = 0; idCards < countECards; idCards += 1) {
      var code = CodeDraw.fromBytes(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < energies.length )
        energies[idCards] = code;
    }

    var countNCards = parser.extractInt16();
    for(var idCards = 0; idCards < countNCards; idCards += 1) {
      var code = CodeDraw.fromBytes(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < noNumbers.length )
        noNumbers[idCards] = code;
    }
  }

  void fromByteV1(ByteParser parser) {
    int countCards = parser.extractInt16();
    for(var idCards = 0; idCards < countCards; idCards += 1) {
      int countSub  = parser.extractInt8();
      for(var idSubCards = 0; idSubCards < countSub; idSubCards += 1) {
        var code = CodeDraw.fromBytesV1(parser);
        // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
        if(idCards < cards.length && idSubCards < cards[idCards].length)
          cards[idCards][idSubCards] = code;
      }
    }

    var countECards = parser.extractInt16();
    for(var idCards = 0; idCards < countECards; idCards += 1) {
      var code = CodeDraw.fromBytesV1(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < energies.length )
        energies[idCards] = code;
    }

    var countNCards = parser.extractInt16();
    for(var idCards = 0; idCards < countNCards; idCards += 1) {
      var code = CodeDraw.fromBytesV1(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < noNumbers.length )
        noNumbers[idCards] = code;
    }
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

    bytes += ByteEncoder.encodeInt16(energies.length);
    energies.forEach((code) {
      bytes += code.toBytes();
    });

    bytes += ByteEncoder.encodeInt16(noNumbers.length);
    noNumbers.forEach((code) {
      bytes += code.toBytes();
    });
    return bytes;
  }

  void add(ExtensionDrawCards edc, [NewCardsReport? report]) {
    int idCard = 0;
    var subCard = cards.iterator;
    edc.drawCards.forEach((element) {
      if(subCard.moveNext()) {
        addList(subExtension, element, subCard.current, [0, idCard], report);
        idCard += 1;
      }
    });

    addList(subExtension, edc.drawEnergies, energies, [1], report);
  }

  void addRandomCard(ProductCard card, CodeDraw counter, [NewCardsReport? report]) {
    var idCard = card.subExtension.seCards.computeIdCard(card.card)!;

    var code;
    switch(idCard.listId) {
      case 0:
        code = cards[idCard.numberId][idCard.alternativeId].add(counter);
        break;
      case 1:
        code = energies[idCard.numberId].add(counter);
        break;
      case 2:
        code = noNumbers[idCard.numberId].add(counter);
        break;
      default:
        throw StatitikException("Missing list !");
    }
    if(code != null && report!= null) {
      report.add(card.subExtension, NewCardReport(idCard, code));
    }
  }

  void addList(SubExtension se, List<CodeDraw> from, List<CodeDraw> to, List<int> listId, [NewCardsReport? report]) {
    int idCard = 0;
    var dstCode = to.iterator;
    from.forEach((cardCode) {
      if(dstCode.moveNext()) {
        var code = dstCode.current.add(cardCode);
        if(code != null && report!= null) {
          report.add(se, NewCardReport(CardIdentifier.from(listId + [idCard]), code));
        }
        idCard +=1;
      }
    });
  }

  NewCardReport? addProductCard(ProductCard productCard, [int mulFactor=1]) {
    assert(productCard.subExtension == subExtension);
    if( !productCard.isRandom ) {
      CodeDraw? report;
      var idCards = subExtension.seCards.computeIdCard(productCard.card)!;
      switch(idCards.listId) {
        case 0:
          if (idCards.numberId < cards.length &&
              idCards.alternativeId < cards[idCards.numberId].length)
            report = cards[idCards.numberId][idCards.alternativeId].add(
                productCard.counter, mulFactor);
          break;
        case 1:
          if (idCards.numberId < energies.length)
            report = energies[idCards.numberId].add(productCard.counter, mulFactor);
          break;
        case 2:
          if (idCards.numberId < noNumbers.length)
            report = noNumbers[idCards.numberId].add(productCard.counter, mulFactor);
          break;
        default:
          throw StatitikException("Unknown List");
      }
      return (report != null) ? NewCardReport(idCards, report) : null;
    }
    return null;
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
  static const int version = 2;

  PokeSpace();

  CodeDraw cardCounter(SubExtension subExtension, CardIdentifier idCard) {
    var info = myCards[subExtension]!;
    switch(idCard.listId) {
      case 0:
        return info.cards[idCard.numberId][idCard.alternativeId];
      case 1:
        return info.energies[idCard.numberId];
      case 2:
        return info.noNumbers[idCard.numberId];
      default:
        throw StatitikException("Unknown list !");
    }
  }

  List<Language> myLanguagesCard() {
    List<Language> languages = [];
    myCards.keys.forEach((subExtension) {
      if(!languages.contains(subExtension.extension.language)) {
        languages.add(subExtension.extension.language);
      }
    });
    return languages;
  }

  List<Language> myLanguagesProduct() {
    List<Language> languages = [];
    myProducts.keys.forEach((product) {
      if(!languages.contains(product.language)) {
        languages.add(product.language!);
      }
    });
    return languages;
  }

  /// Build space from database
  PokeSpace.fromBytes(List<int> data, Map subExtensions, Map products, Map sideProducts)
  {
    int localVersion = data[0];
    if(localVersion > version)
      throw StatitikException("Unknown Product version: ${data[0]}");

    // Is Zip ?
    List<int> bytes = (data[1] == 1) ? gzip.decode(data.sublist(2)) : data.sublist(2);
    ByteParser parser = ByteParser(bytes);

    int nbSubExtensions = parser.extractInt16();
    for(var id=0; id < nbSubExtensions; id +=1) {
      int idSE = parser.extractInt16();
      assert(subExtensions[idSE] != null, "Impossible to find SE: $idSE");
      var subExtension = subExtensions[idSE]!;
      insertSubExtension(subExtension);
      if(localVersion == 2)
        myCards[subExtension]!.fromByte(parser);
      else
        myCards[subExtension]!.fromByteV1(parser);
    }

    int nbProducts = parser.extractInt16();
    for(var id=0; id < nbProducts; id +=1) {
      var product = products[parser.extractInt16()]!;
      insertProduct(product, UserProductCounter.fromBytes(parser), addCardAndMore: false);
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
      assert(subExt.id > 0);
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

  void insertProduct(Product product, UserProductCounter counter, {NewCardsReport? report, bool addCardAndMore=true}) {
    // Added new product
    if( myProducts.containsKey(product) ) {
      myProducts[product]!.cumulate(counter);
    } else {
      myProducts[product] = counter;
    }

    // Fill container if opened
    if(addCardAndMore && counter.opened > 0) {
      // Side product
      product.sideProducts.forEach((sideProduct, count) {
        insertSideProduct(sideProduct, UserProductCounter.fromOpened( counter.opened * count));
      });
      // Cards
      product.otherCards.forEach((productCard) {
        insertSubExtension(productCard.subExtension);
        var result = myCards[productCard.subExtension]!.addProductCard(productCard, counter.opened);
        if(result != null && report!=null) {
          report.add(productCard.subExtension, result);
        }
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

  NewCardsReport insertSessionDraw(SessionDraw draw) {
    var myNewCard = NewCardsReport();

    draw.boosterDraws.forEach((booster) {
      if(booster.cardDrawing != null) {
        insertSubExtension(booster.subExtension!);
        myCards[booster.subExtension!]!.add(booster.cardDrawing!, myNewCard);
      }
    });

    // Add new product
    insertProduct(draw.product, UserProductCounter.fromOpened(), report: myNewCard);

    // Add random product draw
    draw.productDraw.randomProductCard.forEach((productDraw, counter) {
      if(counter.count() > 0) {
        insertSubExtension(productDraw.subExtension);
        myCards[productDraw.subExtension]!.addRandomCard(productDraw, counter, myNewCard);
      }
    });

    // Refresh state
    computeStats();

    return myNewCard;
  }

  Map getProductsBy(Language? language) {
    if(language != null) {
      return Map.from(myProducts)..removeWhere((product, info) => product.language! != language);
    } else {
      return mySideProducts;
    }
  }
}