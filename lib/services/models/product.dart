import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/cardDrawData.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class ProductSide
{
  int             idDB;
  ProductCategory category;
  String          name;
  String          image;

  ProductSide(this.idDB, this.category, this.name, this.image);
}

class ProductBooster
{
  SubExtension? subExtension;
  int           nbBoosters;
  int           nbCardsPerBooster;

  ProductBooster(this.subExtension, this.nbBoosters, this.nbCardsPerBooster);
}

class Product
{
  int                      idDB;
  String                   name;
  String                   imageURL;
  List<ProductBooster>     boosters;
  Language?                language;
  ProductCategory?         category;
  DateTime                 outDate;
  // New
  Map<ProductSide, int>         sideProducts = {};
  Map<PokemonCardExtension, int>  otherCards    = {};
  static const int version = 1;

  Product.empty():
    this.idDB     =-1,
    this.outDate  = DateTime.now(),
    this.name     = "",
    this.imageURL = "",
    this.boosters = [];

  Product(this.idDB, this.language, this.name, this.imageURL, this.outDate, this.category, this.boosters);

  Product.fromBytes(this.idDB, this.language, this.name, this.imageURL, this.outDate, this.category,
                    List<int> data, Map subExtension, Map productSides, Map pokemonExt):
    this.boosters = []
  {
    if(data[0] != version)
      throw StatitikException("Unknown Product version: ${data[0]}");

    // Is Zip ?
    List<int> bytes = (data[1] == 1) ? gzip.decode(data.sublist(2)) : data.sublist(2);
    ByteParser parser = ByteParser(bytes);

    // Read boosters
    var nbBoosters = parser.extractInt8();
    for(int id=0; id < nbBoosters; id +=1){
      var idSe = parser.extractInt16();
      boosters.add(ProductBooster(idSe == 0 ? null : subExtension[idSe]!, parser.extractInt8(), parser.extractInt8()));
    }

    // Read other products
    var nbSideProducts = parser.extractInt8();
    for(int id=0; id < nbSideProducts; id +=1){
      var idSP = parser.extractInt32();
      sideProducts[productSides[idSP]] = parser.extractInt8();
    }

    // Read other cards
    var nbOtherCards = parser.extractInt8();
    for(int id=0; id < nbOtherCards; id +=1){
      var idCard = parser.extractInt32();
      otherCards[pokemonExt[idCard]] = parser.extractInt8();
    }
  }

  List<int> toBytes(Map rPokemonExt) {
    List<int> bytes = [];

    // Save boosters
    assert(boosters.length <= 255);
    bytes += ByteEncoder.encodeInt8(boosters.length);
    boosters.forEach((booster) {
      bytes += ByteEncoder.encodeInt16(booster.subExtension != null ? booster.subExtension!.id : 0);
      bytes += ByteEncoder.encodeInt8(booster.nbBoosters);
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
    otherCards.forEach((card, count) {
      assert(count <= 255);
      bytes += ByteEncoder.encodeInt32(rPokemonExt[card]);
      bytes += ByteEncoder.encodeInt8(count);
    });

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

  CachedNetworkImage image()
  {
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
        list.add(new BoosterDraw(creation: value.subExtension!, id: id, nbCards: value.nbCardsPerBooster));
        id += 1;
      }
    });
    return list;
  }

  /// Validate before send request
  bool validate() {
    return boosters.length > 0 && language != null && category != null;
  }
}

class ProductRequested
{
  Product     product;
  final Color color;
  final int   count;

  ProductRequested(this.product, this.color, this.count);
}

class ProductQuery {
  static Future<void> fillProd(Map produits, exts, color) async {
    for (var row in exts) {
      var product = Environment.instance.collection.products[row[0]];
      // Get category
      var cat = product.category;
      // Search already existing
      Iterable searching = produits[cat]!.where( (ProductRequested item) {return item.product == product;});
      if(searching.isEmpty) {
        produits[cat]!.add(ProductRequested(product, color, row[1]));
      }
    }
  }
}

/*
Future<Map> readProducts(Language l, SubExtension se, ProductCategory? categorie, SubExtension? containsSe, {bool showAll=true}) async
{
  Map<Category, List<ProductRequested>> products = {};//.generate(Environment.instance.collection.categories.length, (index) { return []; });
  Environment.instance.collection.categories.forEach((key, category) { products[category] = [];});

  Environment.instance.collection.products.values.forEach((product) {
    bool keep = product.language == l;
    // Filter language
    if( keep && categorie != null ) {
      keep = product.category == categorie;
    }
    // Filter subextension
    if( keep && containsSe != null ) {
      keep = product.boosters.containsKey(containsSe.id);
    }

    // Add to list
    if(keep) {
      products[product.category]!.add(product);
    }
  });

  return products;
}
*/

