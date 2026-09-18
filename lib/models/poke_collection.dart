
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/models/database/poke_db_description.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/card/poke_card.dart';
import 'package:statitikcard/models/card/poke_card_effect.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_expansion_cards.dart';
import 'package:statitikcard/models/poke_form.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_illustrator.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_marker.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_region.dart';
import 'package:statitikcard/models/poke_serie.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/models/products/poke_product.dart';
import 'package:statitikcard/models/products/poke_product_booster.dart';
import 'package:statitikcard/models/products/poke_product_category.dart';
import 'package:statitikcard/models/products/poke_product_side.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/time_report.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

import 'database/poke_db_cards_blob.dart';



class PokeCollection {
  static const double _version = 1.1;
  Map<Language, PokeLanguage> _languages = {};
  List<PokeSerie>     _series     = [];
  List<PokemonName>   _pokemons   = [];
  List<OtherCardName> _otherCards = [];
  List<PokeRegion>    _regions    = [];
  List<PokeSet>       _sets       = [];
  List<PokeDesign>    _designs    = [];
  List<PokeMarker>    _markers    = [];
  List<PokeForm>      _forms      = [];
  List<PokeIllustrator> _illustrators      = [];
  List<PokeEffectName> _effectNames = [];

  Map<PokeIdentifier, PokeDbDescription> _descriptions = {};
  List<PokeRarity>    _rarities   = [];
  PokeRarity?         _unknownRarity;
  List<PokeRarity>    _worldRarity      = [];
  List<PokeRarity>    _japanRarity      = [];
  List<PokeRarity>    _goodCard         = [];
  List<PokeRarity>    _otherThanReverse = [];

  // Finally database (need others lists)
  List<PokeCard>      _cards      = [];
  List<PokeExpansion> _expansions = [];

  List<PokeProductCategory> _product_categories = [];
  List<PokeProductBooster>  _product_boosters   = [];
  List<PokeProductSide>     _product_sides      = [];
  List<PokeProduct>         _products           = [];

  // Tools
  Map<String, String> convertKanji   = {};
  List<String>        orderedKanji   = [];

  // Computed helper
  Map<CardLocation, List<PokeLanguage>> _locationBylanguages = {};

  /// TEMPORARY ACCESS----------------------------
  List<PokeMarker> markers() { return _markers; }

  CardTitle? cardTitleOld(int oldId) {
    int newId = oldId;
    if( oldId >= 10000 ) {
      for(final obj in _otherCards) {
        final localId = obj.pid();
        if(localId.type() == PokeIdentifierType.object) {
          if( localId.number() == oldId-10000 ) {
            return obj;
          }
        }
      }
      throw Exception("Bad id: $oldId");
    } else {
      newId += 300000000;
      //Add generation
      if(oldId < 152)      { newId += 1000000;}
      else if(oldId < 252) { newId += 2000000;}
      else if(oldId < 387) { newId += 3000000;}
      else if(oldId < 494) { newId += 4000000;}
      else if(oldId < 650) { newId += 5000000;}
      else if(oldId < 722) { newId += 6000000;}
      else if(oldId < 810) { newId += 7000000;}
      else if(oldId < 906) { newId += 8000000;}
      else                 { newId += 9000000;}
    }
    try {
      return cardTitle(PokeIdentifier(newId));
    } catch(e) {
      throw e;
    }
  }

  PokeRegion? regionOld(int oldId){
    if(oldId > 0) {
      return region(PokeIdentifier(oldId + 910000000));
    }
    return null;
  }

  PokeForm? formOld(int oldId){
    if(oldId > 0) {
      try {
        if( oldId == 23) { return null; }
        if( oldId > 23) { oldId = oldId - 1;}
        return form(PokeIdentifier(oldId + 520000000));
      } catch(e) {
        rethrow;
      }
    }
    return null;
  }

  PokeDesign?  designOld(int idDesign, int pattern){
    return design(PokeIdentifier(idDesign + pattern * 10000 + 510000000));
  }

  PokeSet?  setsOld(int id){
    return sets(PokeIdentifier(id + 530000000));
  }

  PokeProductBooster? tmpBoosterFromExp(PokeExpansion? pokeExpansion) {
    if(pokeExpansion == null) {
      return null;
    }
    for(final booster in _product_boosters) {
      if(booster.expansion() == pokeExpansion) {
        return booster;
      }
    }
    return null;
  }
  //List<PokeCard>      cardsOld()      { return _cardsOld; }

  /// TEMPORARY ACCESS----------------------------

  List<PokemonName>   pokemons()          { return _pokemons; }
  List<OtherCardName> otherCards()        { return _otherCards; }
  List<PokeRegion>    regions()           { return _regions; }
  List<PokeForm>      forms()             { return _forms; }
  List<PokeLanguage>  languages()         { return _languages.values.toList(growable: false); }
  PokeRarity          unknownRarity()     { return _unknownRarity!; }
  List<PokeRarity>    worldRarity()       { return _worldRarity; }
  List<PokeRarity>    japanRarity()       { return _japanRarity; }
  List<PokeRarity>    goodCard()          { return _goodCard; }
  List<PokeRarity>    otherThanReverse()  { return _otherThanReverse; }
  List<PokeEffectName> effectNames()      { return _effectNames; }
  List<PokeDesign>     designs()          { return _designs; }
  Map<PokeIdentifier, PokeDbDescription> descriptions() { return _descriptions;}


  List<PokeCard>      cards()      { return _cards; }
  List<PokeExpansion> expansions() { return _expansions;}

