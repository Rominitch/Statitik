import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/collection.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/connection.dart';

class StatitikException implements Exception {
    String msg;
    StatitikException(this.msg);
}

class Database
{
    final String version = '1.9';
    final ConnectionSettings settings = createConnection();

    Future<bool> transactionR(Function queries) async
    {
        bool valid=false;
        MySqlConnection connection;
        try
        {
            connection = await MySqlConnection.connect(settings);
        } catch( e ) {
            throw StatitikException('DB_0');
        }

        // Execute request
        try {
            await connection.transaction(queries);

            valid = true;
        } catch( e ) {
            printOutput(e.toString());
        }
        finally {
            connection.close();
        }
        return valid;
    }
}

class Environment
{
    Environment._privateConstructor();
    static final Environment instance = Environment._privateConstructor();

    // Event
    final StreamController<bool> onInitialize = StreamController<bool>();
    final StreamController<String> onServerError = StreamController<String>();

    // Manager
    Credential credential = Credential();
    Database db = Database();

    // Const data
    final String nameApp = 'StatitikCard';
    final String version = '0.9.7';

    // State
    bool isInitialized          = false;
    bool startDB                = false;
    bool showExtensionName      = false;
    bool showPressImages        = false;
    bool showPressProductImages = false;

    // Cached data
    Collection collection = Collection();

    // Current draw
    UserPoke? user;
    SessionDraw? currentDraw;

    void initialize() async
    {
        if(!isInitialized) {
            // Sync event
            try {
                bool isDBReady       = false;
                bool isDatabaseMatch = false;
                db.transactionR( (connection) async {
                    var info = await connection.query("SELECT * FROM `BaseInfo`");

                    for (var row in info) {
                        isDatabaseMatch = (row[0] == db.version);
                        showPressImages        = (row[2] == 1);
                        showPressProductImages = showPressImages;
                    }
                }).then( (result) {
                    isDBReady = result;
                }).whenComplete( () async {
                    if(!isDBReady) {
                        throw StatitikException('DB_0');
                    }
                    if(!isDatabaseMatch) {
                        throw StatitikException('DB_1');
                    }
                    await Future.wait(
                        [
                            credential.initialize(),
                            readStaticData(),
                        ]);

                    isInitialized = true;
                    onInitialize.add(isInitialized);
                }).catchError((error) {
                    isInitialized = false;
                    onServerError.add(error.msg);
                }).onError((error, stackTrace) {
                    isInitialized = false;
                    //onServerError.add(error.msg);
                });
            }
            on StatitikException catch(e) {
                isInitialized = false;
                onServerError.add(e.msg);
            }
            catch (e) {
                isInitialized = false;
                onServerError.add('error');
            }
        }
    }

    void toggleShowExtensionName() {
        showExtensionName = ! showExtensionName;
    }

