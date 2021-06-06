import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class ProductQuery {

  void fillProd(connection, List produits, exts, color) async {
    for (var row in exts) {
      Map<int, ProductBooster> boosters = {};
      var reqBoosters = await connection.query("SELECT `ProduitBooster`.`idSousExtension`, `ProduitBooster`.`nombre`, `ProduitBooster`.`carte` FROM `ProduitBooster`"
          " WHERE `ProduitBooster`.`idProduit` = ${row[0]}");
      for (var row in reqBoosters) {
        boosters[row[0]] = ProductBooster(nbBoosters: row[1], nbCardsPerBooster: row[2]);
      }
      int cat = row[3]-1;
      assert(0 <= cat && cat < produits.length);
      produits[cat].add(Product(idDB: row[0], name: row[1], imageURL: row[2], count: row[4], boosters: boosters, color: color ));
    }
  }
}
Future<List> readProducts(Language l, SubExtension se, int? idCategorie, SubExtension? containsSe) async
{
  List produits = List<List<Product>>.generate(Environment.instance.collection.category, (index) { return []; });

  Function fillProd = (connection, exts, color) async {
    for (var row in exts) {
      Map<int, ProductBooster> boosters = {};
      var reqBoosters = await connection.query("SELECT `ProduitBooster`.`idSousExtension`, `ProduitBooster`.`nombre`, `ProduitBooster`.`carte` FROM `ProduitBooster`"
          " WHERE `ProduitBooster`.`idProduit` = ${row[0]}");
      for (var rowBooster in reqBoosters) {
        var idBooster = rowBooster[0] == null ? 0 : rowBooster[0];
        boosters[idBooster] = ProductBooster(nbBoosters: rowBooster[1], nbCardsPerBooster: rowBooster[2]);
      }
      int cat = row[3]-1;
      assert(0 <= cat && cat < produits.length);
      produits[cat].add(Product(idDB: row[0], name: row[1], imageURL: row[2], count: row[4], boosters: boosters, color: color ));
    }
  };

  String subQueryCount = '''(SELECT COUNT(*) FROM `Produit` as P, `UtilisateurProduit`
WHERE `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit` 
AND P.`idProduit` = `Produit`.`idProduit`) as count ''';

  String filter = '';
  if(idCategorie != null) {
    filter = ' AND `Produit`.`idCategorie` = $idCategorie';
  }

  await Environment.instance.db.transactionR( (connection) async {
    String query = "SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` "
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` = ${se.id} $filter"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`nom` ASC";

    //printOutput(query);
    var exts = await connection.query(query);
    await fillProd(connection, exts, Colors.grey[600]);

    String tableSE = "";
    String filterSE = " AND `Produit`.`annee` >= ${se.year}";
    if( containsSe != null ) {
      tableSE  = ", `TirageBooster`, `UtilisateurProduit`";
      filterSE =
          " AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`"
          " AND `TirageBooster`.`idAchat` = `UtilisateurProduit`.`idAchat` "
          " AND `TirageBooster`.`idSousExtension` = ${containsSe.id}";
    }

    // Select random booster products
    query ="SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` $tableSE"
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` IS NULL"
        " $filter"
        " $filterSE"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`annee` DESC, `Produit`.`nom` ASC";

    printOutput(query);
    exts = await connection.query(query);
    await fillProd(connection, exts, Colors.deepOrange[700]);
  });
  return produits;
}

Future<List> readProductsForUser(Language l, SubExtension se, int idCategorie) async
{
  assert(Environment.instance.user != null);
  List produits = List<List<Product>>.generate(Environment.instance.collection.category, (index) { return []; });

  Function fillProd = (connection, exts, color) async {
    for (var row in exts) {
      Map<int, ProductBooster> boosters = {};
      var reqBoosters = await connection.query("SELECT `ProduitBooster`.`idSousExtension`, `ProduitBooster`.`nombre`, `ProduitBooster`.`carte` FROM `ProduitBooster`"
          " WHERE `ProduitBooster`.`idProduit` = ${row[0]}");
      for (var row in reqBoosters) {
        boosters[row[0]] = ProductBooster(nbBoosters: row[1], nbCardsPerBooster: row[2]);
      }
      int cat = row[3]-1;
      assert(0 <= cat && cat < produits.length);
      produits[cat].add(Product(idDB: row[0], name: row[1], imageURL: row[2], count: row[4], boosters: boosters, color: color ));
    }
  };

  String subQueryCount = '''(SELECT COUNT(*) FROM `Produit` as P, `UtilisateurProduit`
WHERE `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`
AND P.`idProduit` = `Produit`.`idProduit`
AND `UtilisateurProduit`.`idUtilisateur` = ${Environment.instance.user!.idDB}) as count ''';

  String filter = '';
  if(idCategorie > 0)
    filter = ' AND `Produit`.`idCategorie` = $idCategorie';

  await Environment.instance.db.transactionR( (connection) async {
    String query = "SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` "
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` = ${se.id} $filter"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`nom` ASC";

    //printOutput(query);

    var exts = await connection.query(query);
    await fillProd(connection, exts, Colors.grey[600]);

    String tableSE  = ", `TirageBooster`, `UtilisateurProduit`";
    String filterSE =
    " AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`"
        " AND `TirageBooster`.`idAchat` = `UtilisateurProduit`.`idAchat` "
        " AND `TirageBooster`.`idSousExtension` = ${se.id}";

    query ="SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone`, `Produit`.`idCategorie`, $subQueryCount FROM `Produit`, `ProduitBooster` $tableSE"
        " WHERE `Produit`.`approuve` = 1"
        " AND `Produit`.`idLangue` = ${l.id}"
        " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
        " AND `ProduitBooster`.`idSousExtension` IS NULL"
        " $filter $filterSE"
        " GROUP BY `Produit`.`idProduit`"
        " ORDER BY `Produit`.`annee` DESC, `Produit`.`nom` ASC";

    //printOutput(query);

    exts = await connection.query(query);
    await fillProd(connection, exts, Colors.deepOrange[700]);
  });
  return produits;
}