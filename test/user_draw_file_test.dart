import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/draw/session_draw.dart';
import 'package:statitikcard/services/models/card_set.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/user_draw_file.dart';
import 'package:statitikcard/services/models/extension.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/models/serie_type.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/sub_extension_cards.dart';
import 'package:statitikcard/services/models/product.dart';

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
    var c  = ProductCategory(1, MultiLanguageString(["C","C", "C"]), true);
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

    var seCard = SubExtensionCards([[card[0], card[1]], [card[1]], [card[0]]], [], 0);
    seCard.energyCard.add(card[0]);
    seCard.energyCard.add(card[0]);
    seCard.energyCard.add(card[1]);

    var se = SubExtension(1, "Demo", "D", ex, DateTime.now(), seCard, SerieType.normal, ["D"], 10 );

    List<ProductBooster> boosters = [ProductBooster(se, 1, 3)];
    var p = Product(1, l, "DemoProduct", "None", DateTime.now(), c, boosters);

    Map languages      = { l.id: l };
    Map products       = { p.idDB: p };
    Map subExtensions  = { se.id: se };

    ExtensionDrawCards edc = ExtensionDrawCards.fromSubExtension(se);
    edc.drawCards[0][0].setCount(2, 0);
    edc.drawCards[0][0].setCount(3, 1);
    edc.drawCards[0][1].setCount(1, 0);
    edc.drawCards[2][0].setCount(4, 0);
    edc.drawCards[2][0].setCount(0, 1);

    edc.drawEnergies[0].setCount(3, 0);
    edc.drawEnergies[0].setCount(2, 1);
    edc.drawEnergies[2].setCount(1, 0);

    SessionDraw sd = SessionDraw(p, l);
    sd.boosterDraws[0].fill(se, true, edc);

    var savedDraws = await UserDrawCollection.readSavedDraws();
    if(savedDraws.isNotEmpty) {
      savedDraws.forEach((element) {
        element.remove();
      });
      await UserDrawCollection.readSavedDraws();
    }
    expect(0, savedDraws.length, reason: "Start condition is not ready");

    String savedFile = [(await UserDrawCollection.folder()).path, "demo.bin"].join(Platform.pathSeparator);
    UserDrawFile udf = UserDrawFile(savedFile);
    await udf.save(sd);

    // Check file exists
    savedDraws = await UserDrawCollection.readSavedDraws();
    expect(1, savedDraws.length, reason: "File doesn't exist into collection folder");

    // Read file
    UserDrawFile readUdf = UserDrawFile(savedFile);
    SessionDraw sdRead = await readUdf.read(languages, products, subExtensions);

    compare(sd, sdRead);

    // Delete file
    udf.remove();
    savedDraws = await UserDrawCollection.readSavedDraws();
    expect(0, savedDraws.length, reason: "File still exists into collection folder");
  });
}
