import 'dart:io';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/draw/booster_draw.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/tools.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

abstract class ProductGeneric
{
  int               idDB;
  ProductCategory?  category;
  String            name;
  String            imageURL;
  DateTime          releaseDate;

  ProductGeneric(this.idDB, this.category, this.name, this.imageURL, this.releaseDate);

  Widget image();
}

class ProductSide extends ProductGeneric
{
  ProductSide.empty() : super(0, null, "", "", DateTime.now());

  ProductSide(idDB, category, name, imageURL, releaseDate) : super(idDB, category, name, imageURL, releaseDate);

  @override
  Widget image()
  {
    return drawCachedImage('sideProducts', imageURL, height: 70);
  }
}

class ProductBooster
{
  SubExtension? subExtension;
  int           nbBoosters;
  int           nbCardsPerBooster;

  ProductBooster(this.subExtension, this.nbBoosters, this.nbCardsPerBooster);
}

class ProductCard {
  SubExtension          subExtension;
  late PokemonCardExtension  card;
  AlternativeDesign     design;       /// Think more about it but keep space !
  bool                  jumbo;
  bool                  isRandom;
  CodeDraw              counter;   /// Counter inside BY PRODUCT ONLY: Not limited to 7 !!

  static const int _jumboMask  = 1;
  static const int _randomMask = 2;

  ProductCard(this.subExtension, this.card, this.design, this.jumbo, this.isRandom, this.counter);

  ProductCard.fromBytesV1(ByteParser parser, Map mapSubExtensions):
    subExtension = mapSubExtensions[parser.extractInt16()],
    design    = AlternativeDesign.values[parser.extractInt8()],
    jumbo     = false,
    isRandom  = false,
    counter   = CodeDraw.fromSet(1)
  {
    var code = parser.extractInt8();
    jumbo     = mask(code, _jumboMask);
    isRandom  = mask(code, _randomMask);

    // Retrieve card
    var cardId = CardIdentifier.fromBytes(parser);
    card = subExtension.cardFromId(cardId);

    // Restore counter
    counter = CodeDraw.fromPokeCardExtension(card);
    var count = parser.extractInt8();
    for(int id=0; id < count; id +=1){
      if( id < card.sets.length) {
        counter.setCount(parser.extractInt8(), id);
      }
    }
  }

  ProductCard.fromBytes(ByteParser parser, Map mapSubExtensions):
        subExtension = mapSubExtensions[parser.extractInt16()],
        design    = AlternativeDesign.values[parser.extractInt8()],
        jumbo     = false,
        isRandom  = false,
        counter   = CodeDraw.fromSet(1)
  {
    var code = parser.extractInt8();
    jumbo     = mask(code, _jumboMask);
    isRandom  = mask(code, _randomMask);

    // Retrieve card
    var cardId = CardIdentifier.fromBytes(parser);
    card = subExtension.cardFromId(cardId);

    // Restore counter
    counter = CodeDraw.fromBytes(parser);
  }

  List<int> toBytes() {
    assert(counter.nbSetsRegistred() > 0);
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt16(subExtension.id);
    bytes += ByteEncoder.encodeInt8(design.index);
    int code = (jumbo ? _jumboMask : 0) | (isRandom ? _randomMask : 0);
    bytes += ByteEncoder.encodeInt8(code);

    // Encode card full Id
    var id = subExtension.seCards.computeIdCard(card)!;
    bytes += id.toBytes();

    // Encode counter
    bytes += counter.toBytes();
    return bytes;
  }
}

class Product extends ProductGeneric
{
  List<ProductBooster>     boosters;
  Language?                language;

  // New
  Map<ProductSide, int>    sideProducts = {};
  List<ProductCard>        otherCards   = [];
  int                      nbRandomPerProduct = 0;
  static const int version = 3;

  Product.empty():
    boosters = [],
    super(-1, null, "", "", DateTime.now());

  Product(idDB, this.language, name, imageURL, outDate, category, this.boosters):
    super(idDB, category, name, imageURL, outDate);

