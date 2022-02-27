import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/cardDrawData.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';

class ProductBooster
{
  int nbBoosters;
  int nbCardsPerBooster;

  ProductBooster({required this.nbBoosters, required this.nbCardsPerBooster});
}

class Product
{
  int idDB;
  String name;
  String imageURL;
  Map<int, ProductBooster> boosters;

  Product({required this.idDB, required this.name, required this.imageURL, required this.boosters});

  bool hasImages() {
    return imageURL.isNotEmpty;
  }

  CachedNetworkImage image()
  {
    return drawCachedImage('products', imageURL, height: 70);
  }

  int countBoosters() {
    int count=0;
    boosters.forEach((key, value) { count += value.nbBoosters; });
    return count;
  }

  List<BoosterDraw> buildBoosterDraw(Map mapSubExtensions) {
    var list = <BoosterDraw>[];
    int id=1;
    boosters.forEach((key, value) {
      for( int i=0; i < value.nbBoosters; i+=1) {
        SubExtension? se = mapSubExtensions[key];
        list.add(new BoosterDraw(creation: se, id: id, nbCards: value.nbCardsPerBooster));
        id += 1;
      }
    });
    return list;
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
  static Future<void> fillProd(connection, List produits, exts, color) async {
    for (var row in exts) {
      // Get category
      int cat = row[1]-1;
      assert(0 <= cat && cat < produits.length);
      // Search already existing
      Iterable searching = produits[cat].where( (ProductRequested item) {return item.product.idDB == row[0];});
      if(searching.isEmpty) {
        /*
        // Get latest data
        Map<int, ProductBooster> boosters = {};
        var reqBoosters = await connection.query("SELECT `ProduitBooster`.`idSousExtension`, `ProduitBooster`.`nombre`, `ProduitBooster`.`carte` FROM `ProduitBooster`"
            " WHERE `ProduitBooster`.`idProduit` = ${row[0]}");
        for (var rowBooster in reqBoosters) {
          var idBooster = rowBooster[0] == null ? 0 : rowBooster[0];
          boosters[idBooster] = ProductBooster(nbBoosters: rowBooster[1], nbCardsPerBooster: rowBooster[2]);
        }
        // Add new product
        produits[cat].add(Product(idDB: row[0], name: row[1], imageURL: row[2], count: row[4], boosters: boosters, color: color ));
        */
        produits[cat].add(ProductRequested(Environment.instance.collection.products[row[0]], color, row[2]));
      }
    }
  }
}

Future<List> readProducts(Language l, SubExtension se, int? idCategorie, SubExtension? containsSe, {bool showAll=true}) async
{
  List produits = List<List<ProductRequested>>.generate(Environment.instance.collection.category, (index) { return []; });

  String subQueryCount = '''(SELECT COUNT(*) FROM `Produit` as P, `UtilisateurProduit`
WHERE `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit` 
AND P.`idProduit` = `Produit`.`idProduit`) as count ''';

  String filter = '';
  if(idCategorie != null) {
    filter = ' AND `Produit`.`idCategorie` = $idCategorie';
  }

  await Environment.instance.db.transactionR( (connection) async {
    String query = "SELECT `Produit`.`idProduit`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` "
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` = ${se.id} $filter"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`nom` ASC";

    //printOutput(query);
    var exts = await connection.query(query);
    await ProductQuery.fillProd(connection, produits, exts, Colors.grey[600]);

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
      query ="SELECT `Produit`.`idProduit`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` $tableSE"
          " WHERE `Produit`.`approuve` = 1"
          " AND `Produit`.`idLangue` = ${l.id}"
          " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
          " AND `ProduitBooster`.`idSousExtension` IS NULL"
          " $filter"
          " $filterSE"
          " GROUP BY `Produit`.`idProduit`"
          " ORDER BY `Produit`.`sortie` DESC, `Produit`.`nom` ASC";

      printOutput(query);
      exts = await connection.query(query);
      await ProductQuery.fillProd(connection, produits, exts, Colors.deepOrange[700]);
    }
  });
  return produits;
}

Future<List> readProductsForUser(Language l, SubExtension se, int idCategorie) async
{
  assert(Environment.instance.user != null);
  List produits = List<List<ProductRequested>>.generate(Environment.instance.collection.category, (index) { return []; });

  String subQueryCount = '''(SELECT COUNT(*) FROM `Produit` as P, `UtilisateurProduit`
WHERE `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`
AND P.`idProduit` = `Produit`.`idProduit`
AND `UtilisateurProduit`.`idUtilisateur` = ${Environment.instance.user!.idDB}) as count ''';

  String filter = '';
  if(idCategorie > 0)
    filter = ' AND `Produit`.`idCategorie` = $idCategorie';

  await Environment.instance.db.transactionR( (connection) async {
    String query = "SELECT `Produit`.`idProduit`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` "
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` = ${se.id} $filter"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`nom` ASC";

    //printOutput(query);

    var exts = await connection.query(query);
    await ProductQuery.fillProd(connection, produits, exts, Colors.grey[600]);

    String tableSE  = ", `TirageBooster`, `UtilisateurProduit`";
    String filterSE =
    " AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`"
        " AND `TirageBooster`.`idAchat` = `UtilisateurProduit`.`idAchat` "
        " AND `TirageBooster`.`idSousExtension` = ${se.id}";

    query ="SELECT `Produit`.`idProduit`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` $tableSE"
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` IS NULL"
        " $filter $filterSE"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`sortie` DESC, `Produit`.`nom` ASC";

    //printOutput(query);

    exts = await connection.query(query);
    await ProductQuery.fillProd(connection, produits, exts, Colors.deepOrange[700]);
  });
  return produits;
}