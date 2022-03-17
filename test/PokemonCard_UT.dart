import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/CardTitleData.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

void main() {

  test('CardMarkers', () {
    Map markers = {
      3: CardMarker(MultiLanguageString(["A", "A", "A"]), Colors.black, false),
      5: CardMarker(MultiLanguageString(["B", "B", "B"]), Colors.green, false),

      1: CardMarker(MultiLanguageString(["C", "C", "C"]), Colors.green, false),
      11: CardMarker(MultiLanguageString(["C", "C", "C"]), Colors.green, false),
      26: CardMarker(MultiLanguageString(["C", "C", "C"]), Colors.green, false),

      32: CardMarker(MultiLanguageString(["C", "C", "C"]), Colors.green, false),
      33: CardMarker(MultiLanguageString(["D", "D", "D"]), Colors.green, false),
      36: CardMarker(MultiLanguageString(["E", "E", "E"]), Colors.green, false),
      37: CardMarker(MultiLanguageString(["F", "F", "F"]), Colors.green, false),
    };
    Map rmarkers = markers.map((k, v) => MapEntry(v, k));

    List<CardMarkers> c =
    [
      CardMarkers.from([markers[3], markers[5]]),
      CardMarkers.from(<CardMarker>[]),
      CardMarkers.from([markers[3]]),
      CardMarkers.from([markers[1], markers[11]]),
      CardMarkers.from([markers[11], markers[26]]),
      CardMarkers.from([markers[32], markers[33]]), // Limit new int32
      CardMarkers.from([markers[36], markers[37]]),
    ];

    expect([0, 0, 0 ,0 ,20], c[0].toBytes(rmarkers));
    expect([0, 0, 0 ,0, 0],  c[1].toBytes(rmarkers));
    expect([0, 0, 0 ,0, 4],  c[2].toBytes(rmarkers));
    expect([0, 0, 0 ,4, 1],  c[3].toBytes(rmarkers));
    expect([0, 2, 0 ,4, 0],  c[4].toBytes(rmarkers));
    expect([1, 128, 0 ,0, 0],c[5].toBytes(rmarkers));
    expect([24, 0, 0 ,0, 0], c[6].toBytes(rmarkers));

    for(CardMarkers code in c) {
      CardMarkers codeS = CardMarkers.fromBytes(code.toBytes(rmarkers), markers);
      expect(codeS.markers, code.markers);
    }
  });

  test('ExtensionDrawCards', () {
    var l  = Language(id: 1, image: "FR");
    var ex = Extension(0, "Ex", l);
    var r  = Rarity.fromText(0, MultiLanguageString(["S0","S0","S0"]), Colors.green);
    var defaultCard = PokemonCardData.empty();
    var sets = [
      CardSet(MultiLanguageString(["S0","S0","S0"]), Colors.green, "normal"),
      CardSet(MultiLanguageString(["S1","S1","S1"]), Colors.blue, "normal"),
    ];
    var card = [
      PokemonCardExtension.empty(defaultCard, r),
      PokemonCardExtension.empty(defaultCard, r)
    ];
    card[0].sets.add(sets[0]);
    card[0].sets.add(sets[1]);
    card[1].sets.add(sets[0]);

    var seCard = SubExtensionCards([[card[0], card[1]], [card[1]], [card[0]]], [], 0);
    seCard.energyCard.add(card[0]);
    seCard.energyCard.add(card[0]);
    seCard.energyCard.add(card[1]);

    var se = SubExtension(1, "Demo", "D", ex, DateTime.now(), seCard, SerieType.Normal, ["D"], 10 );

    var compare = (ExtensionDrawCards codeS, ExtensionDrawCards code) {
      expect(codeS.drawCards.length, code.drawCards.length);

      var itS = codeS.drawCards.iterator;
      code.drawCards.forEach((subCards) {
        itS.moveNext();

        expect(itS.current, isNot(null));
        var itSS = itS.current.iterator;
        subCards.forEach((code) {
          itSS.moveNext();
          expect(itSS.current, isNot(null));

          var setSS = itSS.current.countBySet.iterator;
          code.countBySet.forEach((element) {
            setSS.moveNext();
            expect(element,  setSS.current);
          });
        });
      });

      // Energy
      {
        expect(codeS.drawEnergies.length, code.drawEnergies.length);
        var itRef = codeS.drawEnergies.iterator;
        code.drawEnergies.forEach((cardCode) {
          itRef.moveNext();
          var setSS = itRef.current.countBySet.iterator;
          cardCode.countBySet.forEach((element) {
            setSS.moveNext();
            expect(element,  setSS.current);
          });
        });
      }
    };

    // Demo data
    ExtensionDrawCards edc = ExtensionDrawCards.fromSubExtension(se);
    edc.drawCards[0][0].countBySet[0] = 2;
    edc.drawCards[0][0].countBySet[1] = 3;
    edc.drawCards[0][1].countBySet[0] = 1;
    edc.drawCards[2][0].countBySet[0] = 4;
    edc.drawCards[2][0].countBySet[1] = 0;

    edc.drawEnergies[0].countBySet[0] = 3;
    edc.drawEnergies[0].countBySet[1] = 2;
    edc.drawEnergies[2].countBySet[0] = 1;

    // From byte to byte
    ExtensionDrawCards codeS = ExtensionDrawCards.fromBytes(se, edc.toBytes());
    compare(codeS, edc);

    // Simplify
    ExtensionDrawCards long = ExtensionDrawCards.fromSubExtension(se);
    long.drawCards[0][0].countBySet[0] = 2;
    long.drawCards[0][0].countBySet[1] = 3;
    long.drawCards[0][1].countBySet[0] = 1;

    long.drawEnergies[0].countBySet[0] = 3;
    long.drawEnergies[0].countBySet[1] = 2;

    ExtensionDrawCards simplified = ExtensionDrawCards.fromBytes(se, long.toBytes());

    expect( long.drawCards[0][0].countBySet[0], simplified.drawCards[0][0].countBySet[0] );
    expect( long.drawCards[0][0].countBySet[1], simplified.drawCards[0][0].countBySet[1] );
    expect( long.drawCards[0][1].countBySet[0], simplified.drawCards[0][1].countBySet[0] );

    expect( 1, simplified.drawEnergies.length );
    expect( long.drawEnergies[0].countBySet[0], simplified.drawEnergies[0].countBySet[0] );
    expect( long.drawEnergies[0].countBySet[1], simplified.drawEnergies[0].countBySet[1] );
  });

  test('PokemonCardExtension', () {
    Map allSets = {
      0: CardSet(MultiLanguageString(["set", "set", "set"]), Colors.green, "normal"),
    };

    Map raritySets = {
      0: Rarity.fromText(0, MultiLanguageString(["Unknown","Unknown","Unknown"]), Colors.black),
      1: Rarity.fromText(1, MultiLanguageString(["C","C","C"]),       Colors.green),
      2: Rarity.fromText(2, MultiLanguageString(["U","U","U"]),       Colors.green),
      3: Rarity.fromText(3, MultiLanguageString(["R","R","R"]),       Colors.blue),
    };
    Environment.instance.collection.unknownRarity = raritySets[0];

    Map collection = {
      1: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Pika", "Pika", "Pika"]), 1, 25),)], Level.Base,   TypeCard.Eau, CardMarkers()),
      2: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Chu", "Chu", "Chu"]), 2, 25),)],    Level.Level1, TypeCard.Electrique, CardMarkers()),
      3: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Jp", "Jp", "Jp"]), 2, 25),)],       Level.Level2, TypeCard.Electrique, CardMarkers()),
    };
    Map rCollection = collection.map((k, v) => MapEntry(v, k));
    Map rAllSets    = allSets.map((k, v) => MapEntry(v, k));
    Map rRaritySets = raritySets.map((k, v) => MapEntry(v, k));

    List<PokemonCardExtension> c =
    [
      PokemonCardExtension.empty(collection[1], raritySets[1]),
      PokemonCardExtension.empty(collection[2], raritySets[2]),
      PokemonCardExtension.empty(collection[3], raritySets[0], image: "Image.png"),
    ];

    for(PokemonCardExtension code in c) {
      PokemonCardExtension codeS = PokemonCardExtension.fromBytes(ByteParser(code.toBytes(rCollection, rAllSets, rRaritySets)), collection, allSets, raritySets);
      expect(codeS.data,   code.data); // Pointer comparison
      expect(codeS.rarity, code.rarity);
      expect(codeS.image,  code.image);
    }
  });

  test('CardEffects', () {

    CardEffect effectEmpty          = CardEffect();
    CardEffect effectName           = CardEffect();
    effectName.title = 1;
    effectName.attack = [TypeCard.Electrique, TypeCard.Electrique, TypeCard.Incolore];

    CardEffect effectDescription    = CardEffect();
    effectDescription.description = CardDescription(2);

    CardEffect effectBoth           = CardEffect();
    effectName.title = 2;
    effectName.attack = [TypeCard.Electrique, TypeCard.Electrique, TypeCard.Incolore];
    effectName.description = CardDescription(3);
    effectName.description!.parameters.add(5);

    List<CardEffects> c =
    [
      CardEffects(),
      CardEffects.fromEffects([effectEmpty]),
      CardEffects.fromEffects([effectName, effectDescription, effectBoth]),
    ];

    for(CardEffects code in c) {
      CardEffects codeS = CardEffects.fromBytes(code.toBytes());
      expect(codeS.effects.length, code.effects.length); // Pointer comparison

      var itEffect = code.effects.iterator;
      codeS.effects.forEach((effect) {
        itEffect.moveNext();
        expect(effect.attack,      itEffect.current.attack);
        expect(effect.title,       itEffect.current.title);
        if(effect.description != null) {
          expect(effect.description!.idDescription, itEffect.current.description!.idDescription);
          expect(effect.description!.parameters.length, itEffect.current.description!.parameters.length);
        } else {
          expect(effect.description, itEffect.current.description);
        }
      });
    }
  });
}