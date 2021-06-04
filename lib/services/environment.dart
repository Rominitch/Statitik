import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/connection.dart';

class StatitikException implements Exception {
    String msg;
    StatitikException(this.msg);
}

enum CredentialMode
{
    Google,
    Phone,
    AutoLog
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
                Environment.instance.login(CredentialMode.AutoLog, null, null);
            }
        } catch(e) {
            Environment.instance.user = null;
        }
    }

    void signInWithGoogle(onSuccess) {
        FirebaseAuth _auth = FirebaseAuth.instance;

        googleSignIn.signIn().then((GoogleSignInAccount? googleSignInAccount) {
            googleSignInAccount!.authentication.then((GoogleSignInAuthentication googleSignInAuthentication) {
                final AuthCredential credential = GoogleAuthProvider.credential(
                    accessToken: googleSignInAuthentication.accessToken,
                    idToken: googleSignInAuthentication.idToken,
                );

                _auth.signInWithCredential(credential).then((UserCredential authResult){
                    onSuccess("google-" + authResult.user!.uid);
                });


            });
        });
    }

    Future<void> signInWithPhone(BuildContext? context, onError, onSuccess) async {
        try {
            FirebaseAuth auth = FirebaseAuth.instance;

            showDialog(
                context: context!,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) { return enterPhone(context); })
                .then( (myPhoneNumber) {
                    if(myPhoneNumber != "") {
                        auth.verifyPhoneNumber(
                            phoneNumber: myPhoneNumber,
                            verificationCompleted: (
                                PhoneAuthCredential credential) {
                                // Sign the user in (or link) with the auto-generated credential
                                auth.signInWithCredential(credential).then((
                                    UserCredential authResult) {
                                    String uid = "telephone-" +
                                        authResult.user!.uid;
                                    onSuccess(uid);
                                }).onError((error, stackTrace) =>
                                    onError('LOG_5', myPhoneNumber));
                            },
                            verificationFailed: (FirebaseAuthException e) {
                                onError('LOG_5', myPhoneNumber);
                            },
                            codeSent: (String verificationId,
                                int? resendToken) async {
                                // Update the UI - wait for the user to enter the SMS code
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    // user must tap button!
                                    builder: (BuildContext context) {
                                        return showAlert(context);
                                    })
                                    .then((smsCode) {
                                        if(smsCode!="") {
                                            // Create a PhoneAuthCredential with the code
                                            PhoneAuthCredential credential = PhoneAuthProvider
                                                .credential(
                                                verificationId: verificationId,
                                                smsCode: smsCode);

                                            // Sign the user in (or link) with the credential
                                            auth.signInWithCredential(credential).then((
                                                UserCredential authResult) {
                                                String uid = "telephone-" +
                                                    authResult.user!.uid;
                                                onSuccess(uid);
                                            }).onError((error, stackTrace) =>
                                                onError('LOG_5', myPhoneNumber));
                                        } else {
                                            onError('LOG_8', null);
                                        }
                                });
                            },
                            timeout: const Duration(seconds: 2 * 60),
                            codeAutoRetrievalTimeout: (
                                String verificationId) {},
                        ).then((value) {}
                        ).onError((error, stackTrace) =>
                            onError('LOG_5', error));
                    } else {
                        onError('LOG_8', null);
                    }
                }
            );
        }
        catch(e) {
            onError(e);
        }
    }

    Future<void> signOutGoogle() async {
        Environment.instance.user = null;
        await googleSignIn.signOut();

        var prefs = await SharedPreferences.getInstance();
        prefs.remove('uid');
    }

    AlertDialog showAlert(BuildContext context) {
        String smsCode="";
        return AlertDialog(
            title: Text(StatitikLocale.of(context).read('LOG_1')),
            content:  TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                    smsCode = value;
                },
                //controller: _textFieldController,
                decoration: InputDecoration(hintText: "Sms code"),
            ),
            actions: <Widget>[
                TextButton(
                    child: Text(StatitikLocale.of(context).read('confirm')),
                    onPressed: () {
                        Navigator.of(context).pop(smsCode);
                    },
                ),
                TextButton(
                    child: Text(StatitikLocale.of(context).read('cancel')),
                    onPressed: () {
                        Navigator.of(context).pop("");
                    },
                ),
            ],
        );
    }

    AlertDialog enterPhone(BuildContext context) {
        String smsCode="";
        return AlertDialog(
            title: Text(StatitikLocale.of(context).read('LOG_6')),
            content:  TextField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                    smsCode = value;
                },
                //controller: _textFieldController,
                decoration: InputDecoration(hintText: StatitikLocale.of(context).read('LOG_7')),
            ),
            actions: <Widget>[
                TextButton(
                    child: Text(StatitikLocale.of(context).read('confirm')),
                    onPressed: () {
                        Navigator.of(context).pop(smsCode);
                    },
                ),
                TextButton(
                    child: Text(StatitikLocale.of(context).read('cancel')),
                    onPressed: () {
                        Navigator.of(context).pop("");
                    },
                ),
            ],
        );
    }
}

