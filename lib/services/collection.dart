import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class Collection
{
  bool migration = false;
  Map languages = {};
  Map extensions = {};
  Map subExtensions = {};
  Map cardsExtensions = {};
  int category=0;
  Map pokemons = {};
  Map otherNames = {};
  Map regions = {};
  Map formes  = {};
  Map pokemonCards = {};
  Map illustrator  = {};

  // Admin part
  Map rIllustrator = {};
  Map rRegions     = {};
  Map rPokemonCards= {};
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
    pokemonCards.clear();
    category=0;
  }

  Region getRegion(int id) {
    return regions[id];
  }

  Forme getForme(int id) {
    return formes[id];
  }

  List<Extension> getExtensions(Language language) {
    List<Extension> l = [];
    for(Extension e in extensions.values) {
      if (e.language == language) {
        l.add(e);
      }
    }
    return l;
  }

  List<SubExtension> getSubExtensions(Extension e) {
    List<SubExtension> l = [];
    for(SubExtension se in subExtensions.values) {
      if (se.extension == e) {
        l.add(se);
      }
    }
    return l;
  }

  PokemonInfo getPokemonID(int id) {
    assert(pokemons.isNotEmpty);
    assert(0 < id && id < (pokemons.length+1));
    return pokemons[id];
  }

  NamedInfo getNamedID(int id) {
    assert(otherNames.isNotEmpty);
    assert(10000 <= id );
    assert((id-10000) < otherNames.length);
    return otherNames[id];
  }

  Future<void> readStaticData(connection) async
  {
      var langues = await connection.query("SELECT * FROM `Langue`");
      for (var row in langues) {
        languages[row[0]] = Language(id: row[0], image: row[1]);
      }
      assert(languages.isNotEmpty);

      var exts = await connection.query("SELECT * FROM `Extension` ORDER BY `code` DESC");
      for (var row in exts) {
        extensions[row[0]] = Extension(row[0], row[2], languages[row[1]]);
      }
      assert(extensions.isNotEmpty);

      int idPoke=1;
      var pokes = await connection.query("SELECT * FROM `Pokemon`");
      for (var row in pokes) {
        try {
          pokemons[row[0]] = PokemonInfo(names: row[2].split('|'), generation: row[1], idPokedex: idPoke);
          idPoke += 1;
        } catch(e) {
          printOutput("Bad pokemon: ${row[0]} $e");
        }
      }
      assert(pokemons.isNotEmpty);

      var objSup = await connection.query("SELECT * FROM `DresseurObjet`");
      for (var row in objSup) {
        try {
          otherNames[row[0]] = NamedInfo(row[1].split('|'));
        } catch(e) {
          printOutput("Bad Object: ${row[0]} $e");
        }
      }
      assert(otherNames.isNotEmpty);

      var regionRes = await connection.query("SELECT * FROM `Region`");
      for (var row in regionRes) {
        try {
          regions[row[0]] = Region(row[1].split('|'), row[2].split('|'));
        } catch(e) {
          printOutput("Bad Region: ${row[0]} $e");
        }
      }
      assert(regions.isNotEmpty);

      var formeRes = await connection.query("SELECT * FROM `Forme`");
      for (var row in formeRes) {
        try {
          formes[row[0]] = Forme(row[1].split('|'));
        } catch(e) {
          printOutput("Bad Forme: ${row[0]} $e");
        }
      }
      assert(formes.isNotEmpty);

      var illustratorRes = await connection.query("SELECT * FROM `Illustrateur`");
      for (var row in illustratorRes) {
        try {
          illustrator[row[0]] = Illustrator(row[1]);
        } catch(e) {
          printOutput("Bad Illustrateur: ${row[0]} $e");
        }
      }
      assert(illustrator.isNotEmpty);

      // Read cards info
      var cardsReq = await connection.query("SELECT * FROM `Cartes`");
      for (var row in cardsReq) {
        List<Pokemon> namePokemons = [];
        if(row[1] != null)
        {
          // Extract name
          ByteParser nameBytes = ByteParser((row[1] as Blob).toBytes().toList());

          while(nameBytes.pointer < nameBytes.byteArray.length) {
            namePokemons.add(Pokemon.loadBytes(nameBytes));
          }
        }

        var level     = Level.values[row[2]];
        var typeBytes = (row[3] as Blob).toBytes().toList();
        var type      = Type.values[typeBytes[0]];

        // Extract markers
        CardMarkers markers;
        if( row[5] != null) {
          markers = CardMarkers.fromByte(ByteParser((row[5] as Blob).toBytes().toList()));
        } else {
          markers = CardMarkers();
        }

        PokemonCardData p = PokemonCardData(namePokemons, level, type, markers);
        if(typeBytes.length > 1) {
          p.typeExtended = Type.values[typeBytes[1]];
        }
        pokemonCards[row[0]] = p;
      }

      var cardsExtensionRes = await connection.query("SELECT * FROM `CartesExtension`;");
      for(var row in cardsExtensionRes) {
        try {
          var naming = row[2];
          List<CodeNaming> codeNaming = [];
          // Extract code naming
          if(naming != null) {
            naming.split("|").forEach((element) {
              if(element.isNotEmpty) {
                var item = element.split(":");
                assert(item.length == 2);
                codeNaming.add(CodeNaming(int.parse(item[0]), item[1]));
              }
            });
          }

          cardsExtensions[row[0]] = (row[1] != null)
              ? SubExtensionCards.build(ByteParser((row[1] as Blob).toBytes().toList()), codeNaming)
              : SubExtensionCards([], codeNaming);
        } catch(e) {
          printOutput("Bad SubExtensionCards: ${row[0]} $e");
        }
      }
      assert(cardsExtensions.isNotEmpty);

      var subExts = await connection.query("SELECT * FROM `SousExtension` ORDER BY `code` DESC");
      for (var row in subExts) {
        try {
          SubExtensionCards seCards = cardsExtensions[row[4]];
          subExtensions[row[0]] = SubExtension(row[0], row[2], row[3], extensions[row[1]], row[6], seCards);
        } catch(e) {
          printOutput("Bad SubExtension: ${row[0]} $e");
        }
      }
      assert(subExtensions.isNotEmpty);

      var catExts = await connection.query("SELECT COUNT(*) FROM `Categorie`;");
      for (var row in catExts) {
        category = row[0];
      }
  }

  void adminReverse() {
    rIllustrator = Environment.instance.collection.illustrator.map((k, v) => MapEntry(v, k));
    rRegions     = Environment.instance.collection.regions.map((k, v) => MapEntry(v, k));
    rPokemonCards= Environment.instance.collection.pokemonCards.map((k, v) => MapEntry(v, k));
    rFormes      = Environment.instance.collection.formes.map((k, v) => MapEntry(v, k));
    rPokemon     = Environment.instance.collection.pokemons.map((k, v) => MapEntry(v, k));
    rOther       = Environment.instance.collection.otherNames.map((k, v) => MapEntry(v, k));
  }
