import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/saved_instance_state.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:statitikcard/services/draw/booster_draw.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/draw/session_draw.dart';

import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/collection.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/image_storage.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/new_cards_report.dart';
import 'package:statitikcard/services/models/pokespace.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/time_report.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:wakelock/wakelock.dart';

class StatitikException implements Exception {
    String msg;
    StatitikException(this.msg);
}

class Database
{
    final String version = '3.5';
    final ConnectionSettings settings = createConnection();

    Future<bool> transactionR(Future Function(TransactionContext) queries) async
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
        } catch( e, stacktrace ) {
            printOutput(e.toString());
            printOutput(stacktrace.toString());
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
    final StreamController<bool>   onInitialize  = StreamController<bool>();
    final StreamController<String> onServerError = StreamController<String>();
    final StreamController<String> onInfoLoading = StreamController<String>();

    // Manager
    Credential credential = Credential();
    Database   db         = Database();

    // Const data
    final String nameApp = 'StatitikCard';
    final String version = '2.2.8';

    // State
    bool isInitialized          = false;
    bool startDB                = false;
    bool showExtensionName      = false;
    bool showPressImages        = false;
    bool showPressProductImages = false;
    bool showTCGImages          = false;
    bool isMaintenance          = false;

    bool storeImageLocally      = true;

    SavedInstanceState state = SavedInstanceState();

    // Cached data
    Collection collection = Collection();

    // Current draw
    UserPoke? user;
    SessionDraw? currentDraw;

    ImageStorage storage = ImageStorage();

    static const double heightTabHeader     = 40.0;
    static const double heightCircleAvatar  = 25.0;
    static const double heightNewsCircle    = 36.0;
    static const double heightlanguage      = 30.0;

    void initialize()
    {
        // General data control
        assert(TypeCard.values.length <= 255);
        assert(TypeCard.values.length == orderedType.length);
        assert(TypeCard.values.length == typeColors.length);

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
                        showPressProductImages = (row[3] == 1);
                        showTCGImages          = (row[4] == 1);
                        isMaintenance          = (row[5] == 1);
                    }
                }).then( (result) {
                    isDBReady = result;
                }).whenComplete( () {
                    if(!isDBReady) {
                        throw StatitikException('DB_0');
                    }
                    if(!isDatabaseMatch) {
                        throw StatitikException('DB_1');
                    }

                    // Load user
                    onInfoLoading.add('LOAD_0');
                    credential.initialize().whenComplete(() {
                        // Load database
                        onInfoLoading.add('LOAD_1');
                        readStaticData().whenComplete(() async {
                            if (isAdministrator()) {
                                await db.transactionR( collection.migration );
                                printOutput("admin is launched !");
                                onInfoLoading.add('LOAD_2');
                                collection.adminReverse();
                            } else {
                                if(isMaintenance) {
                                    throw StatitikException('DB_2');
                                }
                            }
                            onInfoLoading.add('LOAD_5');
                            (readPokeSpace()).whenComplete( () async {
                                SharedPreferences.getInstance().then((prefs) {
                                    storeImageLocally = prefs.getBool("storeImageLocaly") ?? storeImageLocally;
                                    setScreenOn(prefs.getBool("ScreenOn") ?? false);
                                }).whenComplete(() {
                                    try {
                                        Environment.instance.tryChangeUserConnexionDate(Environment.instance.user!.uid);
                                    } catch(e) {
                                        printOutput(e.toString());
                                    }

                                    isInitialized = true;
                                    onInitialize.add(isInitialized);
                                });
                            });
                        }).catchError((error) {
                            isInitialized = false;
                            onServerError.add(error.message);
                        });
                    });
                }).catchError((error) {
                    isInitialized = false;
                    var message = error is StatitikException ? error.msg : error.toString();
                    onServerError.add(message);
                }).onError((error, stackTrace) {
                    isInitialized = false;
                    onServerError.add('Error');
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
            printOutput("Clean Database");
            // Avoid reentrance
            collection.clear();

            printOutput("Read Database");
            await db.transactionR( collection.readStaticData );

            startDB = true;
        }
    }

    Future<void> restoreAdminData() async {
        // Reload full database to have all real data
        startDB=false;
        db = Database();
        // Read static
        await readStaticData();
        // Migrate if needed
        await db.transactionR( collection.migration );
        // Finalize data
        collection.adminReverse();
        // Change poke space
        user!.pokeSpace = PokeSpace();
        await readPokeSpace();
    }

    Future<void> registerUser(String oldUID, String uid, bool isTest) async {
        if (user == null) {
            var time = TimeReport();
            await db.transactionR( (connection) async {
                String query = 'SELECT `idUtilisateur`, `ban`, `su` FROM `Utilisateur` WHERE `identifiant` = \'$oldUID\';';
                var reqUser = await connection.query(query);
                if( reqUser.length == 1 ) {
                    for (var row in reqUser) {
                        if(row[1] != 0) {
                          throw StatitikException("Utilisateur banni pour non respect des règles.");
                        }
                        // Migrate to new ID
                        var reqQuery = "UPDATE `Utilisateur` SET `identifiant` = '$uid' WHERE `identifiant` = '$oldUID';";
                        await connection.query(reqQuery);

                        user = UserPoke(row[0]);
                        user!.admin = row[2] == 1 ? true : false;
                    }
                } else {
                    String query = 'SELECT `idUtilisateur`, `ban`, `su` FROM `Utilisateur` WHERE `identifiant` = \'$uid\';';
                    var reqUser = await connection.query(query);
                    if( reqUser.length == 1 ) {
                        for (var row in reqUser) {
                            if(row[1] != 0) {
                                throw StatitikException("Utilisateur banni pour non respect des règles.");
                            }
                            user = UserPoke(row[0]);
                            user!.admin = row[2] == 1 ? true : false;
                        }
                    } else {
                        // Check user data exists into database
                        int idNewID=-1;
                        var reqCountUser = await connection.query(
                            'SELECT MAX(`idUtilisateur`) FROM `Utilisateur`;');
                        for (var row in reqCountUser) {
                            idNewID = row[0] + 1;
                        }
                        var nowDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                        await connection.query("INSERT INTO `Utilisateur` (idUtilisateur, identifiant, dernierConnexion) VALUES ($idNewID, '$uid', '$nowDate');");
                        user = UserPoke(idNewID);
                    }
                }
                user!.uid = uid;
                user!.isRobotTest = isTest;
            });
            time.tick("My User");
        }
    }

    Future<void> tryChangeUserConnexionDate(String uid) async {
        if (uid.isNotEmpty) {
            var time = TimeReport();
            await db.transactionR( (connection) async {
                var nowDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                String query = "UPDATE `Utilisateur` SET `dernierConnexion` = '$nowDate' WHERE (`identifiant` = '$uid');";
                await connection.query(query);
            });
            time.tick("Update connexion time");
        }
    }

    Future<void> readPokeSpace() async {
        if (user != null) {
            var time = TimeReport();
            await db.transactionR( (connection) async {
                String query = 'SELECT `pokespace` FROM `Utilisateur` WHERE `idUtilisateur` = \'${user!.idDB}\';';
                var reqUser = await connection.query(query);
                assert( reqUser.length == 1 );

                for (var row in reqUser) {
                    if(row[0] != null) {
                      user!.pokeSpace = PokeSpace.fromBytes((row[0] as Blob).toBytes(),
                            collection.subExtensions,
                            collection.products, collection.productSides);
                    } else {
                        // Retrieve from draw (do one time)
                        String query = 'SELECT `idSousExtension`, `cartesBin`'
                            ' FROM `TirageBooster`, `UtilisateurProduit`'
                            ' WHERE `idUtilisateur` = \'${user!.idDB}\''
                            ' AND `TirageBooster`.`idAchat` = `UtilisateurProduit`.`idAchat`;';
                        var reqUser = await connection.query(query);
                        for (var row in reqUser) {
                            var subExt = collection.subExtensions[row[0]]!;
                            var bytes = (row[1] as Blob).toBytes().toList();
                            ExtensionDrawCards edc = ExtensionDrawCards.fromBytes(subExt, bytes);

                            user!.pokeSpace.add(subExt, edc);
                        }

                        // Added product
                        String queryProd = 'SELECT `idProduit`'
                            ' FROM `UtilisateurProduit`'
                            ' WHERE `idUtilisateur` = \'${user!.idDB}\';';
                        var reqProdUser = await connection.query(queryProd);
                        for (var row in reqProdUser) {
                            user!.pokeSpace.insertProduct(collection.products[row[0]]!, UserProductCounter.fromOpened());
                        }
                        // Finally compute all stats
                        user!.pokeSpace.computeStats();
                    }
                }
            });
            time.tick("My pokespace");
        }
    }

    Future<void> sendPokeSpace(connection) {
        return connection.queryMulti('UPDATE `Utilisateur` SET `pokespace` = ?'
            ' WHERE `idUtilisateur` = \'${user!.idDB}\';',
            [[Int8List.fromList(user!.pokeSpace.toBytes())]]);
    }

    Future<NewCardsReport?> sendDraw([bool registerPokeSpace=true]) async {
        if( !isLogged() ) {
          return null;
        }
        try {
            var report = NewCardsReport();

            await db.transactionR( (connection) async {
                var time = TimeReport();
                // NEVER send stats data if robot test BUT save into personal Pokespace
                if(!user!.isRobotTest) {
                    // Get new ID
                    int idAchat = 1;
                    var req = await connection.query('SELECT MAX(idAchat) FROM `UtilisateurProduit`;');
                    for (var row in req) {
                        idAchat = row[0] + 1;
                    }

                    // Add new product
                    final queryStr = 'INSERT INTO `UtilisateurProduit` (idAchat, idUtilisateur, idProduit, anomalie) VALUES ($idAchat, ${user!.idDB}, ${currentDraw!.product.idDB}, ${currentDraw!.productAnomaly ? 1 : 0})';
                    await connection.query(queryStr);

                    // Prepare data
                    List<List<Object?>> draw = [];
                    for(BoosterDraw booster in currentDraw!.boosterDraws) {
                        draw.add(<Object?>[idAchat, booster.subExtension!.id, booster.abnormal ? 1 : 0, Int8List.fromList(booster.cardDrawing!.toBytes())]);
                    }
                    // Send data
                    await connection.queryMulti('INSERT INTO `TirageBooster` (idAchat, idSousExtension, anomalie, cartesBin) VALUES (?, ?, ?, ?);',
                                                draw);
                } else {
                    printOutput("RobotTest skip data send");
                }
                time.tick("Register draw");
                // Update pokespace and save into db
                if(registerPokeSpace) {
                    report = user!.pokeSpace.insertSessionDraw(currentDraw!);
                    await sendPokeSpace(connection);
                    time.tick("Save pokespace");
                }
            });
            return report;
        } catch( e ) {
            printOutput("Database error $e");
        }
        return null;
    }

    Future<void> removeUser() async {
        if( !isLogged() ) {
          return;
        }

        try {
            await db.transactionR( (connection) async {
                await connection.query('UPDATE `Utilisateur` SET `identifiant` = \'unregistred\' WHERE `identifiant` = \'${user!.uid}\';');

                user = null;
            });
        }
        catch( _ ) {}
    }

    Future<StatsBooster> getStats(SubExtension subExt, Product? product, ProductCategory? category, [int? user]) async {
        StatsBooster stats = StatsBooster(subExt: subExt);
        try {
            String userReq = '';
            if(user != null) {
              userReq = 'AND `UtilisateurProduit`.`idUtilisateur` = $user ';
            }

            await db.transactionR( (connection) async {
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
                        ExtensionDrawCards edc = ExtensionDrawCards.fromBytes(subExt, bytes);

                        stats.addBoosterDraw(edc, row[1]);
                    } catch(e) {
                        printOutput("Stats extraction failure - SE=${subExt.id} : $e");
                    }
                }
            });
        }
        catch( e ) {
            if( e is StatitikException) {
              printOutput(e.msg);
            }
        }
        return stats;
    }

    void showAbout(context) {
        showAboutDialog(
            context: context,
            applicationVersion: version,
            //applicationIcon:
            applicationLegalese: 'Copyright (c) 2021 - 2022 Rominitch',
            applicationName: nameApp,
            children:[]
        );
    }

    void showDisclaimer(context) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(StatitikLocale.of(context).read('disclaimer_T0'), style: Theme.of(context).textTheme.headline3),
          content: SingleChildScrollView(
            child: Text( nameApp + StatitikLocale.of(context).read('disclaimer'),
              textAlign: TextAlign.justify
            ),
          )
        )
      );
    }

    bool isLogged() {
        return user != null;
    }

    bool isAdministrator() {
        return isLogged() && user!.admin;
    }

    void savePokeSpace(BuildContext context, PokeSpace pokeSpace) {
        EasyLoading.show();

        pokeSpace.computeStats();

        Environment.instance.db.transactionR((connection) async {
            await Environment.instance.sendPokeSpace(connection);
        }).then((value) {
            EasyLoading.dismiss();
        }).onError((error, stackTrace) {
            EasyLoading.showError(StatitikLocale.of(context).read('error'));
            printOutput("$error\n${stackTrace.toString()}");
        });
    }


    void login(CredentialMode mode, context, {Function()? afterLog, Function(String)? afterError}) async {
        onSuccess(googleID, oldUID, bool? isTest) {
            //printOutput("Credential Success: "+uid);
            SharedPreferences.getInstance().then((prefs) {
                var isRobotTest = isTest ?? false;
                // Save to preferences
                prefs.setString('userID', googleID);
                prefs.setString('uid',    oldUID);
                prefs.setBool('isTest',   isRobotTest);

                // Register and check access
                assert(googleID != null);
                assert(oldUID != null);
                registerUser(oldUID, googleID, isRobotTest).then((value){
                    if(afterLog != null) {
                      afterLog();
                    }
                });
            });
        }
        onError(codeMessage, [code]) {
            //printOutput("Credential Error: "+message);
            var message = sprintf(StatitikLocale.of(context).read(codeMessage), [code]);
            Environment.instance.user = null;

            if(afterError != null) {
              afterError(message);
            }
        }
        try {
            // Log system
            if(mode==CredentialMode.phone) {
                credential.signInWithPhone(context, onError, onSuccess);
            } else if(mode==CredentialMode.google) {
                credential.signInWithGoogle(onSuccess);
            } else if(mode==CredentialMode.autoLog) {
                SharedPreferences.getInstance().then((prefs) {
                    onSuccess(prefs.getString('userID'), prefs.getString('uid'), prefs.getBool('isTest'));
                });
            } else {
                onError('LOG_3');
            }
        } catch(e) {
            onError('LOG_4');
        }
    }

    Future<List<SessionDraw>> getMyDraw([bool showAll=false]) async
    {
        List<SessionDraw> myBooster = [];
        if( isLogged() ) {
            try {
                String filteredUser = (showAll && isAdministrator()) ? '' : ' WHERE `UtilisateurProduit`.`idUtilisateur`= \'${user!.idDB}\'';

                await db.transactionR( (connection) async {
                    String query = 'SELECT `idAchat`, `anomalie`, `idProduit`'
                        ' FROM `UtilisateurProduit`'
                        ' $filteredUser'
                        ' ORDER BY `idAchat` DESC';
                    printOutput(query);

                    var req = await connection.query(query);
                    for (var row in req) {
                        // Start session
                        Product p = collection.products[row[2]]!;
                        var session = SessionDraw(p, p.language!);
                        session.idAchat        = row[0];
                        session.productAnomaly = row[1] != 0;

                        // Read user data
                        var reqUserBoosters = await connection.query("SELECT `idSousExtension`, `anomalie`, `cartesBin` "
                            " FROM `TirageBooster`"
                            " WHERE `idAchat` = '${session.idAchat}'");
                        int id=0;
                        for (var rowUserBooster in reqUserBoosters) {
                            BoosterDraw booster;
                            if(id >= session.boosterDraws.length) {
                                session.addNewBooster();
                            }
                            booster = session.boosterDraws[id];

                            var subEx = collection.subExtensions[rowUserBooster[0]];
                            var edc = ExtensionDrawCards.fromBytes(subEx, (rowUserBooster[2] as Blob).toBytes());
                            booster.fill(subEx, rowUserBooster[1]==1, edc);

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
        if( isAdministrator() ) {
            try {
                return db.transactionR( (connection) async {
                    await collection.saveDatabaseSEC(se.seCards, connection);
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return false;
    }

    Future<bool> removeOrphans(cardId) async {
        if( isAdministrator() ) {
            try {
                return await db.transactionR( (connection) async {
                    await collection.removeListCards(cardId, connection);
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return false;
    }

    Future<bool> removeUserProduct(draw) async {
        if( isAdministrator() ) {
            try {
                return await db.transactionR( (connection) async {
                    await collection.removeUserProduct(draw, connection);
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return false;
    }

    Future<int?> addNewDresseurObjectName(String name, int language) async {
        int? id;
        if( isAdministrator() ) {

            try {
                await db.transactionR( (connection) async {
                    id = await collection.addNewDresseurObjectName(name, language, connection);
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return id;
    }

    Future<int?> addNewEffectName(MultiLanguageString names) async {
        int? id;
        if( isAdministrator() ) {

            try {
                await db.transactionR( (connection) async {

                    id = await collection.addNewEffectName(names, connection);
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return id;
    }

    Future<int?> addNewDescriptionData(MultiLanguageString names) async {
        int? id;
        if( isAdministrator() ) {

            try {
                await db.transactionR( (connection) async {

                    id = await collection.addNewDescriptionData(names, connection);
                });
            } catch( e ) {
                printOutput("Database error $e");
            }
        }
        return id;
    }

    Future<bool> duplicateProducts(Product product) async {

        // Need world
        if( !product.language!.isWorld() ) {
          return false;
        }

        // All world languages
        var languages = [collection.languages[1], collection.languages[2]];
        // Remove current
        languages.remove(product.language!);

        List<Product> products = [];
        for( var newLanguage in languages) {
            // Copy Booster
            List<ProductBooster> boosters = [];
            for(var booster in product.boosters) {
                SubExtension? subExtension;
                if( booster.subExtension != null ) {
                    // Search subextension with same extension cards in new language
                    subExtension = collection.subExtensions.values.firstWhere((element) {
                        return element.extension.language == newLanguage && booster.subExtension!.seCards == element.seCards;
                    });
                }

                var newBooster = ProductBooster(subExtension, booster.nbBoosters, booster.nbCardsPerBooster);
                boosters.add(newBooster);
            }
            Product newProduct = Product(0, newLanguage, product.name, product.imageURL, product.releaseDate, product.category, boosters);

            // Cards
            for(var card in product.otherCards) {
                // Search subextension with same extension cards in new language
                SubExtension? subExtension = collection.subExtensions.values.firstWhere((element) {
                    return element.extension.language == newLanguage && card.subExtension.seCards == element.seCards;
                });
                if(subExtension == null) {
                    printOutput("Impossible to find card SubExtension: ${card.subExtension.name}");
                } else {
                    ProductCard newCard = ProductCard(
                        subExtension, card.idCard, card.design, card.jumbo,
                        card.isRandom, card.counter);
                    newProduct.otherCards.add(newCard);
                }
            }

            // Other products
            for(var other in product.sideProducts.entries) {
                newProduct.sideProducts[other.key] = other.value;
            }

            products.add(newProduct);
        }

        // Send to DB
        return sendProducts(products, true);
    }

    Future<bool> sendProducts(List<Product> products, bool creation) async {
        try {
           return await db.transactionR( (connection) async {
            int maxID = 0;
            String query;
            var productInfo = <List<Object?>>[];
            if (creation) {
                var req = await connection.query('SELECT MAX(idProduit) FROM `Produit`;');
                for (var row in req) {
                    maxID = row[0] + 1;
                }
                query =
                'INSERT INTO `Produit` (`idProduit`, `idLangue`, `nom`, `icone`, `sortie`, `idCategorie`, `contenu` )'
                    ' VALUES (?, ?, ?, ?, ?, ?, ?);';
            } else {
                query =
                'UPDATE `Produit` SET `idLangue` = ?, `nom`= ?, `icone`= ?, `sortie`= ?, `idCategorie`= ?, `contenu`= ?'
                    ' WHERE `idProduit` = ?;';
            }

            for (var product in products) {
                var outDate = DateFormat('yyyy-MM-dd 00:00:00').format(
                    product.releaseDate);

                var myData =
                <Object?>[ product.language!.id, product.name, product.imageURL,
                    outDate, product.category!.idDB,
                    Int8List.fromList(product.toBytes())
                ];
                if (creation) {
                    product.idDB = maxID;
                    maxID += 1;
                    myData.insert(0, product.idDB);
                } else {
                    assert(product.idDB > 0);
                    myData += [product.idDB];
                }

                productInfo.add(myData);
            }
            // Go
            await connection.queryMulti(query, productInfo);
        } );
      }
      catch(e){
        printOutput("Database error $e");
        return false;
      }
    }

    Future<bool> sendSideProducts(List<ProductSide> products, bool creation) async {
        try {
            return await db.transactionR( (connection) async {
                int maxID = 0;
                String query;
                var productInfo = <List<Object?>>[];
                if (creation) {
                    var req = await connection.query('SELECT MAX(idProduitAnnexe) FROM `ProduitAnnexe`;');
                    for (var row in req) {
                        maxID = row[0] + 1;
                    }
                    query =
                    'INSERT INTO `ProduitAnnexe` (`idProduitAnnexe`, `nom`, `image`, `idCategorie`, `dateSortie` )'
                        ' VALUES (?, ?, ?, ?, ?);';
                } else {
                    query =
                    'UPDATE `ProduitAnnexe` SET `nom`= ?, `image`= ?, `idCategorie`= ?, `dateSortie`= ?'
                        ' WHERE `idProduitAnnexe` = ?;';
                }

                for (var product in products) {
                    var outDate = DateFormat('yyyy-MM-dd 00:00:00').format(
                        product.releaseDate);

                    var myData = <Object?>[ product.name, product.imageURL, product.category!.idDB, outDate];
                    if (creation) {
                        product.idDB = maxID;
                        maxID += 1;
                        myData.insert(0, product.idDB);
                    } else {
                        assert(product.idDB > 0);
                        myData += [product.idDB];
                    }

                    productInfo.add(myData);
                }
                // Go
                await connection.queryMulti(query, productInfo);
            } );
        }
        catch(e){
            printOutput("Database error $e");
            return false;
        }
    }

    Widget createDiscordButton() {
        return Card(
            color: const Color(0xFF5865f2),
            child: TextButton(
            onPressed: () => Environment.launchURL(Uri.parse('https://discord.gg/mnJNEka2zN')),
            child: drawCachedImage('press', 'discordBlanc', height: 30.0)
            ),
        );
    }

    static void launchURL(Uri url) async {
        if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication);
        }
    }

    void setScreenOn(bool enable) {
        SharedPreferences.getInstance().then((prefs) {
            prefs.setBool("ScreenOn", enable);
            if( enable) {
                Wakelock.enable();
            } else {
                Wakelock.disable();
            }
        });
    }
}