class Database
{
    final String version = '1.5';
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

class Collection
{
    List languages = [];
    List extensions = [];
    List subExtensions = [];
    Map listCards = {};
    int category=0;
    Map pokemons = {};
    Map otherNames = {};

    void clear() {
        languages.clear();
        extensions.clear();
        subExtensions.clear();
        listCards.clear();
        pokemons.clear();
        category=0;
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
    void addListCards(ListCards l, int id) {
        listCards[id] = l;
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

    SubExtension? getSubExtensionID(int id) {
        for(SubExtension se in subExtensions) {
            if (se.id == id) {
                return se;
            }
        }
        return null;
    }

    ListCards? getListCardsID(int id) {
        return listCards[id];
    }

    void addPokemon(PokemonInfo p, int id) {
        pokemons[id] = p;
    }
    void addNamed(NamedInfo p, int id) {
        otherNames[id] = p;
    }

    PokemonInfo getPokemonID(int id) {
        return id > 0 ? pokemons[id] : null;
    }

    NamedInfo getNamedID(int id) {
        return id >= 10000 ? otherNames[id] : null;
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
    final String version = '0.8.2';

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
    UserPoke? user;
    late SessionDraw currentDraw;

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
                var pokes = await connection.query("SELECT * FROM `Pokemon`");
                for (var row in pokes) {
                    try {
                        PokemonInfo p = PokemonInfo(names: row[2].split('|'), generation: row[1]);
                        collection.addPokemon(p, row[0]);
                    } catch(e) {
                        print("Bad pokemon: ${row[0]} $e");
                    }
                }
                var objSup = await connection.query("SELECT * FROM `DresseurObjet`");
                for (var row in objSup) {
                    try {
                        collection.addNamed(NamedInfo(names: row[1].split('|')), row[0]);
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
                        List<int> pokeCode = [];
                        if( row[2] != null) {
                            try {
                                final byteData = (row[2] as Blob)
                                    .toBytes()
                                    .toList();
                                for (int id = 0; id < byteData.length; id += 2) {
                                    pokeCode.add(
                                        (byteData[id] << 8) + byteData[id + 1]);
                                }
                                c.extractNamed(pokeCode);
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
                        SubExtension se = SubExtension(id: row[0], name: row[2], icon: row[3], idExtension: row[1], year: row[6], chromatique: row[7],
                            cards: cards);
                        assert(se.info() != null);
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
                final queryStr = 'INSERT INTO `UtilisateurProduit` (idAchat, idUtilisateur, idProduit, anomalie) VALUES ($idAchat, ${user!.idDB}, ${currentDraw.product.idDB}, ${currentDraw.productAnomaly ? 1 : 0})';
                await connection.query(queryStr);

                // Prepare data
                List<List<Object>> draw = [];
                for(BoosterDraw booster in currentDraw.boosterDraws) {
                    assert(booster != null);
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
                printOutput(query);

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
            printOutput("Credential Success: "+uid);
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
            printOutput("Credential Error: "+message);
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
}