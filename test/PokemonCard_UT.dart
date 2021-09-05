import 'package:flutter_test/flutter_test.dart';
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
    ];
    for(CardMarkers code in c) {
      CardMarkers codeS = CardMarkers.fromBytes(code.toBytes());
      expect(codeS.markers, code.markers);
    }

    expect([0, 0, 0 ,0 ,20], c[0].toBytes());
    expect([0, 0, 0 ,0, 0],  c[1].toBytes());
    expect([0, 0, 0 ,0, 4],  c[2].toBytes());
    expect([0, 0, 0 ,4, 1],  c[3].toBytes());
    expect([0, 2, 0 ,4, 0],  c[4].toBytes());
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
      1: PokemonCardData([Pokemon(PokemonInfo(["Pika", "Pika", "Pika"], 1, 25),)], Level.Base, Type.Eau, CardMarkers()),
      2: PokemonCardData([Pokemon(PokemonInfo(["Chu", "Chu", "Chu"], 2, 25),)], Level.Level1, Type.Electrique, CardMarkers()),
    };
    Map rCollection = collection.map((k, v) => MapEntry(v, k));

    List<PokemonCardExtension> c =
    [
      PokemonCardExtension(collection[1], Rarity.Chromatique),
      PokemonCardExtension(collection[2], Rarity.ArcEnCiel)
    ];

    for(PokemonCardExtension code in c) {
      PokemonCardExtension codeS = PokemonCardExtension.fromBytes(ByteParser(code.toBytes(rCollection)), collection);
      expect(codeS.data,   code.data); // Pointer comparison
      expect(codeS.rarity, code.rarity);
    }
  });
}