
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/models/database/poke_db_description.dart';
import 'package:statitikcard/models/poke_card.dart';
import 'package:statitikcard/models/poke_card_effect.dart';
import 'package:statitikcard/models/poke_card_energy_value.dart';
import 'package:statitikcard/models/poke_card_subject.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_expansion_cards.dart';
import 'package:statitikcard/models/poke_form.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_illustrator.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/models/poke_level.dart';
import 'package:statitikcard/models/poke_marker.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_region.dart';
import 'package:statitikcard/models/poke_serie.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/time_report.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

import 'database/poke_db_cards_blob.dart';

enum Language {
  en,
  fr,
  jp;

  static Language from(String s) {
    switch(s) {
      case "EN": return Language.en;
      case "FR": return Language.fr;
      case "JP": return Language.jp;
    }
    throw Exception("unknown");
  }
}

class PokeCollection {
  static const double _version = 1.1;
  Map<Language, PokeLangage> _languages = {};
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
  //List<PokeCard>      _cardsOld   = [];

  /// TEMPORARY ACCESS----------------------------
  List<PokeMarker> markers() { return _markers; }

  CardTitle? cardTitleOld(int oldId) {
    int newId = oldId;
    if( oldId >= 10000 ) {
      for(final obj in _otherCards) {
        final localId = obj.tmp_id();
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
        throw e;
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

  //List<PokeCard>      cardsOld()      { return _cardsOld; }

  /// TEMPORARY ACCESS----------------------------

  List<PokeCard>      cards()      { return _cards; }
  List<PokeExpansion> expansions() { return _expansions;}

  PokeLangage language(Language id) { return _languages[id]!; }
  List<PokeSerie> series() { return _series; }
  PokeSet?        sets(PokeIdentifier pid) {
    return _sets.firstWhere((element) => element.isEqual(pid) );
  }

  PokeRarity?    rarity(int id) {
    return _rarities.firstWhere((element) => element.isEqual(id));
  }

  PokeCard?      card(PokeIdentifier pid) {
    return _cards.firstWhere((element) => element.isEqual(pid));
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

  PokeCollection();

  PokeCollection.fromBytes(BinaryReader reader) {
    if(reader.readFloat32() == 1.0) {
      _languages = reader.readMap(
        (r) => Language.values[r.readInt8()],
        (r) => PokeLangage.fromBytes(r)
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
        (r) => PokeDbDescription.fromBytes(r)
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
    w.writeMap<Language, PokeLangage>(_languages,
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

  Future<void> readStaticData(TransactionContext connection) async
  {
    var time = TimeReport();

    var langueReq = await connection.query("SELECT * FROM `langue`");

    // Read language String
    for (var row in langueReq) {
      final dbName = PokeLangage.dbName(row[1]);
      var languageReq = await connection.query("SELECT * FROM `$dbName`");
      Map<PokeIdentifier, String> data = {};
      for (var row in languageReq) {
        data[PokeIdentifier(row[0])] = row[1];
      }
      _languages[Language.from(row[0])] = PokeLangage.fromDB(row[1], data, CardLocation.from(row[2]) );
      time.tick("Languages ${row[1]}");
    }

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

    // Link
    _linkItems();

    time.tick("Links");
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
    var query = 'REPLACE INTO `PK_expansion` (`id`, `info`)'
        ' VALUES (? ,?);';
    await connection.queryMulti(query, queries);
  }

  Future<void> updatePokeCard(List<List<Object?>> queries, TransactionContext connection) async
  {
    var query = 'REPLACE INTO `PK_cartes` (`id`, `info`)'
        ' VALUES (? ,?);';
    await connection.queryMulti(query, queries);
  }
}