  List<PokeProduct>     products()     { return _products;}
  List<PokeProductSide> sideProducts() { return _product_sides;}
  List<PokeProductBooster> boosters()  { return _product_boosters; }
  List<PokeProductCategory> productCategories() { return _product_categories; }
  List<PokeProductSide>     productSides() { return _product_sides; }

  PokeLanguage language(Language id) { return _languages[id]!; }
  List<PokeSerie> series() { return _series; }
  PokeSet?        sets(PokeIdentifier pid) {
    return _sets.firstWhere((element) => element.isEqual(pid) );
  }

  List<PokeLanguage> languagesBy(CardLocation location) {
    return _locationBylanguages[location]!;
  }

  PokemonName pokemon(PokeIdentifier pid) {
    return _pokemons.firstWhere((element) => element.isEqual(pid));
  }

  List<PokeSet>  allSets() { return _sets; }

  PokeRarity?    rarity(int id) {
    return _rarities.firstWhere((element) => element.isEqual(id));
  }

  PokeCard?      card(PokeIdentifier pid) {
    return _cards.firstWhere((element) => element.isEqual(pid));
  }

  bool containsCard(PokeCard card) {
    return _cards.where((element) => element.isEqual(card.pid())).isNotEmpty;
  }

  PokeDesign? design(PokeIdentifier pid){
    return _designs.firstWhere((element) => element.isEqual(pid));
  }

  CardTitle? cardTitle(PokeIdentifier pid) {
    if(pid.type() == PokeIdentifierType.pokemon) {
      return _pokemons.firstWhere((element) => element.isEqual(pid));
    } else {
      return _otherCards.firstWhere((element) => element.isEqual(pid));
    }
  }

  PokeMarker? marker(PokeIdentifier pid) {
    return _markers.firstWhere((element) => element.isEqual(pid));
  }

  PokeRegion? region(PokeIdentifier pid) {
    return _regions.firstWhere((element) => element.isEqual(pid));
  }

  PokeForm? form(PokeIdentifier pid) {
    return _forms.firstWhere((element) => element.isEqual(pid));
  }

  PokeIllustrator? illustrator(PokeIdentifier pid) {
    return _illustrators.firstWhere((element) => element.isEqual(pid));
  }

  PokeDbDescription? description(PokeIdentifier pid) {
   return _descriptions[pid];
  }

  PokeEffectName? effectName(PokeIdentifier pid) {
    return _effectNames.firstWhere((element) => element.isEqual(pid));
  }

  PokeProductCategory? productCategory(PokeIdentifier id) {
    return _product_categories.firstWhere((element) => element.isEqual(id));
  }

  PokeProductSide? productSide(PokeIdentifier id) {
    return _product_sides.firstWhere((element) => element.isEqual(id));
  }

  PokeExpansion? expansion(PokeIdentifier pid) {
    return _expansions.firstWhere((element) => element.isEqual(pid) );
  }

  PokeProductBooster? booster(PokeIdentifier pid) {
    try {
      return _product_boosters.firstWhere((element) => element.isEqual(pid));
    } catch(_,_){
      printOutput("Unknown PID: ${pid.id()}");
      rethrow;
    }
  }

  void add(PokeProductBooster booster) {
    _product_boosters.add(booster);
  }

  PokeCollection();

  PokeCollection.fromBytes(BinaryReader reader) {
    if(reader.readFloat32() == 1.0) {
      _languages = reader.readMap(
        (r) => Language.values[r.readInt8()],
        (r, key) => PokeLanguage.fromBytes(key, r)
      );
      _series = reader.readList(
        (r) => PokeSerie.fromBytes(r)
      );
      _pokemons = reader.readList(
        (r) => PokemonName.fromBytes(r)
      );
      _otherCards = reader.readList(
        (r) => OtherCardName.fromBytes(r)
      );
      _regions = reader.readList(
        (r) => PokeRegion.fromBytes(r)
      );
      _forms = reader.readList(
        (r) => PokeForm.fromBytes(r)
      );
      _sets = reader.readList(
        (r) => PokeSet.fromBytes(r)
      );
      _designs = reader.readList(
        (r) => PokeDesign.fromBytes(r)
      );
      _markers = reader.readList(
        (r) => PokeMarker.fromBytes(r)
      );
      _effectNames = reader.readList(
        (r) => PokeEffectName.fromBytes(r)
      );
      _descriptions = reader.readMap(
        (r) => PokeIdentifier.fromBytes(r),
        (r, k) => PokeDbDescription.fromBytes(r)
      );
      _rarities = reader.readList(
        (r) => PokeRarity.fromBytes(r)
      );

      _cards = reader.readList(
        (r) => PokeCard.fromBytes(PokeIdentifier.fromBytes(r), r, this)
      );
      _expansions = reader.readList(
        (r) => PokeExpansion.fromBytes(r, this)
      );

      // Link
      _linkItems();
    }
  }

