import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/UserDrawFile.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/pokemonCard.dart';

void parseDualArray<T>(List<T> main, List<T> other, Function(T mElement, T oElement) parser) {
  expect(main.length, other.length);
  var itOther = other.iterator;
  main.forEach((element) {
    itOther.moveNext();
    parser(element, itOther.current);
  });
}

void main() {
  void compare(SessionDraw ref, SessionDraw cmp) {
    expect(ref.language, cmp.language);
    expect(ref.productAnomaly, cmp.productAnomaly);

    expect(ref.boosterDraws.length, cmp.boosterDraws.length);
    var itBoosterRef = ref.boosterDraws.iterator;
    cmp.boosterDraws.forEach((booster) {
      itBoosterRef.moveNext();
      expect(itBoosterRef.current.id,             booster.id);
      expect(itBoosterRef.current.subExtension,   booster.subExtension);
      expect(itBoosterRef.current.count,          booster.count);
      expect(itBoosterRef.current.creation,       booster.creation);
      expect(itBoosterRef.current.abnormal,       booster.abnormal);
      expect(itBoosterRef.current.nbCards,        booster.nbCards);

      parseDualArray<List<CodeDraw>>(itBoosterRef.current.cardDrawing!.drawCards, booster.cardDrawing!.drawCards,
        (mListElement, oListElement) {
          parseDualArray<CodeDraw>(mListElement, oListElement,
            (mElement, oElement) {
              expect(mElement.toInt(), oElement.toInt());
            }
          );
        }
      );
      parseDualArray<CodeDraw>(itBoosterRef.current.cardDrawing!.drawEnergies, booster.cardDrawing!.drawEnergies,
        (mElement, oElement) {
          expect(mElement.toInt(), oElement.toInt());
        }
      );
    });
  }

  test('UserDrawFile', () async {
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

    Map<int, ProductBooster> boosters = {};
    boosters[se.id] = ProductBooster(nbBoosters: 1, nbCardsPerBooster: 3);
    var p = Product(idDB: 1, name: "DemoProduct", imageURL: "None", boosters: boosters);

    Map languages      = { l.id: l };
    Map products       = { p.idDB: p };
    Map subExtensions  = { se.id: se };

    ExtensionDrawCards edc = ExtensionDrawCards.fromSubExtension(se);
    edc.drawCards[0][0].countBySet[0] = 2;
    edc.drawCards[0][0].countBySet[1] = 3;
    edc.drawCards[0][1].countBySet[0] = 1;
    edc.drawCards[2][0].countBySet[0] = 4;
    edc.drawCards[2][0].countBySet[1] = 0;

    edc.drawEnergies[0].countBySet[0] = 3;
    edc.drawEnergies[0].countBySet[1] = 2;
    edc.drawEnergies[2].countBySet[0] = 1;

    SessionDraw sd = SessionDraw(p, l, subExtensions);
    sd.boosterDraws[0].fill(se, true, edc);

    var collection = UserDrawCollection();
    await collection.readCollection();
    if(collection.collection.isNotEmpty) {
      collection.collection.forEach((element) {
        element.remove();
      });
      await collection.readCollection();
    }
    expect(0, collection.collection.length, reason: "Start condition is not ready");

    String savedFile = [(await UserDrawCollection.folder()).path, "demo.bin"].join(Platform.pathSeparator);
    UserDrawFile udf = UserDrawFile(savedFile);
    await udf.save(sd);

    // Check file exists
    await collection.readCollection();
    expect(1, collection.collection.length, reason: "File doesn't exist into collection folder");

    // Read file
    UserDrawFile readUdf = UserDrawFile(savedFile);
    SessionDraw sdRead = await readUdf.read(languages, products, subExtensions);

    compare(sd, sdRead);

    // Delete file
    udf.remove();
    await collection.readCollection();
    expect(0, collection.collection.length, reason: "File still exists into collection folder");
  });
}
