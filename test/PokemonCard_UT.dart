import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/cardDrawData.dart';

import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

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
    var compare = (ExtensionDrawCards codeS, ExtensionDrawCards code) {
      expect(codeS.draw.length, code.draw.length);

      var itS = codeS.draw.iterator;
      itS.moveNext();
      code.draw.forEach((subCards) {
        expect(itS.current, isNot(null));
        var itSS = itS.current.iterator;
        itSS.moveNext();

        subCards.forEach((code) {
          expect(itSS.current, isNot(null));

          var setSS = itSS.current.countBySet.iterator;
          code.countBySet.forEach((element) {
            expect(element,  setSS.current);
            setSS.moveNext();
          });
          itSS.moveNext();
        });
        itS.moveNext();
      });
    };

    List<ExtensionDrawCards> c =
    [
      ExtensionDrawCards.from([[CodeDraw.fromOld(1, 2, 3), CodeDraw.fromOld(4, 5, 2), CodeDraw.fromOld()], [CodeDraw.fromOld(2, 4, 2)], [CodeDraw.fromOld(1,0,0)]]),
      //ExtensionDrawCards.from(<List<CodeDraw>>[]) // Impossible
    ];

    for(ExtensionDrawCards code in c) {
      ExtensionDrawCards codeS = ExtensionDrawCards.fromBytes(code.toBytes());
      compare(codeS, code);
    }

    // Simplify
    var long = ExtensionDrawCards.from(c[0].draw + [[CodeDraw.fromOld()], [CodeDraw.fromOld()], [CodeDraw.fromOld()], [CodeDraw.fromOld()]]);
    ExtensionDrawCards simplified = ExtensionDrawCards.fromBytes(long.toBytes());

    compare(c[0], simplified);
  });

  test('PokemonCardExtension', () {
    Map allSets = {
      0: CardSet(MultiLanguageString(["set", "set", "set"]), Colors.green, "normal"),
    };

    Map raritySets = {
      0: Rarity.fromText(0, "Unknown", Colors.black),
      1: Rarity.fromText(1, "C",       Colors.green),
      2: Rarity.fromText(2, "U",       Colors.green),
      3: Rarity.fromText(3, "R",       Colors.blue),
    };
    unknownRarity = raritySets[0];

    Map collection = {
      1: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Pika", "Pika", "Pika"]), 1, 25),)], Level.Base,   Type.Eau, CardMarkers()),
      2: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Chu", "Chu", "Chu"]), 2, 25),)],    Level.Level1, Type.Electrique, CardMarkers()),
      3: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Jp", "Jp", "Jp"]), 2, 25),)],       Level.Level2, Type.Electrique, CardMarkers()),
    };
    Map rCollection = collection.map((k, v) => MapEntry(v, k));
    Map rAllSets    = allSets.map((k, v) => MapEntry(v, k));
    Map rRaritySets = raritySets.map((k, v) => MapEntry(v, k));

    List<PokemonCardExtension> c =
    [
      PokemonCardExtension(collection[1], raritySets[1]),
      PokemonCardExtension(collection[2], raritySets[2]),
      PokemonCardExtension(collection[3], raritySets[0], image: "Image.png"),
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
    effectName.attack = [Type.Electrique, Type.Electrique, Type.Incolore];

    CardEffect effectDescription    = CardEffect();
    effectDescription.description = CardDescription(2);

    CardEffect effectBoth           = CardEffect();
    effectName.title = 2;
    effectName.attack = [Type.Electrique, Type.Electrique, Type.Incolore];
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