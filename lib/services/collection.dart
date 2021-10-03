import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardIntoSubExtensions {
  SubExtension se;
  int          position;

  CardIntoSubExtensions(this.se, this.position);
}

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
  Map illustrators = {};
  Map descriptions = {};
  Map effects      = {};

  // Admin part
  Map rIllustrators = {};
  Map rRegions     = {};
  Map rPokemonCards= {};
  Map rFormes      = {};
  Map rPokemon     = {};
  Map rOther       = {};
  Map rCardsExtensions = {};

  void clear() {
    languages.clear();
    extensions.clear();
    subExtensions.clear();
    cardsExtensions.clear();
    pokemons.clear();
    regions.clear();
    formes.clear();
    illustrators.clear();
    pokemonCards.clear();
    category=0;
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

  CardTitleData getNamedID(int id) {
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
        try {
          extensions[row[0]] = Extension(row[0], row[2], languages[row[1]]);
        } catch(e) {
          printOutput("Bad Extension: ${row[0]} $e");
        }
      }
      assert(extensions.isNotEmpty);

      int idPoke=1;
      var pokes = await connection.query("SELECT * FROM `Pokemon`");
      for (var row in pokes) {
        try {
          pokemons[row[0]] = PokemonInfo(MultiLanguageString(row[2].split('|')), row[1], idPoke);
          idPoke += 1;
        } catch(e) {
          printOutput("Bad pokemon: ${row[0]} $e");
        }
      }
      assert(pokemons.isNotEmpty);

      var objSup = await connection.query("SELECT * FROM `DresseurObjet`");
      for (var row in objSup) {
        try {
          otherNames[row[0]] = CardTitleData(MultiLanguageString(row[1].split('|')));
        } catch(e) {
          printOutput("Bad Object: ${row[0]} $e");
        }
      }
      assert(otherNames.isNotEmpty);

      var regionRes = await connection.query("SELECT * FROM `Region`");
      for (var row in regionRes) {
        try {
          regions[row[0]] = Region(
              MultiLanguageString(row[1].split('|')),
              MultiLanguageString(row[2].split('|')));
        } catch(e) {
          printOutput("Bad Region: ${row[0]} $e");
        }
      }
      assert(regions.isNotEmpty);

      var formeRes = await connection.query("SELECT * FROM `Forme`");
      for (var row in formeRes) {
        try {
          formes[row[0]] = Forme(MultiLanguageString(row[1].split('|')));
        } catch(e) {
          printOutput("Bad Forme: ${row[0]} $e");
        }
      }
      assert(formes.isNotEmpty);

      var illustratorRes = await connection.query("SELECT * FROM `Illustrateur`");
      for (var row in illustratorRes) {
        try {
          illustrators[row[0]] = Illustrator(row[1]);
        } catch(e) {
          printOutput("Bad Illustrateur: ${row[0]} $e");
        }
      }
      assert(illustrators.isNotEmpty);

      var descriptionsRes = await connection.query("SELECT * FROM `Description`");
      for (var row in descriptionsRes) {
        try {
          descriptions[row[0]] = MultiLanguageString(row[1].split('|'));
        } catch(e) {
          printOutput("Bad Description: ${row[0]} $e");
        }
      }
      assert(descriptions.isNotEmpty);

      var effectRes = await connection.query("SELECT * FROM `EffetsCarte`");
      for (var row in effectRes) {
        try {
          effects[row[0]] = MultiLanguageString(row[1].split('|'));
        } catch(e) {
          printOutput("Bad Description: ${row[0]} $e");
        }
      }
      assert(effects.isNotEmpty);

      // Read cards info
      var cardsReq = await connection.query("SELECT * FROM `Cartes`");
      for (var row in cardsReq) {
        // 0 = id
        // 1 = nom
        // 2 = niveau
        // 3 = type
        // 4 = vie
        // 5 = marqueur
        // 6 = effets
        // 7 = retraite
        // 8 = faiblesse
        // 9 = resistance
        // 10 = illustrateur

        List<Pokemon> namePokemons = [];
        if(row[1] != null)
        {
          // Extract name
          ByteParser nameBytes = ByteParser((row[1] as Blob).toBytes().toList());

          while(nameBytes.canParse) {
            namePokemons.add(Pokemon.fromBytes(nameBytes, this));
          }
        }

        var level      = Level.values[row[2]];
        var typeBytes  = (row[3] as Blob).toBytes().toList();
        var type       = Type.values[typeBytes[0]];
        var life       = row[4] ?? 0;
        // Extract markers
        CardMarkers markers;
        if( row[5] != null) {
          markers = CardMarkers.fromBytes((row[5] as Blob).toBytes().toList());
        } else {
          markers = CardMarkers();
        }
        var effects      = row[6] != null ? CardEffects.fromBytes((row[6] as Blob).toBytes().toList()) : null;
        var retreat      = row[7] != null ? (row[7] as Blob).toBytes().toList()[0] : 0;
        var weakness     = row[8] != null ? EnergyValue.fromBytes((row[8] as Blob).toBytes().toList()) : null;
        var resistance   = row[9] != null ? EnergyValue.fromBytes((row[9] as Blob).toBytes().toList()) : null;
        var illustrator  = row[10] != null ? illustrators[row[10]]: null;

        //Build card
        PokemonCardData p = PokemonCardData(namePokemons, level, type, markers, life, retreat, resistance, weakness);
        //Extract typeExtended (for double energy card)
        if(typeBytes.length > 1) {
          p.typeExtended = Type.values[typeBytes[1]];
        }
        //Extract effects
        if( effects != null ) {
          p.cardEffects = effects;
        }
        //Extract illustrator
        if( illustrator != null ) {
          p.illustrator = illustrator;
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
              ? SubExtensionCards.build((row[1] as Blob).toBytes().toList(), codeNaming, pokemonCards)
              : SubExtensionCards.emptyDraw(codeNaming);
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
    printOutput("Compute Admin reverse database");
    rIllustrators    = illustrators.map((k, v)    => MapEntry(v, k));
    rRegions         = regions.map((k, v)         => MapEntry(v, k));
    rPokemonCards    = pokemonCards.map((k, v)    => MapEntry(v, k));
    rFormes          = formes.map((k, v)          => MapEntry(v, k));
    rPokemon         = pokemons.map((k, v)        => MapEntry(v, k));
    rOther           = otherNames.map((k, v)      => MapEntry(v, k));
    rCardsExtensions = cardsExtensions.map((k, v) => MapEntry(v, k));
  }

  Future<bool> saveDatabase(PokemonCardData card, int nextId, connection) async {
    // Search if card Id
    int? idCard = rPokemonCards[card];

    List<int> nameBytes = [];
    card.title.forEach((element) {
      nameBytes += element.toBytes(this);
    });

    int? idIllustrator = card.illustrator != null ? rIllustrators[card.illustrator] : null;

    List<int> typesByte = [card.type.index];
    if( card.typeExtended != null) {
      typesByte.add(card.typeExtended!.index);
    }
    var namedData = nameBytes.isNotEmpty ? Int8List.fromList(nameBytes) : null;
    var resistance;
    if( card.resistance != null && card.resistance!.energy != Type.Unknown) {
      resistance = Int8List.fromList(card.resistance!.toBytes());
    }
    var retreat = Int8List.fromList([card.retreat]);

    var weakness;
    if( card.weakness != null && card.weakness!.energy != Type.Unknown) {
      weakness = Int8List.fromList(card.weakness!.toBytes());
    }
    var effects;
    card.cardEffects.removeUseless();
    if( card.cardEffects.effects.isNotEmpty ) {
      effects = Int8List.fromList(card.cardEffects.toBytes());
    }

    List data = [namedData, card.level.index, Int8List.fromList(typesByte), card.life, Int8List.fromList(card.markers.toBytes()), effects, retreat, weakness, resistance, idIllustrator];
    var query = "";
    if (idCard == null) {
      data.insert(0, nextId);
      query = 'INSERT INTO `Cartes` VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);';

      // Update internal database
      pokemonCards[nextId] = card;
      rPokemonCards[card] = nextId;
    } else {
      query = 'UPDATE `Cartes` SET `noms` = ?, `niveau` = ?, `type` = ?, `vie` = ?, `marqueur` = ?, `effets` = ?, `retrait` = ?, `faiblesse` = ?, `resistance` = ?, `idIllustrateur` = ?'
          ' WHERE `Cartes`.`idCartes` = $idCard';
    }

    await connection.queryMulti(query, [data]);
    return idCard == null;
  }

  Future<void> saveDatabaseSEC(SubExtensionCards seCards, connection) async {
    // Compute next Id of card
    int nextId = 0;
    var nextIdReq = await connection.query("SELECT MAX(`idCartes`) as maxId FROM `Cartes`;");
    for(var row in nextIdReq) {
      nextId = row[0];
    }
    nextId += 1;
    printOutput("Next id of card is $nextId");

    // Update or create all cards
    printOutput("Start update card data.");
    int updated = 0;
    int created = 0;
    for(var cardLists in seCards.cards) {
      for(var card in cardLists) {
        // Save and update + maintain admin DB
        if( await saveDatabase(card.data, nextId, connection) ) {
          created += 1;
          nextId  += 1;
          printOutput("New card is add. Next id will be $nextId");
        } else {
          updated +=1;
        }
      }
    }
    printOutput("Done update card data: created: $created | updated: $updated.");

    // Just change card info
    int idSEC = rCardsExtensions[seCards];
    var query = 'UPDATE `CartesExtension` SET `cartes` = ?'
        ' WHERE `CartesExtension`.`idCartesExtension` = $idSEC';
    await connection.queryMulti(query, [[Int8List.fromList(seCards.toBytes(rPokemonCards))]]);
  }

  List<CardIntoSubExtensions> searchCardIntoSubExtension(PokemonCardData searchCard) {
    List<CardIntoSubExtensions> result = [];
    var alreadyFind = Set();

    subExtensions.values.forEach((subExtension) {
      if( !alreadyFind.contains(subExtension.seCards) ) {
        int id=0;
        subExtension.seCards.cards.forEach((cards) {
          cards.forEach((card) {
            if(card.data == searchCard) {
              alreadyFind.add(subExtension.seCards);
              result.add(CardIntoSubExtensions(subExtension, id));
            }
          });
          id += 1;
        });
      }
    });
    return result;
  }

  List<List<int>> searchOrphanCard() {
    List<List<int>> toRemove = [];
    for( var cardID in pokemonCards.keys ) {
      bool find = false;
      var cardInfo = pokemonCards[cardID];
      // Parse all subExtension
      for(SubExtension se in subExtensions.values) {
        // for each card
        for(var seCard in se.seCards.cards) {
          // and possible alternative
          for(var seCardSub in seCard) {
            // search object
            if(seCardSub.data == cardInfo) {
              find = true;
              break;
            }
          }
          // Quit quickly
          if(find) {
            break;
          }
        }
        // Quit quickly
        if(find) {
          break;
        }
      }
      // Orphan ?
      if(!find) {
        toRemove.add([cardID]);
      }
    }
    return toRemove;
  }

  Future<void> removeListCards(List<List<int>> cardId, connection) async {
    var query = 'DELETE FROM `StatitikPokemonDebug`.`Cartes` WHERE (`idCartes` = ?)';
    await connection.queryMulti(query, cardId);
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
        var query = 'UPDATE `CartesExtension` SET `cartes` = ?'
            ' WHERE `CartesExtension`.`idCartesExtension` = ${row[0]}';
        await connection.query(query, [Int8List.fromList(extensions.toBytes(rPokemonCards))]);

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

  Future<void> convertETCToV3() async
  {
    printOutput("Start Migration: ");
    // Migration boosterDraw
    await Environment.instance.db.transactionR((connection) async {
      // Get all data
      var boosterDraw = await connection.query("SELECT * FROM `TirageBooster`;");

      // Convert
      List<List<Object?>> data = [];
      for(var row in boosterDraw) {
        var drawData = (row[4] as Blob).toBytes().toList();

        // Check version
        ExtensionDrawCards edc;
        if(drawData[0] == ExtensionDrawCards.version ) {
          edc = ExtensionDrawCards.fromBytes(drawData);
        } else
          edc = ExtensionDrawCards.fromByteV2(drawData);

        List<Object?> obj = [row[0], row[1], row[2], row[3], Int8List.fromList(edc.toBytes())];
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

  Future<void> convertCarteExtToV3() async {
    adminReverse();

    printOutput("Start Migration: ");
    // Migration boosterDraw
    await Environment.instance.db.transactionR((connection) async {
      // Get all data
      var secReq = await connection.query("SELECT * FROM `CartesExtension`;");

      // Convert
      List<List<Object?>> data = [];
      for(var row in secReq) {
        if(row[1] != null) {
          var drawData = (row[1] as Blob).toBytes().toList();
          // Check version
          SubExtensionCards sec;
          if (drawData[0] == SubExtensionCards.version) {
            sec = SubExtensionCards.build(drawData, [], pokemonCards);
          } else
            sec = SubExtensionCards.fromV2(drawData, [], pokemonCards);

          List<Object?> obj = [Int8List.fromList(sec.toBytes(rPokemonCards))];
          var query = 'UPDATE `CartesExtension` SET `cartes` = ?'
              ' WHERE `CartesExtension`.`idCartesExtension` = ${row[0]}';
          await connection.query(query, obj);
        }
      }
    });

    migration = true;
    printOutput("Migration effectuée !");
  }
  */
}