    Future<void> readStaticData() async
    {
        if(!startDB) {
            // Avoid reentrance
            collection.clear();

            await db.transactionR( (connection) async {
                var langues = await connection.query("SELECT * FROM `Langue`");
                for (var row in langues) {
                    collection.addLanguage(Language(id: row[0], image: row[1]));
                }

                var exts = await connection.query("SELECT * FROM `Extension` ORDER BY `code` DESC");
                for (var row in exts) {
                    collection.addExtension(Extension(id: row[0], name: row[2], idLanguage: row[1]));
                }
                var pokes = await connection.query("SELECT * FROM `Pokemon`");
                for (var row in pokes) {
                    try {
                        PokemonInfo p = PokemonInfo(names: row[2].split('|'), generation: row[1], info: CardInfo.from(0));
                        collection.addPokemon(p, row[0]);
                    } catch(e) {
                        print("Bad pokemon: ${row[0]} $e");
                    }
                }
                var objSup = await connection.query("SELECT * FROM `DresseurObjet`");
                for (var row in objSup) {
                    try {
                        collection.addNamed(NamedInfo(names: row[1].split('|'), info: CardInfo.from(0)), row[0]);
                    } catch(e) {
                        print("Bad Object: ${row[0]} $e");
                    }
                }

                var lstCards = await connection.query("SELECT * FROM `ListeCartes`");
                for (var row in lstCards) {
                    ListCards c = ListCards();
                    try {
                        c.extractCard(row[1]);
                        assert(c.cards.isNotEmpty);
                        List<CodeCardInfo> pokeCode = [];
                        if( row[2] != null) {
                            try {
                                final byteData = (row[2] as Blob)
                                    .toBytes()
                                    .toList();
                                assert((byteData.length % (2+4)) == 0);

                                for (int id = 0; id < byteData.length; id += 6) {
                                    pokeCode.add(CodeCardInfo( (byteData[id] << 8) + byteData[id + 1],
                                        (((byteData[id+2] << 8) | byteData[id+3]) << 8 | byteData[id+4]) << 8 | byteData[id+5]));
                                }
                                c.extractCardInfo(pokeCode);
                            } catch(e) {
                                print("Data corruption: ListCard ${row[0]} $e");
                            }
                        }
                        collection.addListCards(c, row[0]);
                    } catch(e) {
                        print("Bad cards list: $e");
                    }
                }

                var subExts = await connection.query("SELECT * FROM `SousExtension` ORDER BY `code` DESC");
                for (var row in subExts) {
                    try {
                        var cards = collection.getListCardsID(row[4]);
                        SubExtension se = SubExtension(id: row[0], name: row[2], icon: row[3], idExtension: row[1], out: row[6], chromatique: row[7],
                            cards: cards);
                        collection.addSubExtension(se);
                    } catch(e) {
                        print("Bad SubExtension: ${row[2]} $e");
                    }
                }

                var catExts = await connection.query("SELECT COUNT(*) FROM `Categorie`");
                for (var row in catExts) {
                    collection.category = row[0];
                }
            });

            startDB = true;
        }
    }

    Future<void> registerUser(String uid) async {
        if (user == null) {
            await db.transactionR( (connection) async {
                // Check user data exists into database
                int idNewID=-1;
                var reqCountUser = await connection.query(
                    'SELECT count(`idUtilisateur`) FROM `Utilisateur`;');
                for (var row in reqCountUser) {
                    idNewID = row[0] + 1;
                }

                String query = 'SELECT `idUtilisateur`, `ban`, `su` FROM `Utilisateur` WHERE `identifiant` = \'$uid\';';
                var reqUser = await connection.query(query);
                if( reqUser.length == 1 ) {
                    for (var row in reqUser) {
                        if(row[1] != 0)
                            throw StatitikException("Utilisateur banni pour non respect des règles.");
                        user = UserPoke(idDB: row[0]);
                        user!.admin = row[2] == 1 ? true : false;
                    }
                } else {
                    await connection.query('INSERT INTO `Utilisateur` (idUtilisateur, identifiant, ban) VALUES ($idNewID, \'$uid\', 0);');
                    user = UserPoke(idDB: idNewID);
                }
                user!.uid = uid;
            });
        }
    }

    Future<bool> sendDraw() async {
        if( !isLogged() )
            return false;

        try {
            return await db.transactionR( (connection) async {
                // Get new ID
                int idAchat = 1;
                var req = await connection.query('SELECT count(idAchat) FROM `UtilisateurProduit`;');
                for (var row in req) {
                    idAchat = row[0] + 1;
                }

                // Add new product
                final queryStr = 'INSERT INTO `UtilisateurProduit` (idAchat, idUtilisateur, idProduit, anomalie) VALUES ($idAchat, ${user!.idDB}, ${currentDraw!.product.idDB}, ${currentDraw!.productAnomaly ? 1 : 0})';
                await connection.query(queryStr);

                // Prepare data
                List<List<Object>> draw = [];
                for(BoosterDraw booster in currentDraw!.boosterDraws) {
                    draw.add(booster.buildQuery(idAchat));
                }
                // Send data
                await connection.queryMulti('INSERT INTO `TirageBooster` (idAchat, idSousExtension, anomalie, energieBin, cartesBin) VALUES (?, ?, ?, ?, ?);',
                                            draw);
            });
        } catch( e ) {
            printOutput("Database error $e");
        }
        return false;
    }