  void toBytes(BinaryWriter w) {
    var time = TimeReport();
    w.writeFloat32(_version);
    w.writeMap<Language, PokeLanguage>(_languages,
      (w, key)   => w.writeInt8(key.index),
      (w, value) => value.toBytes(w)
    );
    time.tick("Languages");
    w.writeList<PokeSerie>(_series,
      (w, value) => value.toBytes(w)
    );
    time.tick("Series");
    w.writeList<PokemonName>(_pokemons,
      (w, value) => value.toBytesID(w)
    );
    time.tick("Pokemons");
    w.writeList<OtherCardName>(_otherCards,
      (w, value) => value.toBytesID(w)
    );
    time.tick("Tools/Equipement/Stadium");
    w.writeList<PokeRegion>(_regions,
      (w, value) => value.toBytesID(w)
    );
    time.tick("Regions");
    w.writeList<PokeForm>(_forms,
      (w, value) => value.toBytesID(w)
    );
    time.tick("Forms");
    w.writeList<PokeSet>(_sets,
      (w, value) => value.toBytes(w)
    );
    time.tick("Sets");
    w.writeList<PokeDesign>(_designs,
      (w, value) => value.toBytes(w)
    );
    time.tick("Designs");
    w.writeList<PokeMarker>(_markers,
      (w, value) => value.toBytes(w)
    );
    time.tick("Markers");
    
    w.writeList<PokeEffectName>(_effectNames,
      (w, value) => value.toBytesID(w)
    );
    time.tick("Effects");

    w.writeMap<PokeIdentifier, PokeDbDescription>(_descriptions,
      (w, key)   => key.toBytesID(w),
      (w, value) => value.toBytes(w)
    );
    time.tick("Description");
    w.writeList<PokeRarity>(_rarities,
      (w, value) => value.toBytes(w)
    );
    time.tick("Rarity");

    w.writeList<PokeCard>(_cards,
      (w, value) {
        value.pid().toBytesID(w);
        value.toBytes(w);
      }
    );
    time.tick("Cards");

    w.writeList<PokeExpansion>(_expansions,
      (w, value) => value.toBytes(w)
    );
    time.tick("Expansions");
  }

  void clear() {
    _languages.clear();
    _series.clear();
    _pokemons.clear();
    _otherCards.clear();
    _regions.clear();
    _sets.clear();
    _designs.clear();
    _markers.clear();
    _forms.clear();
    _illustrators.clear();
    _effectNames.clear();

    _descriptions     .clear();
    _rarities         .clear();
    _worldRarity      .clear();
    _japanRarity      .clear();
    _goodCard         .clear();
    _otherThanReverse .clear();

    _cards.clear();
    _expansions.clear();

    _product_categories .clear();
    _product_boosters   .clear();
    _product_sides      .clear();
    _products           .clear();

    // Tools
    convertKanji   .clear();
    orderedKanji   .clear();

    // Computed helper
    _locationBylanguages.clear();

    _unknownRarity = null;
  }