  Product.fromBytes(idDB, this.language, name, imageURL, outDate, category,
      List<int> data, Map mapSubExtensions, Map productSides):
        boosters = [],
        super(idDB, category, name, imageURL, outDate)
  {
    int currentVersion = data[0];
    if(!(currentVersion <= version)) {
      throw StatitikException("Unknown Product version: ${data[0]}");
    }

    // Is Zip ?
    List<int> bytes = (data[1] == 1) ? gzip.decode(data.sublist(2)) : data.sublist(2);
    ByteParser parser = ByteParser(bytes);

    // Read boosters
    var nbBoosters = parser.extractInt8();
    for(int id=0; id < nbBoosters; id +=1){
      var idSe = parser.extractInt16();
      var pb = ProductBooster(idSe == 0 ? null : mapSubExtensions[idSe]!, parser.extractInt8(), parser.extractInt8());
      //printOutput("$name: ${pb.subExtension != null ? pb.subExtension!.name : "No se"}");
      boosters.add(pb);
    }
    assert(boosters.isNotEmpty);

    // Read other products
    var nbSideProducts = parser.extractInt8();
    for(int id=0; id < nbSideProducts; id +=1){
      var idSP = parser.extractInt32();
      sideProducts[productSides[idSP]] = parser.extractInt8();
    }

    // Read other cards
    if(currentVersion == 2) {
      var nbOtherCards = parser.extractInt8();
      for(int id=0; id < nbOtherCards; id +=1){
        otherCards.add(ProductCard.fromBytesV1(parser, mapSubExtensions));
      }
    } else if(currentVersion == 3) {
      var nbOtherCards = parser.extractInt8();
      for(int id=0; id < nbOtherCards; id +=1) {
        otherCards.add(ProductCard.fromBytes(parser, mapSubExtensions));
      }
    }

    if(currentVersion == 2 || currentVersion == 3) {
      nbRandomPerProduct = parser.extractInt8();
    }
  }

  List<int> toBytes() {
    List<int> bytes = [];

    // Save boosters
    assert(boosters.length <= 255);
    bytes += ByteEncoder.encodeInt8(boosters.length);
    boosters.forEach((booster) {
      bytes += ByteEncoder.encodeInt16(booster.subExtension != null ? booster.subExtension!.id : 0);
      assert(booster.nbBoosters <= 255);
      bytes += ByteEncoder.encodeInt8(booster.nbBoosters);
      assert(booster.nbCardsPerBooster <= 255);
      bytes += ByteEncoder.encodeInt8(booster.nbCardsPerBooster);
    });

    // Save other products
    assert(sideProducts.length <= 255);
    bytes += ByteEncoder.encodeInt8(sideProducts.length);
    sideProducts.forEach((pa, count) {
      assert(count <= 255);
      bytes += ByteEncoder.encodeInt32(pa.idDB);
      bytes += ByteEncoder.encodeInt8(count);
    });

    // Save other cards
    assert(otherCards.length <= 255);
    bytes += ByteEncoder.encodeInt8(otherCards.length);
    otherCards.forEach((card) {
      bytes += card.toBytes();
    });
    
    assert(nbRandomPerProduct <= 255);
    bytes += ByteEncoder.encodeInt8(nbRandomPerProduct);

    // Save final data
    assert(version <= 255);
    List<int> zipBytes = gzip.encode(bytes);
    printOutput("Product: data: ${bytes.length} compressed: ${zipBytes.length}");

    bool needZip = bytes.length < zipBytes.length;
    return [version, needZip ? 1 : 0] + (needZip ? zipBytes : bytes);
  }

  bool hasImages() {
    return imageURL.isNotEmpty;
  }

  @override
  Widget image() {
    return drawCachedImage('products', imageURL, height: 70);
  }

  int countBoosters() {
    int count=0;
    boosters.forEach((value) { count += value.nbBoosters; });
    return count;
  }

  List<BoosterDraw> buildBoosterDraw() {
    var list = <BoosterDraw>[];
    int id=1;
    boosters.forEach((value) {
      for( int i=0; i < value.nbBoosters; i+=1) {
        list.add( BoosterDraw(creation: value.subExtension, id: id, nbCards: value.nbCardsPerBooster) );
        id += 1;
      }
    });
    return list;
  }

  /// Validate before send request
  bool validate() {
    return boosters.isNotEmpty && language != null && category != null;
  }
}