    Future<void> removeUser() async {
        if( !isLogged() )
            return;

        try {
            await db.transactionR( (connection) async {
                await connection.query('UPDATE `Utilisateur` SET `identifiant` = \'unregistred\' WHERE `identifiant` = \'${user!.uid}\';');

                user = null;
            });
        }
        catch( e ) {
        }
    }

    Future<Stats> getStats(SubExtension subExt, Product? product, int category, [int? user]) async {
        Stats stats = new Stats(subExt: subExt);
        try {
            String userReq = '';
            if(user != null)
                userReq = 'AND `UtilisateurProduit`.`idUtilisateur` = $user ';

            await db.transactionR( (connection) async {
                String query;
                if(product != null) {
                    query = 'SELECT `cartesBin`, `energieBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit` '
                            'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
                            'AND `UtilisateurProduit`.`idProduit` = ${product.idDB} '
                            'AND `idSousExtension` = ${subExt.id} '
                            '$userReq;';
                } else if(category > 0) {
                    query = 'SELECT `cartesBin`, `energieBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit`, `Produit` '
                        'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
                        'AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit` '
                        'AND `Produit`.`idCategorie` = $category '
                        'AND `idSousExtension` = ${subExt.id} '
                        '$userReq;';
                } else {
                    query = 'SELECT `cartesBin`, `energieBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit` '
                            'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
                            'AND `idSousExtension` = ${subExt.id} '
                            '$userReq;';
                }
                //printOutput(query);

                var req = await connection.query(query);
                for (var row in req) {
                    try {
                        stats.addBoosterDraw((row[0] as Blob).toBytes(), (row[1] as Blob).toBytes(), row[2]);
                    } catch(e) {}
                }
            });
        }
        catch( e ) {
            if( e is StatitikException)
                printOutput(e.msg);
        }
        return stats;
    }

    void showAbout(context) {
        showAboutDialog(
            context: context,
            applicationVersion: version,
            //applicationIcon:
            applicationLegalese: 'Copyright (c) 2021 Rominitch',
            applicationName: nameApp,
            children:[]
        );
    }