  Future<void> readStaticData(TransactionContext connection) async
  {
    var time = TimeReport();

    var langueReq = await connection.query("SELECT * FROM `langue`");

    // Read language String
    for (var row in langueReq) {
      final dbName = PokeLanguage.dbName(row[1]);
      var languageReq = await connection.query("SELECT * FROM `$dbName`");
      Map<PokeIdentifier, String> data = {};
      for (var row in languageReq) {
        data[PokeIdentifier(row[0])] = row[1];
      }
      final langID = Language.from(row[0]);
      _languages[langID] = PokeLanguage.fromDB(row[1], data, CardLocation.from(row[2]), langID);
      time.tick("Languages ${row[1]}");
    }

    updateLanguageData();

    var seriesReq = await connection.query("SELECT * FROM `PK_serie`");
    for (var row in seriesReq) {
      _series.add(PokeSerie.fromDB(PokeIdentifier(row[0])));
    }
    time.tick("Series");

    var pokemonsReq = await connection.query("SELECT * FROM `PK_pokemon`");
    for (var row in pokemonsReq) {
      _pokemons.add(PokemonName.fromDB(PokeIdentifier(row[0])));
    }
    time.tick("Pokemons");

    var othersReq = await connection.query("SELECT * FROM `PK_autres`");
    for (var row in othersReq) {
      _otherCards.add(OtherCardName.fromDB(PokeIdentifier(row[0])));
    }
    time.tick("Tools/Equipement/Stadium");

    var regionsReq = await connection.query("SELECT * FROM `PK_region`");
    for (var row in regionsReq) {
      _regions.add(PokeRegion.fromDB(row[0]));
    }
    time.tick("Regions");

    var formsReq = await connection.query("SELECT * FROM `PK_forme`");
    for (var row in formsReq) {
      _forms.add(PokeForm.fromDB(row[0]));
    }
    time.tick("Forms");

    var setsReq = await connection.query("SELECT * FROM `PK_set`");
    for (var row in setsReq) {
      _sets.add(PokeSet.fromDB(PokeIdentifier(row[0]), Color(row[1]), row[2], row[3]));
    }
    time.tick("Sets");

    var designsReq = await connection.query("SELECT * FROM `PK_design`");
    for (var row in designsReq) {
      _designs.add(PokeDesign.fromDB(PokeIdentifier(row[0]), row[1]));
    }
    time.tick("Designs");

    var markersReq = await connection.query("SELECT * FROM `PK_marker`");
    for (var row in markersReq) {
      _markers.add(PokeMarker.fromDB(PokeIdentifier(row[0]), row[1], Color(row[2]), row[3] != 0));
    }
    time.tick("Markers");

    var effectsNameReq = await connection.query("SELECT * FROM `PK_effects`");
    for (var row in effectsNameReq) {
      _effectNames.add(PokeEffectName.fromDB(row[0]));
    }
    time.tick("Effects name");

    var descriptionReq = await connection.query("SELECT * FROM `PK_description`");
    for (var row in descriptionReq) {
      final id = PokeIdentifier(row[0]);
      _descriptions[id] = PokeDbDescription.fromDB(id, DescriptionEffect.convertMarkers(row[1]));
    }
    time.tick("Descriptions");

    var raritiesReq = await connection.query("SELECT * FROM `PK_rarete` ORDER BY `order` ASC");
    for (var row in raritiesReq) {
      _rarities.add( PokeRarity.fromDB(row[0], PokeRarity.getIcon(row[1]), row[2] ?? "", row[3] ?? "", row[4], Color(row[5]) ));
    }
    time.tick("Rarity");

    var kanjiRes = await connection.query("SELECT * FROM `KanjiConvert`");
    for (var row in kanjiRes) {
      convertKanji[row[0]] = row[1];
    }
    orderedKanji = convertKanji.keys.toList();
    orderedKanji.sort((a, b){
      return a.length.compareTo(b.length);
    });
    time.tick("Kanji");

    /*
    var cardsOldReq = await connection.query("SELECT * FROM `PK_cartesOld`");
     for (var row in cardsOldReq) {
      final title        = row[1] != null ? PokeTitleCard.fromBytesOld(readBlob(row[1]), this) : PokeTitleCard.empty();
      final level        = PokeLevel.values[row[2]];
      final typeReader   = readBlob(row[3]);
      final type         = TypeCard.values[typeReader.readInt8()];
      final typeExtended = typeReader.canParse() ? TypeCard.values[typeReader.readInt8()] : null;
      final markers      = row[4] != null ? PokeMarkers.fromBytesOld((row[4] as Blob).toBytes(), this) : PokeMarkers([]);
      final effects      = row[5] != null ? PokeCardEffects.fromBytesOld(readBlob(row[5]), this) : PokeCardEffects();
      final life         = row[6] ?? 0;
      final retreat      = row[7] != null ? readBlob(row[7]).readInt8() : 0;
      final weakness     = row[8] != null ? PokeEnergyValue.fromBytes(readBlob(row[8])) : null;
      final resistance   = row[9] != null ? PokeEnergyValue.fromBytes(readBlob(row[9])) : null;

      _cardsOld.add(PokeCard.fromDB(PokeIdentifier(row[0]), title, level, type, typeExtended, markers, effects, life, retreat, weakness, resistance));
    }
    time.tick("Cards Old");
    */

    var cardsReq = await connection.query("SELECT * FROM `PK_cartes`");
    for (var row in cardsReq) {
      _cards.add(PokeCard.fromBytes(PokeIdentifier(row[0]), readBlob(row[1]), this));
    }
    time.tick("Cards");

    var expansionsReq = await connection.query("SELECT * FROM `PK_expansion`");
    for (var row in expansionsReq) {
      var cardsReq = await connection.query("SELECT * FROM `PK_cartes_expansion` WHERE id = ${row[0]}");
      if(cardsReq.isEmpty) { throw Exception("Bad item");}

      try {
        final cards = PokeExpansionCards.fromDB(
            PokeDbCardsBlob.convertNaming(cardsReq.first[1]),
            PokeDbCardsBlob.convertCard(cardsReq.first[2], this),
            PokeDbCardsBlob.convertOther(cardsReq.first[3], this),
            PokeDbCardsBlob.convertOther(cardsReq.first[4], this),
            cardsReq.first[5]);
        _expansions.add(PokeExpansion.fromDB(PokeIdentifier(row[0]), row[1], row[2], row[3], ExpansionType.values.byName(row[4]), (row[5] as String).split(";"), cards));
      } on StatitikException catch( e ) {
        printOutput("Expansion Error: ${row[0]}/${row[2]} = ${e.msg}");
        rethrow;
      }
    }
    time.tick("Expansions");

    var productCategoryReq = await connection.query("SELECT * FROM `PK_produit_categorie`");
    for (var row in productCategoryReq) {
      _product_categories.add(PokeProductCategory(PokeIdentifier(row[0]), row[1] != 0));
    }
    time.tick("Product Categories");

    var productBoosterReq = await connection.query("SELECT * FROM `PK_produit_booster`");
    for (var row in productBoosterReq) {
      _product_boosters.add(PokeProductBooster.read(this, PokeIdentifier(row[0]), readBlob(row[1]) ));
    }
    time.tick("Product boosters");

    var productSideReq = await connection.query("SELECT * FROM `PK_produit_annexe`");
    for (var row in productSideReq) {
      final category = productCategory(PokeIdentifier(row[1]))!;
      _product_sides.add(PokeProductSide(PokeIdentifier(row[0]), category, row[2], PokeIdentifier(row[3]) ));
    }
    time.tick("Side Products");

    var productsReq = await connection.query("SELECT * FROM `PK_produit`");
    for (var row in productsReq) {
      if(row[3] != null) {
        final category = productCategory(PokeIdentifier(row[1]))!;

        try {
          final product = PokeProduct.fromDB(
              PokeIdentifier(row[0]), category, row[2], row[3]);
          product.readOldData(readBlob(row[4]), this);
          _products.add(product);
        } catch (_, _) {
          final p = PokeProduct.readData(this, PokeIdentifier(row[0]), category, row[2], row[3], readBlob(row[4]));
          _products.add(p);
        }
      }
    }
    time.tick("Products");

    // Link
    _linkItems();

    time.tick("Links");
  }

  void updateLanguageData() {
    _locationBylanguages = {};
    for( final language in _languages.values ) {
      final location = language.location();
      if( !_locationBylanguages.containsKey(location) ) {
        _locationBylanguages[location] = [];
      }
      _locationBylanguages[location]!.add(language);
    }
  }

