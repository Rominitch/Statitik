import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/models/draw/poke_expansion_draw.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/statistics/poke_stats_booster.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/tools.dart';

class PokeStatistics {

  Future<PokeStatsBooster> getStatsFrom(Database db, PokeExpansion expansion, [int? user]) async {
    String query = 'SELECT `cartesBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit` '
        'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
        'AND `idSousExtension` = ${expansion.pid().id()} ';
    return _getStats(db, expansion, query, user);
  }

  Future<PokeStatsBooster> _getStats(Database db, PokeExpansion expansion, String query, [int? user]) async {
    final stats = PokeStatsBooster(expansion: expansion);
    try {
      String userReq = ';';
      if(user != null) {
        userReq = 'AND `UtilisateurProduit`.`idUtilisateur` = $user ';
      }
      query += userReq;

      await db.transactionR( (connection) async {
        /*
        String query;
        if(product != null) {
          query = 'SELECT `cartesBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit` '
              'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
              'AND `UtilisateurProduit`.`idProduit` = ${product.idDB} '
              'AND `idSousExtension` = ${subExt.id} '
              '$userReq;';
        } else if(category != null) {
          query = 'SELECT `cartesBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit`, `Produit` '
              'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
              'AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit` '
              'AND `Produit`.`idCategorie` = ${category.idDB} '
              'AND `idSousExtension` = ${subExt.id} '
              '$userReq;';
        } else {
          query = 'SELECT `cartesBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit` '
              'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
              'AND `idSousExtension` = ${subExt.id} '
              '$userReq;';
        }
        //printOutput(query);

        var req = await connection.query(query);
        for (var row in req) {
          try {
            var bytes = (row[0] as Blob).toBytes().toList();
            final edc = PokeExpansionDraw.fromBytes(expansion, bytes);
            stats.addBoosterDraw(edc, row[1]);
          } catch(e) {
            printOutput("Stats extraction failure - SE=${expansion.pid().id()} : $e");
          }
        }
        */
      });
    }
    catch( e ) {
      if( e is StatitikException) {
        printOutput(e.msg);
      }
    }
    return stats;
  }
}