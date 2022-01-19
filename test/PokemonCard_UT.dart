import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/cardDrawData.dart';

import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

void main() {

  test('CardMarkers', () {
    List<CardMarkers> c =
    [
      CardMarkers.from([CardMarker.VMAX, CardMarker.MillePoint]),
      CardMarkers.from(<CardMarker>[]),
      CardMarkers.from([CardMarker.VMAX]),
      CardMarkers.from([CardMarker.Escouade, CardMarker.Restaure]),
      CardMarkers.from([CardMarker.Restaure, CardMarker.RegenerationAlpha]),
      CardMarkers.from([CardMarker.SP, CardMarker.Yon]), // Limit new int32
      CardMarkers.from([CardMarker.VSTAR, CardMarker.VUNION]),
    ];

    expect([0, 0, 0 ,0 ,20], c[0].toBytes());
    expect([0, 0, 0 ,0, 0],  c[1].toBytes());
    expect([0, 0, 0 ,0, 4],  c[2].toBytes());
    expect([0, 0, 0 ,4, 1],  c[3].toBytes());
    expect([0, 2, 0 ,4, 0],  c[4].toBytes());
    expect([1, 128, 0 ,0, 0],c[5].toBytes());
    expect([24, 0, 0 ,0, 0], c[6].toBytes());

    for(CardMarkers code in c) {
      CardMarkers codeS = CardMarkers.fromBytes(code.toBytes());
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
          expect(code.countNormal,  itSS.current.countNormal);
          expect(code.countHalo,    itSS.current.countHalo);
          expect(code.countReverse, itSS.current.countReverse);
          itSS.moveNext();
        });
        itS.moveNext();
      });
    };

    List<ExtensionDrawCards> c =
    [
      ExtensionDrawCards.from([[CodeDraw(1, 2, 3), CodeDraw(4, 5, 2), CodeDraw()], [CodeDraw(2, 4, 2)], [CodeDraw(1,0,0)]]),
      //ExtensionDrawCards.from(<List<CodeDraw>>[]) // Impossible
    ];

    for(ExtensionDrawCards code in c) {
      ExtensionDrawCards codeS = ExtensionDrawCards.fromBytes(code.toBytes());
      compare(codeS, code);
    }

    // Simplify
    var long = ExtensionDrawCards.from(c[0].draw + [[CodeDraw()], [CodeDraw()], [CodeDraw()], [CodeDraw()]]);
    ExtensionDrawCards simplified = ExtensionDrawCards.fromBytes(long.toBytes());

    compare(c[0], simplified);
  });

  test('PokemonCardExtension', () {
    Map collection = {
      1: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Pika", "Pika", "Pika"]), 1, 25),)], Level.Base, Type.Eau, CardMarkers()),
      2: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Chu", "Chu", "Chu"]), 2, 25),)],    Level.Level1, Type.Electrique, CardMarkers()),
      3: PokemonCardData([Pokemon(PokemonInfo(MultiLanguageString(["Jp", "Jp", "Jp"]), 2, 25),)],    Level.Level2, Type.Electrique, CardMarkers()),
    };
    Map rCollection = collection.map((k, v) => MapEntry(v, k));

    List<PokemonCardExtension> c =
    [
      PokemonCardExtension(collection[1], Rarity.Chromatique),
      PokemonCardExtension(collection[2], Rarity.ArcEnCiel),
      PokemonCardExtension(collection[3], Rarity.Empty, image: "Image.png"),
    ];

    for(PokemonCardExtension code in c) {
      PokemonCardExtension codeS = PokemonCardExtension.fromBytes(ByteParser(code.toBytes(rCollection)), collection);
      expect(codeS.data,   code.data); // Pointer comparison
      expect(codeS.rarity, code.rarity);
      expect(codeS.image, code.image);
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