  void _linkItems() {
    for(final PokeSerie serie in _series) {
      for (var expansion in _expansions) {
        if(expansion.isSameSerie(serie.id())) {
          serie.addExpansion( expansion);
        }
      }
    }

    assert(28 < _rarities.length);
    _unknownRarity = _rarities[28];

    for(final rarity in _rarities) {
      // register into list
      if(rarity.isAsian()) {
        _japanRarity.add(rarity);
      }
      if(rarity.isWorld()) {
        _worldRarity.add(rarity);
      }
      // Good card
      if(rarity.isGood()) {
        _goodCard.add(rarity);
      }
      // Other than reverse
      if(rarity.isOtherReversed()) {
        _otherThanReverse.add(rarity);
      }
    }
  }

  BinaryReader readBlob(dynamic dbRow)
  {
    return BinaryReader(Uint8List.fromList((dbRow as Blob).toBytes()));
  }

  Future<void> updatePokeExpansionCards(PokeIdentifier pid, PokeExpansionCards cards, TransactionContext connection) async
  {
    final wCard = BinaryWriter();
    PokeDbCardsBlob.writeCard(wCard, cards.cards);
    final eCard = BinaryWriter();
    PokeDbCardsBlob.writeOther(eCard, cards.energyCard);
    final oCard = BinaryWriter();
    PokeDbCardsBlob.writeOther(oCard, cards.noNumberedCard);

    var query = 'UPDATE `PK_cartes_expansion` SET `cartes` = ?, `energies` = ?, `cartesSansNumero` = ?,'
        '`sousNoms` = ?, `configuration` = ?'
        ' WHERE `PK_cartes_expansion`.`id` = ${pid.id()}';
    await connection.queryMulti(query, [
      [
        cards.cards.isNotEmpty          ? wCard.toBytes() : null,
        cards.energyCard.isNotEmpty     ? eCard.toBytes() : null,
        cards.noNumberedCard.isNotEmpty ? oCard.toBytes() : null,
        PokeDbCardsBlob.convertCode(cards.codeNaming),
        cards.configuration
      ]]);
  }

  Future<void> updatePokeExpansion(PokeExpansion expansion, TransactionContext connection) async
  {
    // Save Cards
    await updatePokeExpansionCards(expansion.pid(), expansion.cards, connection);

    // Save expansions
    var query = 'REPLACE INTO `PK_expansion` (`id`, `sortie`, `icone`, `nbCarteBooster`, `type`, `nameCode`)'
        ' VALUES (?, ?, ?, ?, ?, ?);';
    await connection.queryMulti(query, [[expansion.pid().id(), expansion.released(), expansion.icon(),
      expansion.nbCardsPerBooster(), expansion.type(), expansion.codes()]]);
  }

  Future<void> updatePokeCard(List<List<Object?>> queries, TransactionContext connection) async
  {
    var query = 'REPLACE INTO `PK_cartes` (`id`, `info`)'
        ' VALUES (? ,?);';
    await connection.queryMulti(query, queries);
  }

  Future<void> updateProducts(TransactionContext connection, [List<PokeProduct>? products]) async
  {
    List<List<Object?>> queries = [];
    for(final product in products ?? _products) {
      final writer = BinaryWriter();
      product.dataToBytes(writer);
      queries.add([product.pid().id(), product.category.pid().id(), product.releaseDate, product.oldName(), writer.toBytes()]);
    }
    updateProduct(queries, connection);
  }
  Future<void> updateProduct(List<List<Object?>> queries, TransactionContext connection) async
  {
    var query = 'REPLACE INTO `PK_produit` (`id`, `id_categorie`, `sortie`, `nom`, `contenu`)'
        ' VALUES (?, ?, ?, ?, ?);';
    await connection.queryMulti(query, queries);
  }

  Future<void> sendProducts(TransactionContext connection, List<PokeProduct> products, bool creation) async {
    try {
      updateProducts(connection, products);

      Environment.instance.restoreAdminData();
    }
    catch(e){
      printOutput("Database error $e");
    }
  }

  Future<void> updateSideProducts(TransactionContext connection, [List<PokeProductSide>? sideProducts]) async
  {
    List<List<Object?>> queries = [];
    for(final sideProduct in sideProducts ?? _product_sides) {

      queries.add([sideProduct.pid().id(), sideProduct.category.pid().id(), sideProduct.releaseDate, sideProduct.idName().id()]);
    }
    updateProduct(queries, connection);
  }

  Future<void> updateSideProduct(List<List<Object?>> queries, TransactionContext connection) async
  {
    var query = 'REPLACE INTO `PK_produit_annexe` (`id`, `id_categorie`, `sortie`, `id_name`)'
        ' VALUES (?, ?, ?, ?);';
    await connection.queryMulti(query, queries);
  }

  Future<void> sendSideProducts(TransactionContext connection, List<PokeProductSide> sideProducts, bool creation) async {
    try {
      updateSideProducts(connection, sideProducts);

      Environment.instance.restoreAdminData();
    }
    catch(e){
      printOutput("Database error $e");
    }
  }

