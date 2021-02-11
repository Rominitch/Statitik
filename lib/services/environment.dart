import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/connection.dart';

class StatitikException implements Exception {
    String msg;
    StatitikException(this.msg);
}

class Credential
{
    final GoogleSignIn googleSignIn = GoogleSignIn();

    Future<void> initialize() async
    {
        try {
            await Firebase.initializeApp();

            // Auto login
            var prefs = await SharedPreferences.getInstance();
            if( prefs.getString('uid') != null ) {
                await Environment.instance.login(1);
            }
        } catch(e) {
            Environment.instance.user = null;
        }
    }

    Future<String> signInWithGoogle() async {
        try {
            FirebaseAuth _auth = FirebaseAuth.instance;

            final GoogleSignInAccount googleSignInAccount = await googleSignIn
                .signIn();
            final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount
                .authentication;
            final AuthCredential credential = GoogleAuthProvider.credential(
                accessToken: googleSignInAuthentication.accessToken,
                idToken: googleSignInAuthentication.idToken,
            );

            final UserCredential authResult = await _auth.signInWithCredential(
                credential);

            return "google-" + authResult.user.uid;

        } catch(e) {
            Environment.instance.user = null;
        }
        return null;
    }

    Future<void> signOutGoogle() async {
        Environment.instance.user = null;
        await googleSignIn.signOut();

        var prefs = await SharedPreferences.getInstance();
        prefs.remove('uid');
    }
}

class Database
{
    final String version = '1.2';
    final ConnectionSettings settings = createConnection();

    Future<void> transactionR(Function queries) async
    {
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
        } catch( e ) {
            if(local)
                print(e.toString());
        }
        finally {
            connection.close();
        }
    }
}

class Collection
{
    List languages = [];
    List extensions = [];
    List subExtensions = [];
    Map<int, String> category = {};

    void clear() {
        languages.clear();
        extensions.clear();
        subExtensions.clear();
        category.clear();
    }

    void addLanguage(Language l) {
        languages.add(l);
    }

    void addExtension(Extension e) {
        extensions.add(e);
    }
    void addSubExtension(SubExtension e) {
        subExtensions.add(e);
    }

    List getExtensions(Language language) {
        List l = [];
        for(Extension e in extensions) {
            if (e.idLanguage == language.id) {
                l.add(e);
            }
        }
        return l;
    }

    List getSubExtensions(Extension e) {
        List l = [];
        for(SubExtension se in subExtensions) {
            if (se.idExtension == e.id) {
                l.add(se);
            }
        }
        return l;
    }

    SubExtension getSubExtensionID(int id) {
        for(SubExtension se in subExtensions) {
            if (se.id == id) {
                return se;
            }
        }
        return null;
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
    final String version = '0.4.0';

    // State
    bool isInitialized=false;
    bool startDB=false;
    bool showExtensionName = false;
    bool showPressImages = false;
    bool showPressProductImages = false;
    final String serverImages = 'https://mouca.fr/StatitikCard/products/';

    // Cached data
    Collection collection = Collection();

    // Current draw
    UserPoke user;
    SessionDraw currentDraw;

    void initialize() async
    {
        if(!isInitialized) {
            // Sync event
            try {
                await Future.wait(
                    [
                        databaseReady(),
                        credential.initialize(),
                        readStaticData(),
                    ]);

                isInitialized = true;
                onInitialize.add(isInitialized);
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

    Future<void> databaseReady() async
    {
        await db.transactionR( (connection) async {
            var info = await connection.query("SELECT * FROM `BaseInfo`");
            bool isValid = false;
            for (var row in info) {
                isValid = row[0] == db.version;
                showPressImages = row[2] == 1;
                showPressProductImages = showPressImages;
            }
            if(info == null || !isValid)
                throw StatitikException('DB_1');
        });
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

                var subExts = await connection.query("SELECT * FROM `SousExtension` ORDER BY `code` DESC");
                for (var row in subExts) {
                    SubExtension se = SubExtension(id: row[0], name: row[2], icon: row[3], idExtension: row[1], year: row[6]);
                    try {
                        se.extractCard(row[4]);
                        collection.addSubExtension(se);
                    } catch(e) {
                        print("Bad Subextension: ${se.name} $e");
                    }
                }

                var catExts = await connection.query("SELECT * FROM `Categorie` ORDER BY `nom` DESC");
                for (var row in catExts) {
                    collection.category[row[0]-1] = row[1];
                }
            });

            startDB = true;
        }
    }

    Future<List> readProducts(Language l, SubExtension se) async
    {
        List produits = List<List<Product>>.generate(Environment.instance.collection.category.length, (index) { return []; });

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
                produits[cat].add(Product(idDB: row[0], name: row[1], imageURL: row[2], boosters: boosters, color: color ));
            }
        };

