import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class Collection
{
  bool migration = false;
  Map languages = {};
  List extensions = [];
  Map subExtensions = {};
  Map cardsExtensions = {};
  int category=0;
  Map pokemons = {};
  Map otherNames = {};
  Map regions = {};
  Map formes  = {};
  Map cards  = {};
  Map illustrator  = {};

  // Admin part
  Map rIllustrator = {};
  Map rRegions     = {};
  Map rCard        = {};
  Map rFormes      = {};
  Map rPokemon     = {};
  Map rOther       = {};

  void clear() {
    languages.clear();
    extensions.clear();
    subExtensions.clear();
    cardsExtensions.clear();
    pokemons.clear();
    regions.clear();
    formes.clear();
    illustrator.clear();
    cards.clear();
    category=0;
  }

  Region getRegion(int id) {
    return regions[id];
  }

  Forme getForme(int id) {
    return formes[id];
  }

  PokemonCard getCard(int id) {
    return cards[id];
  }

  List<Extension> getExtensions(Language language) {
    List<Extension> l = [];
    for(Extension e in extensions) {
      if (e.idLanguage == language.id) {
        l.add(e);
      }
    }
    return l;
  }

  List<SubExtension> getSubExtensions(Extension e) {
    List<SubExtension> l = [];
    for(SubExtension se in subExtensions.values) {
      if (se.idExtension == e.id) {
        l.add(se);
      }
    }
    return l;
  }

  SubExtension? getSubExtensionID(int id) {
    return subExtensions[id];
  }

  PokemonInfo getPokemonID(int id) {
    //if(local) {
    //  if(!pokemons.containsKey(id))
    //    throw StatitikException("pokemons: Missing $id");
    //}
    assert(0 < id && id < (pokemons.length+1));
    return pokemons[id];
  }

  NamedInfo getNamedID(int id) {
    //if(local) {
    //  if(!otherNames.containsKey(id))
    //    throw StatitikException("otherNames: Missing $id");
    //}
    assert(10000 <= id );
    assert((id-10000) < otherNames.length);
    return otherNames[id];
  }

  void readStaticData(connection) async
  {
      var langues = await connection.query("SELECT * FROM `Langue`");
      for (var row in langues) {
        languages[row[0]] = Language(id: row[0], image: row[1]);
      }

      var exts = await connection.query("SELECT * FROM `Extension` ORDER BY `code` DESC");
      for (var row in exts) {
        extensions.add(Extension(id: row[0], name: row[2], idLanguage: row[1]));
      }
      int idPoke=1;
      var pokes = await connection.query("SELECT * FROM `Pokemon`");
      for (var row in pokes) {
        try {
          pokemons[row[0]] = PokemonInfo(names: row[2].split('|'), generation: row[1], idPokedex: idPoke);
          idPoke += 1;
        } catch(e) {
          print("Bad pokemon: ${row[0]} $e");
        }
      }
      var objSup = await connection.query("SELECT * FROM `DresseurObjet`");
      for (var row in objSup) {
        try {
          otherNames[row[0]] = NamedInfo(row[1].split('|'));
        } catch(e) {
          print("Bad Object: ${row[0]} $e");
        }
      }

      var regionRes = await connection.query("SELECT * FROM `Region`");
      for (var row in regionRes) {
        try {
          regions[row[0]] = Region(row[1].split('|'), row[2].split('|'));
        } catch(e) {
          print("Bad Region: ${row[0]} $e");
        }
      }

      var formeRes = await connection.query("SELECT * FROM `Forme`");
      for (var row in formeRes) {
        try {
          formes[row[0]] = Forme(row[1].split('|'));
        } catch(e) {
          print("Bad Forme: ${row[0]} $e");
        }
      }

      var illustratorRes = await connection.query("SELECT * FROM `Illustrateur`");
      for (var row in illustratorRes) {
        try {
          illustrator[row[0]] = Illustrator(row[1]);
        } catch(e) {
          print("Bad Illustrateur: ${row[0]} $e");
        }
      }

      // Read cards info
      var cardsReq = await connection.query("SELECT * FROM `Cartes`");
      for (var row in cardsReq) {
        List<Pokemon> pokemons = [];

        // Extract name
        var nameBytes = (row[1] as Blob).toBytes().toList();
        int pointerName = 0;
        while(pointerName < nameBytes.length) {
          pokemons.add(Pokemon.loadBytes(pointerName, nameBytes));
        }

        var level     = Level.values[row[2]];
        var typeBytes = (row[3] as Blob).toBytes().toList();
        var type      = Type.values[typeBytes[0]];

        PokemonCard p = PokemonCard(pokemons, level, type);
        if(typeBytes.length > 1) {
          p.typeExtended = Type.values[typeBytes[1]];
        }
        cards[row[0]] = p;
      }

      var cardsExtensionRes = await connection.query("SELECT * FROM `CartesExtension`;");
      for(var row in cardsExtensionRes) {
        if(row[1] != null) {
          cardsExtensions[row[0]] = SubExtensionCards.build((row[1] as Blob).toBytes().toList(), row[2]);
        }
      }

      var subExts = await connection.query("SELECT * FROM `SousExtension` ORDER BY `code` DESC");
      for (var row in subExts) {
        try {
          subExtensions[row[0]] = SubExtension(row[0], row[2], row[3], row[1], row[6], cardsExtensions[row[4]]);
        } catch(e) {
          print("Bad SubExtension: ${row[2]} $e");
        }
      }

      var catExts = await connection.query("SELECT COUNT(*) FROM `Categorie`;");
      for (var row in catExts) {
        category = row[0];
      }
  }

  void adminReverse() {
    rIllustrator = Environment.instance.collection.illustrator.map((k, v) => MapEntry(v, k));
    rRegions     = Environment.instance.collection.regions.map((k, v) => MapEntry(v, k));
    rCard        = Environment.instance.collection.cards.map((k, v) => MapEntry(v, k));
    rFormes      = Environment.instance.collection.formes.map((k, v) => MapEntry(v, k));
    rPokemon     = Environment.instance.collection.pokemons.map((k, v) => MapEntry(v, k));
    rOther       = Environment.instance.collection.otherNames.map((k, v) => MapEntry(v, k));
  }

  void readOldDatabaseToConvert(connection) async {
    bool update = false;
    List<ListCards> toUpdateCards =[];
    var lstCards = await connection.query("SELECT `idListeCartes`, `cartes`, `carteNoms`, `carteInfos` FROM `ListeCartes`");
    for (var row in lstCards) {
      ListCards c = ListCards();
      try {
        // Skip already migrate
        if(cardsExtensions.containsKey(row[0]))
          continue;

        update = true;

        c.extractCard(row[1]);
        assert(c.cards.isNotEmpty);
        // Extract Names
        if( row[2] != null ) {
          int idCard=0;
          try {
            final byteData = (row[2] as Blob).toBytes().toList();

            for (int id = 0; id < byteData.length; ) {
              assert( idCard < c.cards.length );
              var card = c.cards[idCard];
              id = card.extractNameByte(id, byteData);
              idCard+=1;
            }
          } catch(e) {
            printOutput("Data corruption: ListCardName ${row[0]} : $idCard = $e");
          }
        }
        // Extract Info
        if( row[3] != null ) {
          try {
            final byteData = (row[3] as Blob).toBytes().toList();

            if( byteData.length == c.cards.length * 3 ) {
              int idCard = 0;
              for (int id = 0; id < byteData.length;) {
                var card = c.cards[idCard];
                id = card.extractInfoByte3(id, byteData);
                idCard += 1;
              }
              toUpdateCards.add(c);

            } else if( byteData.length == c.cards.length * 5 ) {
              int idCard = 0;
              for (int id = 0; id < byteData.length;) {
                var card = c.cards[idCard];
                id = card.extractInfoByte5(id, byteData);
                idCard += 1;
              }
            } else {
              throw StatitikException("Bad data info size.");
            }
          } catch(e) {
            printOutput("Data corruption: ListCardInfo ${row[0]} $e");
          }
        }
      } catch(e) {
        printOutput("Bad cards list: $e");
      }

      // Convert
      int idCard = cards.length + 1;
      List<List<PokemonCardExtension>> allCardEx = [];
      c.cards.forEach((card) {
        List<Pokemon> pokeName = [];
        card.names.forEach((name) {
          Region? r;
          if(name.region == PokeRegion.Alola)
            r = regions[1];
          if(name.region == PokeRegion.Galar)
            r = regions[2];
          pokeName.add(Pokemon(name.name, region: r));
        });
        // Create new card
        PokemonCard newCard = new PokemonCard(pokeName, Level.Base, card.type);
        newCard.saveDatabase(connection, idCard, true);
        Environment.instance.collection.cards[idCard] = newCard;

        idCard += 1;
        // Add into List
        allCardEx.add([PokemonCardExtension(newCard, card.rarity)]);
      });

      // Update Collection data
      rCard = Environment.instance.collection.cards.map((k, v) => MapEntry(v, k));

      SubExtensionCards extensions = SubExtensionCards(allCardEx);
      await extensions.saveDatabase(connection, row[0]);

      // Remove migrate data to never migrate again
      await connection.query("DELETE FROM `ListeCartes` WHERE `idListeCartes` = ${row[0]};");
      printOutput("Migration Done for ListeCartes=${row[0]}");
    }
    if( update ) {
      migration = true;
      printOutput("Migration effectuée !");
    }
  }
}