import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/card_set.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/extension.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/marker.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/models/serie_type.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/sub_extension_cards.dart';
import 'package:statitikcard/services/models/type_card.dart';

import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

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
      CardSet(MultiLanguageString(["S0","S0","S0"]), Colors.green, "normal", false, false, false),
      CardSet(MultiLanguageString(["S1","S1","S1"]), Colors.blue, "normal", false, false, false),
    ];
    var card = [
      PokemonCardExtension.empty(defaultCard, r),
      PokemonCardExtension.empty(defaultCard, r)
    ];
    card[0].sets.add(sets[0]);
    card[0].sets.add(sets[1]);
    card[1].sets.add(sets[0]);
    card[0].images[0].add(ImageDesign());
    card[0].images.add([ImageDesign()]);

    var seCard = SubExtensionCards([[card[0], card[1]], [card[1]], [card[0]]], [], 0);
    seCard.energyCard.add(card[0]);
    seCard.energyCard.add(card[0]);
    seCard.energyCard.add(card[1]);

    var se = SubExtension(1, "Demo", "D", ex, DateTime.now(), seCard, SerieType.normal, ["D"], 10 );

    var compare = (ExtensionDrawCards codeS, ExtensionDrawCards code) {
      expect(codeS.drawCards.length, code.drawCards.length);

      var itS = codeS.drawCards.iterator;
      for (var subCards in code.drawCards) {
        itS.moveNext();

        expect(itS.current, isNot(null));
        var itSS = itS.current.iterator;
        for (var code in subCards) {
          itSS.moveNext();
          expect(itSS.current, isNot(null));

          var setSS = itSS.current.iterator;
          var cardSS = code.iterator;
          while(cardSS.moveNext()) {
            setSS.moveNext();
            expect(cardSS.current,  setSS.current);
          }
        }
      }

      // Energy
      {
        expect(codeS.drawEnergies.length, code.drawEnergies.length);
        var itRef = codeS.drawEnergies.iterator;
        for (var cardCode in code.drawEnergies) {
          itRef.moveNext();
          var setSS = itRef.current.iterator;
          var cardSS = cardCode.iterator;
          while(cardSS.moveNext()) {
            setSS.moveNext();
            expect(cardSS.current,  setSS.current);
          }
        }
      }
    };

    // Demo data
    ExtensionDrawCards edc = ExtensionDrawCards.fromSubExtension(se);
    edc.drawCards[0][0].setCount(2, 0);
    edc.drawCards[0][0].setCount(3, 1);
    edc.drawCards[0][1].setCount(1, 0);
    edc.drawCards[2][0].setCount(4, 0);
    edc.drawCards[2][0].setCount(0, 1);

    edc.drawEnergies[0].setCount(3, 0);
    edc.drawEnergies[0].setCount(2, 1);
    edc.drawEnergies[2].setCount(1, 0);

    // From byte to byte
    ExtensionDrawCards codeS = ExtensionDrawCards.fromBytes(se, edc.toBytes());
    compare(codeS, edc);

    // Simplify
    ExtensionDrawCards long = ExtensionDrawCards.fromSubExtension(se);
    long.drawCards[0][0].setCount(2, 0);
    long.drawCards[0][0].setCount(3, 1);
    long.drawCards[0][1].setCount(1, 0);

    long.drawEnergies[0].setCount(3, 0);
    long.drawEnergies[0].setCount(2, 1);

    ExtensionDrawCards simplified = ExtensionDrawCards.fromBytes(se, long.toBytes());

    expect( long.drawCards[0][0].countBySet(0), simplified.drawCards[0][0].countBySet(0) );
    expect( long.drawCards[0][0].countBySet(1), simplified.drawCards[0][0].countBySet(1) );
    expect( long.drawCards[0][1].countBySet(0), simplified.drawCards[0][1].countBySet(0) );

    expect( 1, simplified.drawEnergies.length );
    expect( long.drawEnergies[0].countBySet(0), simplified.drawEnergies[0].countBySet(0) );
    expect( long.drawEnergies[0].countBySet(1), simplified.drawEnergies[0].countBySet(1) );
  });

  test('PokemonCardExtension', () {
    Map allSets = {
      0: CardSet(MultiLanguageString(["set", "set", "set"]), Colors.green, "normal", false, false, false),
    };

    Map raritySets = {
      0: Rarity.fromText(0, MultiLanguageString(["Unknown","Unknown","Unknown"]), Colors.black),
      1: Rarity.fromText(1, MultiLanguageString(["C","C","C"]),       Colors.green),
      2: Rarity.fromText(2, MultiLanguageString(["U","U","U"]),       Colors.green),
      3: Rarity.fromText(3, MultiLanguageString(["R","R","R"]),       Colors.blue),
    };
    Environment.instance.collection.unknownRarity = raritySets[0];

    Map collection = {
      1: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Pika", "Pika", "Pika"]), 1, 25),)], Level.base,   TypeCard.eau, CardMarkers()),
      2: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Chu", "Chu", "Chu"]), 2, 25),)],    Level.level1, TypeCard.electrique, CardMarkers()),
      3: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Jp", "Jp", "Jp"]), 2, 25),)],       Level.level2, TypeCard.electrique, CardMarkers()),
    };
    Map rCollection = collection.map((k, v) => MapEntry(v, k));
    Map rAllSets    = allSets.map((k, v) => MapEntry(v, k));
    Map rRaritySets = raritySets.map((k, v) => MapEntry(v, k));

    List<PokemonCardExtension> c =
    [
      PokemonCardExtension.empty(collection[1], raritySets[1]),
      PokemonCardExtension.empty(collection[2], raritySets[2]),
      PokemonCardExtension.empty(collection[3], raritySets[0]),
    ];
    var img = ImageDesign();
    img.image = "image.png";
    c[2].images.add([img]);

    for(PokemonCardExtension code in c) {
      PokemonCardExtension codeS = PokemonCardExtension.fromBytes(ByteParser(code.toBytes(rCollection, rAllSets, rRaritySets)), collection, allSets, raritySets);
      expect(codeS.data,   code.data); // Pointer comparison
      expect(codeS.rarity, code.rarity);
      expect(codeS.images.length,  code.images.length);
    }
  });

  test('CardEffects', () {

    CardEffect effectEmpty          = CardEffect();
    CardEffect effectName           = CardEffect();
    effectName.title = 1;
    effectName.attack = [TypeCard.electrique, TypeCard.electrique, TypeCard.incolore];

    CardEffect effectDescription    = CardEffect();
    effectDescription.description = CardDescription(2);

    CardEffect effectBoth           = CardEffect();
    effectName.title = 2;
    effectName.attack = [TypeCard.electrique, TypeCard.electrique, TypeCard.incolore];
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
      for (var effect in codeS.effects) {
        itEffect.moveNext();
        expect(effect.attack,      itEffect.current.attack);
        expect(effect.title,       itEffect.current.title);
        if(effect.description != null) {
          expect(effect.description!.idDescription, itEffect.current.description!.idDescription);
          expect(effect.description!.parameters.length, itEffect.current.description!.parameters.length);
        } else {
          expect(effect.description, itEffect.current.description);
        }
      }
    }
  });
}