import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:statitik_pokemon/services/models.dart';
import 'package:mysql1/mysql1.dart';
import 'package:statitik_pokemon/services/connection.dart';

class Credential
{
    FirebaseAuth _auth;
    String userId;
    FirebaseApp _initialization;

    Future<void> initialize() async
    {
        print("Start firebase");
        _initialization = await Firebase.initializeApp();

        print("Launch Auth");
        _auth = FirebaseAuth.instance;

        print("Ready to work");
    }
    /*
    // auth change user stream
    Stream<String> get user {
        return _auth.authStateChanges().map( (User user) => userId = user.uid );
    }

    // sign in anon
    Future signInAnon() async {
        try {
            return null;
        } catch (e) {
            print(e.toString());
            return null;
        }
    }
    */
}

class Database
{
    final ConnectionSettings settings = createConnection();

    Future<void> transactionR(Function queries) async
    {
        MySqlConnection connection;
        try
        {
            connection = await MySqlConnection.connect(settings);
        } catch( e ) {
            print("Impossible to connect to DB: $e");
            throw e;
        }

        // Execute request
        try {
            await connection.transaction(queries);
        } catch( e ) {
            print("Query error: $e");
            throw e;
        } finally {
            connection.close();
        }
    }
}

class Collection
{
    List languages = [];
    List extensions = [];
    List subExtensions = [];

    void clear() {
        languages.clear();
        extensions.clear();
        subExtensions.clear();
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

    // Manager
    Credential credential = Credential();
    Database db = Database();

    // Const data
    final String nameApp = 'Statitik Pokemon';
    final String version = 'v0.1';

    // State
    bool isInitialized=false;
    bool startDB=false;

    // Cached data
    Collection collection = Collection();

    // Current draw
    UserPoke user;
    List boosterDraws;

    void initialize() async
    {
        if(!isInitialized) {
            // Sync event
            try {
                List responses = await Future.wait(
                    [
                        credential.initialize(),
                        readStaticData(),
                    ]);
            } catch (e) {
                print("Error of init");
            }

            // Debug user
            user = new UserPoke(idDB: 1);

            // Send event
            isInitialized = true;
        }
        onInitialize.add(isInitialized);
    }

    Future<void> readStaticData() async
    {
        if(!startDB) {
            // Avoid reentrance
            startDB = true;
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

                var sub_exts = await connection.query("SELECT * FROM `SousExtension` ORDER BY `code` DESC");
                for (var row in sub_exts) {
                    SubExtension se = SubExtension(id: row[0], name: row[2], icon: row[3], idExtension: row[1]);
                    try {
                        se.extractCard(row[4]);
                        collection.addSubExtension(se);
                    } catch(e) {
                        print("Bad Subextension: $e");
                    }
                }
            });
        }
    }

    Future<List> readProducts(Language l, SubExtension se) async
    {
        List produits = [];
        await db.transactionR( (connection) async {
            var exts = await connection.query("SELECT `Produit`.`idProduit`, `Produit`.`nom`, `Produit`.`icone` FROM `Produit`, `ProduitBooster`"
                " WHERE `Produit`.`approuve` = 1"
                " AND `Produit`.`idProduit` = `ProduitBooster`.`idProduit`"
                " AND `ProduitBooster`.`idSousExtension` = ${se.id}"
                " ORDER BY `Produit`.`nom` ASC");
            for (var row in exts) {
                Map boosters = {};
                var reqBoosters = await connection.query("SELECT `ProduitBooster`.idSousExtension, `ProduitBooster`.nombre FROM `ProduitBooster`"
                    " WHERE `ProduitBooster`.`idProduit` = ${row[0]}");
                for (var row in reqBoosters) {
                    boosters[row[0]] = row[1];
                }
                produits.add(Product(idDB: row[0], name: row[1], imageURL: row[2], boosters: boosters ));
            }
        });
        return produits;
    }

    Future<bool> sendDraw(Product product, bool productAnomaly) async {
        try {
            await db.transactionR( (connection) async {
                int idAchat;
                var req = await connection.query('SELECT count(idAchat) FROM `UtilisateurProduit`;');
                for (var row in req) {
                    idAchat = row[0] + 1;
                }

                //print("Achat id is $idAchat");

                await connection.query('INSERT INTO `UtilisateurProduit` (idAchat, idUtilisateur, idProduit, anomalie) VALUES ($idAchat, ${user.idDB}, ${product.idDB}, ${productAnomaly ? 0 : 1});');

                //print("Insert produit");

                // Prepare data
                List<List<dynamic>> draw = [];
                for(BoosterDraw booster in boosterDraws) {
                    draw.add(booster.buildQuery(idAchat));
                }
                // Send data
                connection.queryMulti('INSERT INTO `TirageBooster` (idAchat, idSousExtension, cartes, anomalie, energie) VALUES (?, ?, ?, ?, ?);',
                    draw);

                print("Insert draw");
            });
            return true;
        } catch( e ) {
            print("Database error $e");
        }
        return false;
    }
}

// import 'services/environment.dart' as G;

/*

// custom event class
class MyEvent {
  String eventData;

  MyEvent(this.eventData);
}

// class that fires when something changes
class SomeClass {
  var changeController = new StreamController<MyEvent>();
  Stream<MyEvent> get onChange => changeController.stream;

  void doSomething() {
    // do the change
    changeController.add(new MyEvent('something changed'));
  }
}

// listen to changes
...
var c = new SomeClass();
c.onChange.listen((e) => print(e.eventData));
 */