  // ------------------------------------------------------------------------
  //    Search
  // ------------------------------------------------------------------------
  List<PokeCardViewerIdentifier> searchCardIntoSubExtension(PokeCard searchCard, [bool supportedDuplicateSeCard=false]) {
    List<PokeCardViewerIdentifier> result = [];
    for (var expansion in _expansions) {
      if( supportedDuplicateSeCard ) {
        int id=0;
        for (var cards in expansion.cards.cards) {
          int subId=0;
          for (var card in cards) {
            if(card.card == searchCard) {
              result.add(PokeCardViewerIdentifier(expansion, PokeCardIdentifier.from([0, id, subId])));
            }
            subId += 1;
          }
          id += 1;
        }

        id=0;
        for (var card in expansion.cards.energyCard) {
          if(card.card == searchCard) {
            result.add(PokeCardViewerIdentifier(expansion, PokeCardIdentifier.from([1, id])));
          }
          id += 1;
        }

        id=0;
        for (var card in expansion.cards.noNumberedCard) {
          if(card.card == searchCard) {
            result.add(PokeCardViewerIdentifier(expansion, PokeCardIdentifier.from([2, id])));
          }
          id += 1;
        }
      }
    }
    return result;
  }

  PokeSerie serieFrom(PokeExpansion expansion) {
    return _series.firstWhere((element) => expansion.isSameSerie(element.id()));
  }

