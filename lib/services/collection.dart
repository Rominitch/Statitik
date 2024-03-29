import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/CardIntoSubExtensions.dart';
import 'package:statitikcard/services/models/CardTitleData.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/SubExtensionCards.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/Draw/SessionDraw.dart';
import 'package:statitikcard/services/TimeReport.dart';
import 'package:statitikcard/services/Tools.dart';

class Collection
{
  Map languages       = {};
  Map sets            = {};
  Map extensions      = {};
  Map subExtensions   = {};
  Map cardsExtensions = {};
  Map categories      = {};

  Map pokemons        = {};
  Map otherNames      = {};
  Map regions         = {};
  Map formes          = {};
  Map pokemonCards    = {};
  Map illustrators    = {};
  Map descriptions    = {};
  Map effects         = {};
  Map rarities        = {};
  Map markers         = {};
  Map products        = {};
  Map productSides   = {};

  // Rarity Information
  static const int idUnknownRarity = 28;
  static const int idEmptyRarity   = 29;
  static const int RarityMaskWorldCard        = 1;
  static const int RarityMaskAsianCard        = 2;
  static const int RarityMaskOtherReverseCard = 4;
  static const int RarityMaskGoodCard         = 8;
  static const int RarityMaskRotateIcon       = 16;
  Rarity? unknownRarity;
  List<Rarity> orderedRarity    = [];
  List<Rarity> worldRarity      = [];
  List<Rarity> japanRarity      = [];
  List<Rarity> goodCard         = [];
  List<Rarity> otherThanReverse = [];
  Map<Language, Map<Rarity, List<Widget>?>> cachedImageRarity = {};

  // Markers
  Map<CardMarker, Widget?> cachedMarkers = {};
  List<CardMarker>         longMarkers   = [];

  // Admin part
  Map rIllustrators    = {};
  Map rRegions         = {};
  Map rPokemonCards    = {};
  Map rFormes          = {};
  Map rPokemon         = {};
  Map rOther           = {};
  Map rCardsExtensions = {};
  Map rSets            = {};
  Map rRarities        = {};
  Map rMarkers         = {};