        await db.transactionR( (connection) async {
            String query = "SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone`, `Produit`.`idCategorie` FROM `Produit`, `ProduitBooster`"
                " WHERE `Produit`.`approuve` = 1"
                " AND `Produit`.`idLangue` = ${l.id}"
                " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
                " AND `ProduitBooster`.`idSousExtension` = ${se.id}"
                " ORDER BY `Produit`.`nom` ASC";
            var exts = await connection.query(query);
            await fillProd(connection, exts, Colors.grey[600]);

            query ="SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone`, `Produit`.`idCategorie` FROM `Produit`, `ProduitBooster`"
                " WHERE `Produit`.`approuve` = 1"
                " AND `Produit`.`idLangue` = ${l.id}"
                " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
                " AND `ProduitBooster`.`idSousExtension` IS NULL"
                " AND `Produit`.`annee` >= ${se.year}"
                " ORDER BY `Produit`.`annee` DESC, `Produit`.`nom` ASC";
            exts = await connection.query(query);
            await fillProd(connection, exts, Colors.deepOrange[700]);
        });
        return produits;
    }

    Future<void> registerUser(String uid) async {
        if (user == null) {
            await db.transactionR( (connection) async {
                // Check user data exists into database
                int idNewID;
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
                        user.admin = row[2] == 1 ? true : false;
                    }
                } else {
                    await connection.query('INSERT INTO `Utilisateur` (idUtilisateur, identifiant, ban) VALUES ($idNewID, \'$uid\', 0);');
                    user = UserPoke(idDB: idNewID);
                }
                user.uid = uid;
            });
        }
    }

    Future<bool> sendDraw() async {
        if( !isLogged() )
            return false;

        try {
            await db.transactionR( (connection) async {
                int idAchat;
                var req = await connection.query('SELECT count(idAchat) FROM `UtilisateurProduit`;');
                for (var row in req) {
                    idAchat = row[0] + 1;
                }

                await connection.query('INSERT INTO `UtilisateurProduit` (idAchat, idUtilisateur, idProduit, anomalie) VALUES ($idAchat, ${user.idDB}, ${currentDraw.product.idDB}, ${currentDraw.productAnomaly ? 1 : 0});');

                // Prepare data
                List<List<dynamic>> draw = [];
                for(BoosterDraw booster in currentDraw.boosterDraws) {
                    draw.add(booster.buildQuery(idAchat));
                }
                // Send data
                await connection.queryMulti('INSERT INTO `TirageBooster` (idAchat, idSousExtension, anomalie, energieBin, cartesBin) VALUES (?, ?, ?, ?, ?);',
                                            draw);
            });
            return true;
        } catch( e ) {
            if(local)
                print("Database error $e");
        }
        return false;
    }

    Future<void> removeUser() async {
        if( !isLogged() )
            return;

        try {
            await db.transactionR( (connection) async {
                await connection.query('UPDATE `Utilisateur` SET `identifiant` = \'unregistred\' WHERE `identifiant` = \'${user.uid}\';');

                user = null;
            });
        }
        catch( e ) {
        }
    }

    Future<Stats> getStats(SubExtension subExt, Product product, int category) async {
        Stats stats = new Stats(subExt: subExt);
        try {
            await db.transactionR( (connection) async {
                String query;
                if(product != null) {
                    query = 'SELECT `cartesBin`, `energieBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit` '
                            'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
                            'AND `UtilisateurProduit`.`idProduit` = ${product.idDB} '
                            'AND `idSousExtension` = ${subExt.id};';
                } else if(category != -1) {
                    query = 'SELECT `cartesBin`, `energieBin`, `TirageBooster`.`anomalie` FROM `TirageBooster`, `UtilisateurProduit`, `Produit` '
                        'WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat` '
                        'AND `UtilisateurProduit`.`idProduit` = `Produit`.`idProduit` '
                        'AND `Produit`.`idCategorie` = ${category+1} '
                        'AND `idSousExtension` = ${subExt.id};';
                } else {
                    query = 'SELECT `cartesBin`, `energieBin`, `anomalie` FROM `TirageBooster` WHERE `idSousExtension` = ${subExt.id};';
                }
                var req = await connection.query(query);
                for (var row in req) {
                    stats.addBoosterDraw((row[0] as Blob).toBytes(), (row[1] as Blob).toBytes(), row[2]);
                }
            });
        }
        catch( e ) {
            if( local && e is StatitikException)
                print(e.msg);
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

    Future<String> login(int mode) async {
        try {
            String uid;
            var prefs = await SharedPreferences.getInstance();

            // Log system
            if(mode==0) {
                uid = await credential.signInWithGoogle();
                prefs.setString('uid', uid);
            } else {
                uid = prefs.getString('uid');
            }

            // Register and check access
            if(uid != null) {
                await registerUser(uid);
            }
        } catch(e) {
            Environment.instance.user = null;
            if( e is StatitikException) {
                return e.msg;
            } else {
                return "Une erreur interne est apparue !";
            }
        }
        return null;
    }

}