class ProductRequested
{
  Product     product;
  final Color color;
  final int   count;

  ProductRequested(this.product, this.color, this.count);
}

bool filter(Product product, Language l, SubExtension se, ProductCategory? category, Map userExtension, {bool onlyShowRandom=false}) {
  bool keep = product.language == l;
  // Filter language
  if( keep && category != null ) {
    keep = product.category == category;
  }
  // Keep user product only
  if( keep && userExtension.isNotEmpty ) {
    keep = userExtension.containsKey(product);
  }

  // Filter subextension
  if( keep ) {
    for(var booster in product.boosters) {
      if(!onlyShowRandom) {
        // Keep product of extension
        keep = booster.subExtension == se;
        if(keep) {
          break;
        }
      } else {
        if(se.seCards.notInsideRandom()) {
          keep = false;
        } else {
          if(userExtension.isNotEmpty) {
            // Search if user contains specific
            for (var subEx in userExtension[product]) {
              keep = se == subEx;
              if (keep) {
                break;
              }
            }
            if (keep) {
              break;
            }
          } else {
            // Search product with random
            for (var booster in product.boosters) {
              keep = booster.subExtension == null;
              if (keep) {
                break;
              }
            }
            // Keep product if after extension
            if (keep) {
              keep = (product.releaseDate.compareTo(se.out) >= 0);
            }
          }
        }
      }
    }
  }
  return keep;
}

Future<Map> filterProducts(Language l, SubExtension se, ProductCategory? category, {bool showAll=true, bool withUserCount=false, bool onlyWithUser=false, bool onlyLocalUser=false}) async
{
  printOutput("Filter: ${l.image} ${se.name} showRandom=$showAll computeUserCount=$withUserCount keepUserProduct=$onlyWithUser localUser=$onlyLocalUser");

  // Count all products
  Map<Product, int>                userCounts    = {};
  Map<Product, List<SubExtension>> userExtension = {};
  await Environment.instance.db.transactionR( (connection) async {
    if(withUserCount) {
      String query = "SELECT `idProduit`, COUNT(`idProduit`) as count"
          " FROM `UtilisateurProduit` "
          " GROUP BY `UtilisateurProduit`.`idProduit`;";
      var exts = await connection.query(query);
      for(var row in exts) {
        userCounts[Environment.instance.collection.products[row[0]]!] = row[1];
      }
    }

    if(onlyWithUser) {
      String query = "SELECT DISTINCT `idProduit`, `idSousExtension`"
      " FROM `UtilisateurProduit`, `TirageBooster`"
      " WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat`";
      if(onlyLocalUser) {
        query += " AND `UtilisateurProduit`.`idUtilisateur` = ${Environment.instance.user!.idDB};";
      }

      var exts = await connection.query(query);
      for(var row in exts) {
        var p = Environment.instance.collection.products[row[0]]!;
        if( !userExtension.containsKey(p)) {
          userExtension[p] = [];
        }

        userExtension[p]!.add( Environment.instance.collection.subExtensions[row[1]]! );
      }
    }
  });

  // Internal filter
  Map<ProductCategory, List<ProductRequested>> products = {};//.generate(Environment.instance.collection.categories.length, (index) { return []; });
  Environment.instance.collection.categories.forEach((key, category) { products[category] = [];});

  // Product of current extension
  Environment.instance.collection.products.values.forEach((product) {
    // Add to list
    if(filter(product, l, se, category, userExtension)) {
      products[product.category]!.add(ProductRequested(product, Colors.grey.shade600, userCounts[product] ?? 0));
    }
  });
  if(showAll) {
    // Product of with random booster
    Environment.instance.collection.products.values.forEach((product) {
      // Add to list
      if(filter(product, l, se, category, userExtension, onlyShowRandom: true)) {
        // Search product inside list
        bool find = false;
        for(var p in products[product.category]!) {
          find = (p.product == product);
          if(find) {
            break;
          }
        }
        // Add if missing
        if(!find) {
          products[product.category]!.add(ProductRequested(product, Colors.deepOrange.shade700, userCounts[product] ?? 0));
        }
      }
    });
  }
  return products;
}