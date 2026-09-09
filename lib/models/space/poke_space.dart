import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/space/poke_deck.dart';
import 'package:statitikcard/models/space/poke_user_card_counter.dart';
import 'package:statitikcard/services/environment.dart';

class PokeSpace
{
  Map<PokeLanguage, Map<PokeExpansion, PokeUserCardCounter>> myCards = {};
  //Map<PokeProduct,     UserProductCounter> myProducts     = {};
  //Map<PokeProductSide, UserProductCounter> mySideProducts = {};
  List<PokeDeck>                           myDecks        = [];

  DateTime lastestUpdate = DateTime.now();
  bool outOfDate = false;
  static const int version = 4;

  PokeSpace();


  PokeCardDraw cardCounter(PokeCardViewerIdentifier pcv) {
    var info = myCards[pcv.specificLanguage!]![pcv.expansion]!;
    switch(pcv.idCard.listId) {
      case 0:
        return info.cards[pcv.idCard.numberId][pcv.idCard.alternativeId];
      case 1:
        return info.energies[pcv.idCard.numberId];
      case 2:
        return info.noNumbers[pcv.idCard.numberId];
      default:
        throw StatitikException(ErrorCode.unknown, "Unknown list !");
    }
  }

  List<PokeLanguage> myLanguagesCard() {
    return myCards.keys.toList(growable: false);
  }
/*
  List<PokeLangage> myLanguagesProduct() {
    List<PokeLangage> languages = [];
    for (var product in myProducts.keys) {
      if(!languages.contains(product.language)) {
        languages.add(product.language!);
      }
    }
    return languages;
  }

  static PokeSpace fromBytes(List<int> data, Map subExtensions, Map products, Map sideProducts)
  {
    int localVersion = data[0];
    if(localVersion == 2) {
      return PokeSpace.fromBytesV2(data, subExtensions, products, sideProducts);
    } else if(localVersion == 3) {
      return PokeSpace.fromBytesV3(data, subExtensions, products, sideProducts);
    } else {
      throw StatitikException(ErrorCode.unknown, "Unknown Product version: ${data[0]}");
    }
  }

  /// Build space from database
  PokeSpace.fromBytesV2(List<int> data, Map subExtensions, Map products, Map sideProducts)
  {
    int localVersion = data[0];
    if(localVersion > version) {
      throw StatitikException(ErrorCode.unknown, "Unknown Product version: ${data[0]}");
    }

    // Is Zip ?
    List<int> bytes = (data[1] == 1) ? gzip.decode(data.sublist(2)) : data.sublist(2);
    ByteParser parser = ByteParser(bytes);

    int nbSubExtensions = parser.extractInt16();
    for(var id=0; id < nbSubExtensions; id +=1) {
      int idSE = parser.extractInt16();
      assert(subExtensions[idSE] != null, "Impossible to find SE: $idSE");
      var subExtension = subExtensions[idSE]!;
      insertSubExtension(subExtension);
      if(localVersion == 2) {
        myCards[subExtension]!.fromByte(parser);
      } else {
        myCards[subExtension]!.fromByteV1(parser);
      }
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

  /// Build space from database
  PokeSpace.fromBytesV3(List<int> data, Map subExtensions, Map products, Map sideProducts)
  {
    int localVersion = data[0];
    if(localVersion > version) {
      throw StatitikException(ErrorCode.unknown, "Unknown Product version: ${data[0]}");
    }

    // Is Zip ?
    List<int> bytes = (data[1] == 1) ? gzip.decode(data.sublist(2)) : data.sublist(2);
    ByteParser parser = ByteParser(bytes);

    int nbSubExtensions = parser.extractInt16();
    for(var id=0; id < nbSubExtensions; id +=1) {
      int idSE = parser.extractInt16();
      assert(subExtensions[idSE] != null, "Impossible to find SE: $idSE");
      var subExtension = subExtensions[idSE]!;
      insertSubExtension(subExtension);
      if(localVersion >= 2) {
        myCards[subExtension]!.fromByte(parser);
      } else {
        myCards[subExtension]!.fromByteV1(parser);
      }
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

    // Extract deck
    int nbDecks = parser.extractInt16();
    for(var id=0; id < nbDecks; id +=1) {
      myDecks.add(Deck.fromBytes(parser, subExtensions));
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

    // My decks
    bytes += ByteEncoder.encodeInt16(myDecks.length);
    for (var deck in myDecks) {
      bytes += deck.toBytes();
    }

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
      for (var productCard in product.otherCards) {
        insertSubExtension(productCard.expansion);
        var result = myCards[productCard.expansion]!.addProductCard(productCard, counter.opened);
        if(result != null && report!=null) {
          report.add(productCard.expansion, result);
        }
      }

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
    if(currentValue != null && myCards.isNotEmpty) {
      return Map.from(myCards)..removeWhere((subExt, v) => subExt.extension.language != currentValue );
    } else {
      return {};
    }
  }

  NewCardsReport insertSessionDraw(SessionDraw draw) {
    var myNewCard = NewCardsReport();

    for (var booster in draw.boosterDraws) {
      if(booster.cardDrawing != null) {
        insertSubExtension(booster.expansion!);
        myCards[booster.expansion!]!.add(booster.cardDrawing!, myNewCard);
      }
    }

    // Add new product
    insertProduct(draw.product, UserProductCounter.fromOpened(), report: myNewCard);

    // Add random product draw
    draw.productDraw.randomProductCard.forEach((productDraw, counter) {
      if(counter.count() > 0) {
        insertSubExtension(productDraw.expansion);
        myCards[productDraw.expansion]!.addRandomCard(productDraw, counter, myNewCard);
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
  */
}