Future<Map> readProducts(Language l, SubExtension se, int? idCategorie, SubExtension? containsSe, {bool showAll=true}) async
{
  Map<ProductCategory, List<ProductRequested>> produits = {};
  Environment.instance.collection.categories.forEach((key, category) {
    produits[category] = [];
  });

  String subQueryCount = '''(SELECT COUNT(*) FROM `Produit` as P, `UtilisateurProduit`
WHERE `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit` 
AND P.`idProduit` = `Produit`.`idProduit`) as count ''';

  String filter = '';
  if(idCategorie != null) {
    filter = ' AND `Produit`.`idCategorie` = $idCategorie';
  }

  await Environment.instance.db.transactionR( (connection) async {
    String query = "SELECT `Produit`.`idProduit`, $subQueryCount FROM `Produit`, `ProduitBooster` "
        " WHERE `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` = ${se.id} $filter"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`nom` ASC";

    //printOutput(query);
    var exts = await connection.query(query);
    await ProductQuery.fillProd(produits, exts, Colors.grey[600]);

    if(showAll) {
      String tableSE = "";
      String filterSE = " AND `Produit`.`sortie` >= ${se.outDate()}";
      if( containsSe != null ) {
        tableSE  = ", `TirageBooster`, `UtilisateurProduit`";
        filterSE =
            " AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`"
            " AND `TirageBooster`.`idAchat` = `UtilisateurProduit`.`idAchat` "
            " AND `TirageBooster`.`idSousExtension` = ${containsSe.id}";
      }

      // Select random booster products
      query ="SELECT `Produit`.`idProduit`, $subQueryCount FROM `Produit`, `ProduitBooster` $tableSE"
          " WHERE `Produit`.`idLangue` = ${l.id}"
          " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
          " AND `ProduitBooster`.`idSousExtension` IS NULL"
          " $filter"
          " $filterSE"
          " GROUP BY `Produit`.`idProduit`"
          " ORDER BY `Produit`.`sortie` DESC, `Produit`.`nom` ASC";

      printOutput(query);
      exts = await connection.query(query);
      await ProductQuery.fillProd(produits, exts, Colors.deepOrange[700]);
    }
  });
  return produits;
}

Future<Map> readProductsForUser(Language l, SubExtension se, ProductCategory? category) async
{
  assert(Environment.instance.user != null);
  Map<ProductCategory, List<ProductRequested>> produits = {};
  Environment.instance.collection.categories.values.forEach((c) {
    produits[c] = [];
  });

  String subQueryCount = '''(SELECT COUNT(*) FROM `Produit` as P, `UtilisateurProduit`
WHERE `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`
AND P.`idProduit` = `Produit`.`idProduit`
AND `UtilisateurProduit`.`idUtilisateur` = ${Environment.instance.user!.idDB}) as count ''';

  String filter = '';
  if(category != null)
    filter = ' AND `Produit`.`idCategorie` = ${category.idDB}';

  await Environment.instance.db.transactionR( (connection) async {
    String query = "SELECT `Produit`.`idProduit`, $subQueryCount FROM `Produit`, `ProduitBooster` "
        " WHERE `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` = ${se.id} $filter"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`nom` ASC";

    //printOutput(query);

    var exts = await connection.query(query);
    await ProductQuery.fillProd(produits, exts, Colors.grey[600]);

    String tableSE  = ", `TirageBooster`, `UtilisateurProduit`";
    String filterSE =
    " AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`"
        " AND `TirageBooster`.`idAchat` = `UtilisateurProduit`.`idAchat` "
        " AND `TirageBooster`.`idSousExtension` = ${se.id}";

    query ="SELECT `Produit`.`idProduit`, $subQueryCount FROM `Produit`, `ProduitBooster` $tableSE"
        " WHERE `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` IS NULL"
        " $filter $filterSE"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`sortie` DESC, `Produit`.`nom` ASC";

    //printOutput(query);

    exts = await connection.query(query);
    await ProductQuery.fillProd(produits, exts, Colors.deepOrange[700]);
  });
  return produits;
}