  (PokeLanguage?, PokeExpansion?) expansionFromOldDB(int oldID) {
    final Map<int, (Language, int)> convert = {
      1	: (Language.fr,1108040000),
      2	: (Language.fr,1108030000),
      3	: (Language.fr,1108020000),
      4	: (Language.fr,1108010000),
      5	: (Language.fr,1108035000),
      6	: (Language.fr,1108045000),
      7	: (Language.fr,1108050000),
      8	: (Language.fr,1107120000),
      9	: (Language.fr,1107115000),
      10	: (Language.fr,1107110000),
      11	: (Language.fr,1107100000),
      12	: (Language.fr,1107090000),
      13	: (Language.fr,1107080000),
      14	: (Language.en,1108040000),
      15	: (Language.en,1108030000),
      16	: (Language.en,1108020000),
      17	: (Language.en,1108010000),
      18	: (Language.en,1108035000),
      19	: (Language.en,1108045000),
      20	: (Language.en,1108050000),
      21	: (Language.en,1107120000),
      22	: (Language.en,1107115000),
      23	: (Language.en,1107110000),
      24	: (Language.en,1107100000),
      25	: (Language.en,1107090000),
      26	: (Language.en,1107080000),
      27	: (Language.jp,1008040000),
      28	: (Language.jp,1008030000),
      29	: (Language.jp,1008020000),
      30	: (Language.jp,1008010000),
      31	: (Language.jp,1008050000),
      32	: (Language.fr,1107050000),
      33	: (Language.en,1107050000),
      34	: (Language.fr,1107060000),
      35	: (Language.fr,1107070000),
      36	: (Language.en,1107060000),
      37	: (Language.en,1107070000),
      38	: (Language.fr,1107040000),
      39	: (Language.fr,1107030000),
      40	: (Language.en,1107040000),
      41	: (Language.en,1107030000),
      42	: (Language.fr,1107020000),
      43	: (Language.fr,1107010000),
      44	: (Language.en,1107020000),
      45	: (Language.en,1107010000),
      46	: (Language.fr,1106120000),
      47	: (Language.en,1106120000),
      48	: (Language.jp,1008011000),
      49	: (Language.jp,1008051000),
      50	: (Language.fr,1108060000),
      51	: (Language.en,1108060000),
      52	: (Language.jp,1008060000),
      53	: (Language.jp,1008061000),
      54	: (Language.jp,1008062000),
      55	: (Language.jp,1008052000),
      56	: (Language.fr,1108070000),
      57	: (Language.en,1108070000),
      58	: (Language.fr,1107075000),
      59	: (Language.en,1107075000),
      60	: (Language.fr,1107035000),
      61	: (Language.en,1107035000),
      62	: (Language.fr,1100000000),
      63	: (Language.en,1100000000),
      64	: (Language.fr,1106110000),
      65	: (Language.fr,1106100000),
      66	: (Language.fr,1106090000),
      67	: (Language.en,1106110000),
      68	: (Language.en,1106100000),
      69	: (Language.en,1106090000),
      70	: (Language.fr,1108075000),
      71	: (Language.en,1108075000),
      72	: (Language.jp,1008070000),
      73	: (Language.jp,1008071000),
      74	: (Language.jp,1008080000),
      75	: (Language.jp,1008041000),
      76	: (Language.jp,1008031000),
      77	: (Language.jp,1008021000),
      78	: (Language.jp,1008012000),
      79	: (Language.fr,1108080000),
      80	: (Language.en,1108080000),
      81	: (Language.fr,1106080000),
      82	: (Language.en,1106080000),
      83	: (Language.fr,1106070000),
      84	: (Language.en,1106070000),
      85	: (Language.fr,1106060000),
      86	: (Language.en,1106060000),
      87	: (Language.fr,1106050000),
      88	: (Language.en,1106050000),
      89	: (Language.fr,1106040000),
      90	: (Language.en,1106040000),
      91	: (Language.fr,1106030000),
      92	: (Language.en,1106030000),
      93	: (Language.fr,1106020000),
      94	: (Language.en,1106020000),
      95	: (Language.fr,1106010000),
      96	: (Language.en,1106010000),
      97	: (Language.fr,1106000000),
      98	: (Language.en,1106000000),
      99	: (Language.jp,1008000000),
      100	: (Language.jp,1008081000),
      101	: (Language.jp,1008083000),
      102	: (Language.jp,1008082000),
      103	: (Language.fr,1108090000),
      104	: (Language.en,1108090000),
      105	: (Language.jp,1008090000),
      106	: (Language.jp,1008918000),
      107	: (Language.jp,1008916000),
      108	: (Language.jp,1008004000),
      109	: (Language.jp,1008005000),
      110	: (Language.jp,1008914000),
      111	: (Language.jp,1008915000),
      112	: (Language.jp,1008003000),
      113	: (Language.jp,1008002000),
      114	: (Language.jp,1008001000),
      115	: (Language.jp,1008913000),
      116	: (Language.jp,1008909000),
      117	: (Language.jp,1008911000),
      118	: (Language.jp,1008912000),
      119	: (Language.jp,1008910000),
      120	: (Language.jp,1008907000),
      121	: (Language.jp,1008908000),
      122	: (Language.jp,1008906000),
      123	: (Language.jp,1008905000),
      124	: (Language.jp,1008904000),
      125	: (Language.jp,1008903000),
      126	: (Language.jp,1008902000),
      127	: (Language.jp,1008901000),
      128	: (Language.jp,1008917000),
      129	: (Language.jp,1008923000),
      130	: (Language.fr,1108000000),
      131	: (Language.en,1108000000),
      132	: (Language.jp,1007120000),
      133	: (Language.jp,1007121000),
      134	: (Language.jp,1008919000),
      135	: (Language.jp,1008091000),
      136	: (Language.jp,1008920000),
      137	: (Language.jp,1008921000),
      138	: (Language.jp,1008103000),
      139	: (Language.fr,1108100000),
      140	: (Language.en,1108100000),
      141	: (Language.jp,1008101000),
      142	: (Language.jp,1008100000),
      143	: (Language.jp,1007112000),
      144	: (Language.jp,1007111000),
      145	: (Language.jp,1007110000),
      146	: (Language.jp,1007912000),
      147	: (Language.jp,1007102000),
      148	: (Language.jp,1007101000),
      149	: (Language.jp,1007100000),
      150	: (Language.jp,1007002000),
      151	: (Language.jp,1007911000),
      152	: (Language.jp,1007913000),
      153	: (Language.jp,1007092000),
      154	: (Language.jp,1007091000),
      155	: (Language.jp,1007090000),
      156	: (Language.jp,1007910000),
      157	: (Language.jp,1007909000),
      158	: (Language.jp,1007908000),
      159	: (Language.jp,1007082000),
      160	: (Language.jp,1007081000),
      161	: (Language.jp,1007080000),
      162	: (Language.jp,1007072000),
      163	: (Language.jp,1007071000),
      164	: (Language.jp,1007907000),
      165	: (Language.jp,1007070000),
      166	: (Language.jp,1007000000),
      167	: (Language.jp,1007062000),
      168	: (Language.jp,1007061000),
      169	: (Language.jp,1007060000),
      170	: (Language.jp,1008102000),
      171	: (Language.jp,1007906000),
      172	: (Language.jp,1007052000),
      173	: (Language.jp,1007051000),
      174	: (Language.jp,1007050000),
      175	: (Language.jp,1007905000),
      176	: (Language.jp,1007904000),
      177	: (Language.jp,1007042000),
      178	: (Language.jp,1007041000),
      179	: (Language.jp,1007040000),
      180	: (Language.fr,1108115000),
      181	: (Language.en,1108115000),
      182	: (Language.jp,1007032000),
      183	: (Language.jp,1007031000),
      184	: (Language.jp,1007030000),
      185	: (Language.jp,1007022000),
      186	: (Language.jp,1007903000),
      187	: (Language.jp,1007021000),
      188	: (Language.jp,1007020000),
      189	: (Language.jp,1007902000),
      190	: (Language.jp,1007012000),
      191	: (Language.jp,1007011000),
      192	: (Language.jp,1007010000),
      193	: (Language.jp,1007001000),
      194	: (Language.jp,1007901000),
      195	: (Language.fr,1108110000),
      196	: (Language.en,1108110000),
      197	: (Language.jp,1008006000),
      198	: (Language.jp,1008110000),
      199	: (Language.jp,1008925000),
      200	: (Language.jp,1008926000),
      201	: (Language.jp,1008111000),
      202	: (Language.fr,1108120000),
      203	: (Language.en,1108120000),
      204	: (Language.jp,1008120000),
      205	: (Language.jp,1008121000),
      206	: (Language.jp,1008924000),
      207	: (Language.en,1108125000),
      208	: (Language.fr,1108125000),
      209	: (Language.fr,1109010000),
      210	: (Language.en,1109010000),
      211	: (Language.jp,1009010000),
      212	: (Language.jp,1009011000),
      213	: (Language.fr,1109000000),
      214	: (Language.en,1109000000),
      215	: (Language.jp,1009901000),
      216	: (Language.jp,1009902000),
      217	: (Language.jp,1009903000),
      218	: (Language.jp,1009904000),
      219	: (Language.jp,1009000000),
      220	: (Language.jp,1009012000),
      221	: (Language.jp,1009905000),
      222	: (Language.jp,1009020000),
      223	: (Language.jp,1009021000),
      224	: (Language.jp,1009906000),
      225	: (Language.jp,1009022000),
      226	: (Language.fr,1109020000),
      227	: (Language.en,1109020000),
      228	: (Language.fr,1109030000),
      229	: (Language.en,1109030000),
      230	: (Language.jp,1009030000),
      231	: (Language.fr,1109021000),
      232	: (Language.en,1109021000)
    };
    if( oldID == 0) {
      return (null, null);
    }
    try {
      final (idL, idExp) = convert[oldID]!;
      return (_languages[idL], expansion(PokeIdentifier(idExp)));
    } catch(_, _) {
      printOutput("Not found: $oldID");
      rethrow;
    }
  }