/*
  Future<void> readOldDatabaseToConvert() async {
    migration = false;
    var lstCards;
    await Environment.instance.db.transactionR(
        (connection) async {
          lstCards = await connection.query("SELECT `idListeCartes`, `cartes`, `carteNoms`, `carteInfos` FROM `ListeCartes`");
        }
    );

    bool update = false;
    for (var row in lstCards) {
      ListCards c = ListCards();
      try {
        // Skip already migrate
        SubExtensionCards cardsEx = cardsExtensions[row[0]];
        if(cardsEx.cards.length > 0)
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
      printOutput("Migration Start for ListeCartes=${row[0]}");
      await Environment.instance.db.transactionR((connection) async {
        // Convert
        int idCard = pokemonCards.length + 1;
        List<List<PokemonCardExtension>> allCardEx = [];
        for( var card in c.cards) {
          // Read name
          List<Pokemon> pokeName = [];
          card.names.forEach((name) {
            Region? r;
            if (name.region == PokeRegion.Alola)
              r = regions[1];
            if (name.region == PokeRegion.Galar)
              r = regions[2];
            pokeName.add(Pokemon(name.name, region: r));
          });

          // Read markers
          CardMarkers markers = CardMarkers.from(card.info.markers);

          // Create new card
          PokemonCardData newCard = new PokemonCardData(
              pokeName, Level.Base, card.type, markers);
          await newCard.saveDatabase(connection, idCard, true);
          pokemonCards[idCard] = newCard;

          idCard += 1;
          // Add into List
          allCardEx.add([PokemonCardExtension(newCard, card.rarity)]);
        }

        // Update Collection data
        rPokemonCards = pokemonCards.map((k, v) => MapEntry(v, k));

        // Set latest cards info
        SubExtensionCards extensions = cardsExtensions[row[0]];
        extensions.cards = allCardEx;
        await extensions.saveDatabase(connection, row[0]);

        // Remove migrate data to never migrate again
        await connection.query("DELETE FROM `ListeCartes` WHERE `idListeCartes` = ${row[0]};");
        printOutput("Migration Done for ListeCartes=${row[0]}");
      });
    }

    if( update ) {
      migration = true;
      printOutput("Migration effectuée !");
    }
  }

  Future<void> convertNewDrawFormat() async
  {
      // Migration boosterDraw
      await Environment.instance.db.transactionR((connection) async {
        // Get all data
        var boosterDraw = await connection.query("SELECT * FROM `TirageBooster`;");

        // Convert
        List<List<Object?>> data = [];
        for(var row in boosterDraw) {
          var drawData = (row[4] as Blob).toBytes().toList();

          // Stupid check to see if migration is done
          if(drawData[0] == 1 && drawData[2] == 1 && drawData[4] == 1 ) {
            printOutput("SKIP Migration from ${row[1]}");
            return;
          }

          assert(subExtensions.containsKey(row[1]));
          SubExtension se = subExtensions[row[1]];
          List<int> draw = [];
          int idCard=0;
          for(var code in drawData) {
            var allCards = se.seCards.cards[idCard];
            draw.add(allCards.length);
            draw.add(code);
            for(int i=1; i < allCards.length; i+=1) {
              draw.add(0);
            }
            idCard += 1;
          }
          List<Object?> obj = [row[0], row[1], row[2], row[3], Int8List.fromList(draw)];
          data.add(obj);
        }

        // Remove all
        await connection.query("TRUNCATE TABLE `TirageBooster`;");
        // Add
        for(var info in data) {
          await connection.query("INSERT INTO `TirageBooster` VALUES(?, ?, ?, ?, ?);", info);
        }
      });

      migration = true;
      printOutput("Migration effectuée !");
  }
 */
}