    void showDisclaimer(context) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                title: new Text(StatitikLocale.of(context).read('disclaimer_T0')),
                content: SingleChildScrollView( child:Text( nameApp + StatitikLocale.of(context).read('disclaimer'),
                textAlign: TextAlign.justify),
            ), )
        );
    }

    bool isLogged() {
        return user != null;
    }

    void login(CredentialMode mode, context, Function(String?)? updateGUI) {
        var onSuccess = (uid) {
            //printOutput("Credential Success: "+uid);
            SharedPreferences.getInstance().then((prefs) {
                // Save to preferences
                prefs.setString('uid', uid);

                // Register and check access
                assert(uid != null);
                registerUser(uid).then((value) {
                    if(updateGUI != null)
                        updateGUI(null);
                });
            });
        };
        var onError = (message, [code]) {
            //printOutput("Credential Error: "+message);
            Environment.instance.user = null;
            if(updateGUI != null)
                updateGUI(sprintf(StatitikLocale.of(context).read(message), [code]));
        };

        try {
            // Log system
            if(mode==CredentialMode.Phone) {
                credential.signInWithPhone(context, onError, onSuccess);
            } else if(mode==CredentialMode.Google) {
                credential.signInWithGoogle(onSuccess);
            }
            else if(mode==CredentialMode.AutoLog){
                SharedPreferences.getInstance().then((prefs) {
                    onSuccess(prefs.getString('uid'));
                });
            } else {
                onError('LOG_3');
            }
        } catch(e) {
            onError('LOG_4');
        }
    }

  Future<bool> sendRequestProduct(String info, String eac) async
  {
      if( !isLogged() )
          return false;
      try {
          return await db.transactionR( (connection) async {
              // Get new ID
              int idRequest = 1;
              var req = await connection.query('SELECT count(idDemande) FROM `Demande`;');
              for (var row in req) {
                  idRequest = row[0] + 1;
              }

              // Add new request
              final queryStr = 'INSERT INTO `Demande` (idDemande, Information, EAC) VALUES (?, ?, ?)';

              await connection.queryMulti(queryStr, [[idRequest, info, eac]]);
          });
      } catch( e ) {
          printOutput("Database error $e");
      }
      return false;
  }

    Future<List<SessionDraw>> getMyDraw([bool showAll=false]) async
    {
        List<SessionDraw> myBooster = [];
        if( isLogged() ) {
            try {
                String filteredUser = (showAll && user!.admin) ? '' : ' `UtilisateurProduit`.`idUtilisateur`= \'${user!.idDB}\' AND ';

                await db.transactionR( (connection) async {
                    String query = 'SELECT `idAchat`, `anomalie`, `Produit`.`idProduit`, `Produit`.`idLangue`, `Produit`.`nom`, `Produit`.`icone`'
                        ' FROM `UtilisateurProduit`, `Produit`'
                        ' WHERE $filteredUser'
                        ' `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit`'
                        ' ORDER BY `idAchat` DESC';
                    //printOutput(query);

                    var req = await connection.query(query);
                    for (var row in req) {
                        Map<int, ProductBooster> boosters = {};
                        var reqBoosters = await connection.query("SELECT `idSousExtension`, `nombre`, `carte`"
                            " FROM `ProduitBooster`"
                            " WHERE `idProduit` = \'${row[2]}\'");
                        for (var rowBooster in reqBoosters) {
                            var idBooster = rowBooster[0] == null ? 0 : rowBooster[0];
                            boosters[idBooster] = ProductBooster(nbBoosters: rowBooster[1], nbCardsPerBooster: rowBooster[2]);
                        }

                        // Start session
                        var p = Product(idDB: row[2], name: row[4], imageURL: row[5], count: 1, boosters: boosters, color: Colors.grey[600]!);
                        var l = collection.languages[row[3]];
                        var session = SessionDraw(product: p, language: l);

                        // Read user data
                        var reqUserBoosters = await connection.query("SELECT `idSousExtension`, `anomalie`, `cartesBin`, `energieBin` "
                            " FROM `TirageBooster`"
                            " WHERE `idAchat` = \'${row[0]}\'");
                        int id=0;
                        for (var rowUserBooster in reqUserBoosters) {
                            BoosterDraw booster;
                            if(id >= session.boosterDraws.length) {
                                session.addNewBooster();
                            }
                            booster = session.boosterDraws[id];
                            booster.fill(collection.getSubExtensionID(rowUserBooster[0])!, rowUserBooster[1]==1, (rowUserBooster[2] as Blob).toBytes(), (rowUserBooster[3] as Blob).toBytes());

                            id += 1;
                        }
                        myBooster.add(session);
                    }
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return myBooster;
    }

    Future<bool> sendCardInfo(SubExtension se) async {
        if( !isLogged() && !user!.admin)
            return false;
        try {
            return await db.transactionR( (connection) async {
                var rType   = convertType.map((k, v) => MapEntry(v, k));
                var rRarity = convertRarity.map((k, v) => MapEntry(v, k));

                String code = "";
                se.cards!.cards.forEach((PokeCard card) {
                    code += rType[card.type] + rRarity[card.rarity];
                });

                var query = 'UPDATE `listecartes`, `sousextension` SET `cartes` = "$code"'
                ' WHERE `listecartes`.`idListeCartes` = `sousextension`.`idListeCartes`'
                ' AND `sousextension`.`idSousExtension` = ${se.id}';
                //printOutput(query);

                await connection.query(query);
            });
        } catch( e ) {
            printOutput("Database error $e");
        }
        return false;
    }
}