  PokeIdentifier newId(PokeIdentifierType type, List allItems) {
    int newCode = allItems.last.pid().number();

    var newId = PokeIdentifier.create(type, newCode);

    //Search if product id is unique
    while(allItems.any((item){
      return item.pid() == newId;
    }))
    {
      newCode += 1;
      newId = PokeIdentifier.create(type, newCode);
    }
    return newId;
  }

  List<PokeCardViewerIdentifier> searchCardIntoAllSubExtension(PokeCard searchCard) {
    List<PokeCardViewerIdentifier> result = [];
    for (final exp in _expansions) {
      int id=0;
      for (var cards in exp.cards.cards) {
        int subId=0;
        for (var card in cards) {
          if(card.card == searchCard) {
            result.add(PokeCardViewerIdentifier(exp, PokeCardIdentifier.from([0, id, subId])));
          }
          subId += 1;
        }
        id += 1;
      }

      id=0;
      for (var card in exp.cards.energyCard) {
        if(card.card == searchCard) {
          result.add(PokeCardViewerIdentifier(exp, PokeCardIdentifier.from([1, id])));
        }
        id += 1;
      }

      id=0;
      for (var card in exp.cards.noNumberedCard) {
        if(card.card == searchCard) {
          result.add(PokeCardViewerIdentifier(exp, PokeCardIdentifier.from([2, id])));
        }
        id += 1;
      }
    }
    return result;
  }

  Future<PokeIdentifier> addNewDresseurObjectName(TransactionContext connection, String newText, PokeLanguage langue) async
  {
    // Generate new ID
    PokeIdentifier idOther = newId(PokeIdentifierType.object, _otherCards);

    for(final l in _languages.values ) {
      final value = (l == langue)
          ? newText
          : "<$newText>";

      var query = 'INSERT INTO `${l.db()}` (`id_nom`, `nom`)'
          ' VALUES (?, ?);';
      await connection.queryMulti(query, [[idOther.id(), value]]);
    }
    return idOther;
  }

  Future<PokeIdentifier> addNewEffectName(TransactionContext connection, String effectLabels, PokeLanguage language) async {
    assert(effectLabels.isNotEmpty);
    // Generate new ID
    PokeIdentifier idEffect = newId(PokeIdentifierType.effect, _effectNames);

    // Added
    for(final l in _languages.values ) {
      final value = (l == language)
          ? effectLabels
          : "<$effectLabels>";

      var query = 'INSERT INTO `${l.db()}` (`id_nom`, `nom`)'
          ' VALUES (?, ?);';
      await connection.queryMulti(query, [[idEffect.id(), value]]);
    }
    return idEffect;
  }

  Future<void> saveDatabaseSEC(PokeExpansion expansion, connection) async {
    // Compute next Id of card
    int nextId = _cards.length + 1;
    printOutput("Next id of card is $nextId");

    // Update or create all cards
    printOutput("Start update card data.");
    int updated = 0;
    int created = 0;
    for(var cardLists in expansion.cards.cards) {
      for(var card in cardLists) {
        // Save and update + maintain admin DB
        if( await saveDatabase(card.card, nextId, connection) ) {
          created += 1;
          nextId  += 1;
          printOutput("New card is add. Next id will be $nextId");
        } else {
          updated +=1;
        }
      }
    }
    for(var cardLists in [expansion.cards.energyCard, expansion.cards.noNumberedCard]) {
      for(var card in cardLists) {
        // Save and update + maintain admin DB
        if( await saveDatabase(card.card, nextId, connection) ) {
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
    var query = 'UPDATE `PK_cartes_expansion` SET `cartes` = ?, `energies` = ?, `cartesSansNumero` = ?'
        ' WHERE `PK_cartes_expansion`.`id` = ${expansion.pid().id()}';

    final writerCard = BinaryWriter();
    PokeDbCardsBlob.writeCard(writerCard, expansion.cards.cards);
    final writerEnergy = BinaryWriter();
    PokeDbCardsBlob.writeOther(writerEnergy, expansion.cards.energyCard);
    final writerNoNumber = BinaryWriter();
    PokeDbCardsBlob.writeOther(writerNoNumber, expansion.cards.noNumberedCard);

    await connection.queryMulti(query, [
      [
        writerCard.toBytes(),
        expansion.cards.energyCard.isEmpty     ? null : writerEnergy.toBytes(),
        expansion.cards.noNumberedCard.isEmpty ? null : writerNoNumber.toBytes()
      ]]);
  }

  Future<bool> saveDatabase(PokeCard card, int nextId, connection) async {
    final writer = BinaryWriter();
    card.toBytes(writer);
    List<Object?> data = [writer.toBytes()];

    var query = "";

    final isCreation = card.pid().id() == 0;
    if (isCreation) {
      data.insert(0, nextId);
      query = 'INSERT INTO `PK_cartes` VALUES(?, ?);';

      //printOutput("New card added at $nextId and we update internal list");
    } else {
      query = 'UPDATE `PK_cartes` SET `info` = ?'
          ' WHERE `PK_cartes`.`id` = ${card.pid().id()}';

      //printOutput("Update card at $idCard and we update internal list");
    }

    try {
      await connection.queryMulti(query, [data]);
    } catch(e) {
      printOutput("Request error: $e");
      rethrow;
    }
    return isCreation;
  }
}