  void clear() {
    languages.clear();
    sets.clear();
    extensions.clear();
    subExtensions.clear();
    cardsExtensions.clear();
    pokemons.clear();
    regions.clear();
    formes.clear();
    illustrators.clear();
    pokemonCards.clear();
    rarities.clear();
    markers.clear();
    products.clear();
    productSides.clear();
    effects.clear();
    otherNames.clear();
    descriptions.clear();
    categories.clear();

    unknownRarity = null;
    orderedRarity.clear();
    worldRarity.clear();
    japanRarity.clear();
    goodCard.clear();
    otherThanReverse.clear();
    cachedImageRarity.clear();

    cachedMarkers.clear();
    longMarkers.clear();

    rIllustrators.clear();
    rRegions.clear();
    rPokemonCards.clear();
    rFormes.clear();
    rPokemon.clear();
    rOther.clear();
    rCardsExtensions.clear();
    rSets.clear();
    rRarities.clear();
    rMarkers.clear();
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

  // Temporary: need to understand tree shake
  IconData getIcon(int id) {
    switch(id) {
      case 0xe163: return Icons.circle;
      case 0xe606: return Icons.stop;
      case 0xe5f9: return Icons.star;
      case 0xe5fa: return Icons.star_outline;
      case 0xe3b4: return Icons.looks;
    }
    return Icons.help_outline;
  }

  Future<void> readStaticData(connection) async
  {
      var time = TimeReport();

      var languagesReq = await connection.query("SELECT * FROM `Langue`");
      for (var row in languagesReq) {
        languages[row[0]] = Language(id: row[0], image: row[1]);
      }
      time.tick("Langue");
      assert(languages.isNotEmpty);

      var setResult = await connection.query("SELECT * FROM `Set`");
      for (var row in setResult) {
        try {
          var isStandard = row[0] < 2;
          sets[row[0]] = CardSet(MultiLanguageString([row[1] ?? "", row[2] ?? "", row[3] ?? ""]), Color(row[4]), row[5], isStandard);
        } catch(e) {
          printOutput("Bad Set: ${row[0]} $e");
        }
      }
      time.tick("Sets");
      assert(sets.isNotEmpty);

      var rarityResult = await connection.query("SELECT * FROM `Rarete` ORDER BY `order` ASC");
      for (var row in rarityResult) {
        try {
          var name;
          if(row[2] != null) {
            var allName = (row[2] as String).split(";");
            if(allName.length == 3){
              name = MultiLanguageString(allName);
            } else {
              name = MultiLanguageString([allName[0], allName[0], allName[0]]);
            }
          }

          // Build
          var rarity;
          if(row[1] != null) {
            rarity = Rarity.fromIcon(row[0], getIcon(row[1]), name, Color(row[6]), rotate: mask(row[4], RarityMaskRotateIcon));
          }
          else if(row[2] != null)
            rarity = Rarity.fromText(row[0], name, Color(row[6]));
          else if(row[3] != null)
            rarity = Rarity.fromImage(row[0], row[3], Color(row[6]));
          assert(rarity != null);

          // register into list
          if(mask(row[4],RarityMaskAsianCard))
            japanRarity.add(rarity);
          if(mask(row[4],RarityMaskWorldCard))
            worldRarity.add(rarity);

          // Order
          orderedRarity.add(rarity);
          // Good card
          if(mask(row[4], RarityMaskGoodCard))
            goodCard.add(rarity);
          // Other than  reverse
          if(mask(row[4], RarityMaskOtherReverseCard))
            otherThanReverse.add(rarity);

          // Save
          rarities[row[0]] = rarity;
        } catch(e) {
          printOutput("Bad Rarity: ${row[0]} $e");
        }
      }
      time.tick("Rarities");
      assert(rarities.isNotEmpty);
      unknownRarity = rarities[idUnknownRarity];

      var markersResult = await connection.query("SELECT * FROM `Markers`");
      for (var row in markersResult) {
        try {
          var mark = CardMarker(MultiLanguageString([row[1], row[2], row[3]]), Color(row[4]), mask(row[5], 1));
          markers[row[0]] = mark;

          // long markers
          if( mask(row[5], 2) )
            longMarkers.add(mark);
        } catch(e) {
          printOutput("Bad Marker: ${row[0]} $e");
        }
      }
      time.tick("Markers");
      assert(markers.isNotEmpty);
      assert(markers.length <= 40); // Game over : need to change data !!

      var exts = await connection.query("SELECT * FROM `Extension` ORDER BY `code` DESC");
      for (var row in exts) {
        try {
          extensions[row[0]] = Extension(row[0], row[2], languages[row[1]]);
        } catch(e) {
          printOutput("Bad Extension: ${row[0]} $e");
        }
      }
      time.tick("Extensions");
      assert(extensions.isNotEmpty);

      int idPoke=1;
      var pokes = await connection.query("SELECT * FROM `Pokemon`");
      for (var row in pokes) {
        try {
          pokemons[row[0]] = PokemonInfo(MultiLanguageString([row[2], row[3], row[4]]), row[1], idPoke);
          idPoke += 1;
        } catch(e) {
          printOutput("Bad pokemon: ${row[0]} $e");
        }
      }
      time.tick("Pokemon");
      assert(pokemons.isNotEmpty);

      var objSup = await connection.query("SELECT * FROM `DresseurObjet`");
      for (var row in objSup) {
        try {
          otherNames[row[0]] = CardTitleData(MultiLanguageString([row[1], row[2], row[3]]));
        } catch(e) {
          printOutput("Bad Object: ${row[0]} $e");
        }
      }
      time.tick("OtherNames");
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
      time.tick("Regions");
      assert(regions.isNotEmpty);

      var formeRes = await connection.query("SELECT * FROM `Forme`");
      for (var row in formeRes) {
        try {
          formes[row[0]] = Forme(MultiLanguageString([row[1], row[2], row[3]]));
        } catch(e) {
          printOutput("Bad Forme: ${row[0]} $e");
        }
      }
      time.tick("Formes");
      assert(formes.isNotEmpty);

      var illustratorRes = await connection.query("SELECT * FROM `Illustrateur`");
      for (var row in illustratorRes) {
        try {
          illustrators[row[0]] = Illustrator(row[1]);
        } catch(e) {
          printOutput("Bad Illustrateur: ${row[0]} $e");
        }
      }
      time.tick("Illustrators");
      assert(illustrators.isNotEmpty);

      var descriptionsRes = await connection.query("SELECT * FROM `Description`");
      for (var row in descriptionsRes) {
        try {
          descriptions[row[0]] = DescriptionData.fromDb(MultiLanguageString([row[2], row[3], row[4]]), row[1] ?? 0);
        } catch(e) {
          printOutput("Bad Description: ${row[0]} $e");
        }
      }
      time.tick("Descriptions");
      assert(descriptions.isNotEmpty);

      var effectRes = await connection.query("SELECT * FROM `EffetsCarte`");
      for (var row in effectRes) {
        try {
          effects[row[0]] = MultiLanguageString([row[1], row[2], row[3]]);
        } catch(e) {
          printOutput("Bad Description: ${row[0]} $e");
        }
      }
      time.tick("Effects");
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
        var type       = TypeCard.values[typeBytes[0]];
        var life       = row[4] ?? 0;
        // Extract markers
        CardMarkers cardMarkers;
        if( row[5] != null) {
          cardMarkers = CardMarkers.fromBytes((row[5] as Blob).toBytes().toList(), markers);
        } else {
          cardMarkers = CardMarkers();
        }
        var effects      = row[6] != null ? CardEffects.fromBytes((row[6] as Blob).toBytes().toList()) : null;
        var retreat      = row[7] != null ? (row[7] as Blob).toBytes().toList()[0] : 0;
        var weakness     = row[8] != null ? EnergyValue.fromBytes((row[8] as Blob).toBytes().toList()) : null;
        var resistance   = row[9] != null ? EnergyValue.fromBytes((row[9] as Blob).toBytes().toList()) : null;
        var illustrator  = row[10] != null ? illustrators[row[10]]: null;

        //Build card
        PokemonCardData p = PokemonCardData(namePokemons, level, type, cardMarkers, life, retreat, resistance, weakness);
        //Extract typeExtended (for double energy card)
        if(typeBytes.length > 1) {
          p.typeExtended = TypeCard.values[typeBytes[1]];
        }
        //Extract effects
        if( effects != null ) {
          effects.effects.forEach((element) {
            if( element.description != null ) {
              element.description!.computeDescriptionEffects(descriptions, languages[1]);
            }
          });
          p.cardEffects = effects;
        }
        //Extract illustrator
        if( illustrator != null ) {
          p.illustrator = illustrator;
        }
        pokemonCards[row[0]] = p;
      }

      if(!Environment.instance.onInfoLoading.isClosed)
        Environment.instance.onInfoLoading.add('LOAD_3');
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

          var energyList   = row[3] != null ? (row[3] as Blob).toBytes().toList() : null;
          var noNumberList = row[4] != null ? (row[4] as Blob).toBytes().toList() : null;

          cardsExtensions[row[0]] = (row[1] != null)
              ? SubExtensionCards.build((row[1] as Blob).toBytes().toList(), codeNaming, pokemonCards, sets, rarities, row[5], energyList, noNumberList)
              : SubExtensionCards.emptyDraw(codeNaming, row[5], sets);
        } catch(e, callStack) {
          var msg = e is StatitikException ? e.msg : e.toString();
          printOutput("Bad SubExtensionCards: ${row[0]} - $msg\n$callStack");
          cardsExtensions[row[0]] = SubExtensionCards.emptyDraw([], 0, sets);
        }
      }
      time.tick("CardsExtensions");
      assert(cardsExtensions.isNotEmpty);

      var subExts = await connection.query("SELECT * FROM `SousExtension` ORDER BY `code` DESC");
      for (var row in subExts) {
        try {
          SubExtensionCards seCards = cardsExtensions[row[4]];
          subExtensions[row[0]] = SubExtension(row[0], row[2], row[3], extensions[row[1]], row[6], seCards, SerieType.values[row[7]], row[8].split(";"), row[9]);
        } catch(e) {
          printOutput("Bad SubExtension: ${row[0]} $e");
        }
      }
      time.tick("SubExtensions");
      assert(subExtensions.isNotEmpty);

      var catExts = await connection.query("SELECT * FROM `Categorie`;");
      for (var row in catExts) {
        categories[row[0]] = ProductCategory(row[0], MultiLanguageString([row[1], row[2], row[3]]), mask(row[4], 1));
      }
      time.tick("Categories");
      assert(categories.isNotEmpty);

      if(!Environment.instance.onInfoLoading.isClosed)
        Environment.instance.onInfoLoading.add('LOAD_4');
      
      // Read static other product
      var otherProductsRequest = await connection.query("SELECT * FROM `ProduitAnnexe`");
      for (var row in otherProductsRequest) {
        productSides[row[0]] = ProductSide(row[0], categories[row[3]], row[1], row[2], row[4]);
      }
      time.tick("ProductSides");
      assert(productSides.isNotEmpty);

      // Read static product
      var productRequest = await connection.query("SELECT * FROM `Produit`");
      for (var row in productRequest) {
        try {
          assert(row[6] != null);

          // Start session
          products[row[0]] = Product.fromBytes(row[0], languages[row[1]], row[2], row[3], row[4], categories[row[5]],
              (row[6] as Blob).toBytes(), subExtensions, productSides);
        } catch(e) {
          printOutput("Bad Product: ${row[0]} $e");
        }
      }
      time.tick("Products");
      assert(products.isNotEmpty);
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
    rSets            = sets.map((k, v)            => MapEntry(v, k));
    rRarities        = rarities.map((k, v)        => MapEntry(v, k));
    rMarkers         = markers.map((k, v)         => MapEntry(v, k));
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
    if( card.resistance != null && card.resistance!.energy != TypeCard.Unknown) {
      resistance = Int8List.fromList(card.resistance!.toBytes());
    }
    var retreat = Int8List.fromList([card.retreat]);

    var weakness;
    if( card.weakness != null && card.weakness!.energy != TypeCard.Unknown) {
      weakness = Int8List.fromList(card.weakness!.toBytes());
    }
    var effects;
    card.cardEffects.removeUseless();
    if( card.cardEffects.effects.isNotEmpty ) {
      effects = Int8List.fromList(card.cardEffects.toBytes());
    }

    List data = [namedData, card.level.index, Int8List.fromList(typesByte), card.life,
      Int8List.fromList(card.markers.toBytes(rMarkers)),
      effects, retreat, weakness, resistance, idIllustrator,
    ];

    var query = "";
    if (idCard == null) {
      data.insert(0, nextId);
      query = 'INSERT INTO `Cartes` VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);';

      //printOutput("New card added at $nextId and we update internal list");
    } else {
      query = 'UPDATE `Cartes` SET `noms` = ?, `niveau` = ?, `type` = ?, `vie` = ?, `marqueur` = ?, `effets` = ?, `retrait` = ?, `faiblesse` = ?, `resistance` = ?, `idIllustrateur` = ?'
              ' WHERE `Cartes`.`idCartes` = $idCard';

      //printOutput("Update card at $idCard and we update internal list");
    }

    try {
      await connection.queryMulti(query, [data]);

      if(idCard == null) {
        // Update internal database
        pokemonCards[nextId] = card;
        rPokemonCards[card] = nextId;
      }
    } catch(e) {
      printOutput("Request error: "+e.toString());
      throw e;
    }
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
    for(var cardLists in [seCards.energyCard, seCards.noNumberedCard]) {
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
    var query = 'UPDATE `CartesExtension` SET `cartes` = ?, `energies` = ?, `cartesSansNumero` = ?'
        ' WHERE `CartesExtension`.`idCartesExtension` = $idSEC';
    await connection.queryMulti(query, [
      [
        Int8List.fromList(seCards.toBytes(rPokemonCards, rSets, rRarities)),
        seCards.energyCard.isEmpty     ? null : Int8List.fromList(seCards.otherToBytes(seCards.energyCard,     rPokemonCards, rSets, rRarities)),
        seCards.noNumberedCard.isEmpty ? null : Int8List.fromList(seCards.otherToBytes(seCards.noNumberedCard, rPokemonCards, rSets, rRarities))
      ]]);
  }

  List<CardIntoSubExtensions> searchCardIntoAllSubExtension(PokemonCardData searchCard) {
    List<CardIntoSubExtensions> result = [];
    subExtensions.values.forEach((subExtension) {
      int id=0;
      subExtension.seCards.cards.forEach((cards) {
        int subId=0;
        cards.forEach((card) {
          if(card.data == searchCard) {
            result.add(CardIntoSubExtensions.withAll(subExtension, CardIdentifier.from([0, id, subId]), card));
          }
          subId += 1;
        });
        id += 1;
      });

      id=0;
      subExtension.seCards.energyCard.forEach((card) {
        if(card.data == searchCard) {
          result.add(CardIntoSubExtensions.withAll(subExtension, CardIdentifier.from([1, id]), card));
        }
        id += 1;
      });

      id=0;
      subExtension.seCards.noNumberedCard.forEach((card) {
        if(card.data == searchCard) {
          result.add(CardIntoSubExtensions.withAll(subExtension, CardIdentifier.from([2, id]), card));
        }
        id += 1;
      });
    });
    return result;
  }

  List<CardIntoSubExtensions> searchCardIntoSubExtension(PokemonCardData searchCard, [bool supportedDuplicateSeCard=false]) {
    List<CardIntoSubExtensions> result = [];
    var alreadyFind = Set();

    subExtensions.values.forEach((subExtension) {
      if( supportedDuplicateSeCard || !alreadyFind.contains(subExtension.seCards) ) {
        int id=0;
        subExtension.seCards.cards.forEach((cards) {
          int subId=0;
          cards.forEach((card) {
            if(card.data == searchCard) {
              alreadyFind.add(subExtension.seCards);
              result.add(CardIntoSubExtensions.withAll(subExtension, CardIdentifier.from([0, id, subId]), card));
            }
            subId += 1;
          });
          id += 1;
        });

        id=0;
        subExtension.seCards.energyCard.forEach((card) {
          if(card.data == searchCard) {
            result.add(CardIntoSubExtensions.withAll(subExtension, CardIdentifier.from([1, id]), card));
          }
          id += 1;
        });

        id=0;
        subExtension.seCards.noNumberedCard.forEach((card) {
          if(card.data == searchCard) {
            result.add(CardIntoSubExtensions.withAll(subExtension, CardIdentifier.from([2, id]), card));
          }
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

        // Main card
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

        // Energies
        for(var eCard in se.seCards.energyCard) {
          if(eCard.data == cardInfo) {
            find = true;
            break;
          }
        }

        // Other card
        for(var eCard in se.seCards.noNumberedCard) {
          if(eCard.data == cardInfo) {
            find = true;
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
    var query = 'DELETE FROM `Cartes` WHERE (`idCartes` = ?)';
    await connection.queryMulti(query, cardId);
  }

  Future<void> removeUserProduct(SessionDraw session, connection) async {
    if(session.idAchat != -1) {
      var query = 'DELETE FROM `TirageBooster` WHERE (`idAchat` = ?)';
      await connection.queryMulti(query, [[session.idAchat]]);
      query = 'DELETE FROM `UtilisateurProduit` WHERE (`idAchat` = ?)';
      await connection.queryMulti(query, [[session.idAchat]]);
    }
  }

  Future<int> addNewDresseurObjectName(String newText, int idLangue, connection) async {
    // Compute next Id of name
    int nextId = 0;
    {
      var nextIdReq = await connection.query(
          "SELECT MAX(`idDresseurObjet`) as maxId FROM `DresseurObjet`;");
      for (var row in nextIdReq) {
        nextId = row[0];
      }
      nextId += 1;
      printOutput("Next id of card is $nextId");
    }
    // Prepare data
    List<String> names = [ "", "", ""];
    names[idLangue-1] = newText;

    List<Object> values = <Object>[nextId] + names;
    assert( 1 <= idLangue && idLangue <= 3);

    // Run request
    var query = 'INSERT INTO `DresseurObjet` (`idDresseurObjet`, `frNom`, `enNom`, `jpNom`) VALUES (?, ?, ?, ?);';
    await connection.queryMulti(query, [values]);

    // Add internally without reset all static (avoid side supposed effect)
    var newName = CardTitleData(MultiLanguageString(names));
    otherNames[nextId] = newName;
    rOther[newName] = nextId;

    return nextId;
  }

  Future<void> migration(connection) async {
    //printOutput('Migration Start');

    //Insert HERE all requests

    //printOutput('Migration Done !');
  }
}