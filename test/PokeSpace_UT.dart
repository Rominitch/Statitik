import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

import 'TestTools.dart';

void main() {
  test('PokeSpace', () async {
    var l  = Language(id: 1, image: "FR");
    var c  = ProductCategory(1, MultiLanguageString(["C","C", "C"]), true);
    var ex = Extension(0, "Ex", l);
    var r  = Rarity.fromText(0, MultiLanguageString(["S0","S0","S0"]), Colors.green);
    var defaultCard = PokemonCardData.empty();
    var sets = [
      CardSet(MultiLanguageString(["S0","S0","S0"]), Colors.green, "normal"),
      CardSet(MultiLanguageString(["S1","S1","S1"]), Colors.blue, "normal"),
    ];
    Map cards = {
      0: PokemonCardExtension.empty(defaultCard, r),
      1: PokemonCardExtension.empty(defaultCard, r)
    };
    cards[0].sets.add(sets[0]);
    cards[0].sets.add(sets[1]);
    cards[1].sets.add(sets[0]);

    var seCard = SubExtensionCards([[cards[0], cards[1]], [cards[1]], [cards[0]]], [], 0);
    seCard.energyCard.add(cards[0]);
    seCard.energyCard.add(cards[0]);
    seCard.energyCard.add(cards[1]);

    Map subExtensions = {
      1: SubExtension(1, "SE1", "D", ex, DateTime.now(), seCard, SerieType.Normal, ["D"], 10 ),
      2: SubExtension(2, "SE2", "D", ex, DateTime.now(), seCard, SerieType.Normal, ["D"], 10 ),
    };

    Map sideProducts = {
      1: ProductSide(1, c, "SP1", "SP1", DateTime.now()),
      2: ProductSide(2, c, "SP2", "SP2", DateTime.now()),
    };

    var date = DateTime.now();

    Map products = {
      1: Product(1, l, "P1", "P1", date, c, [ProductBooster(subExtensions[1], 1, 3)]),
      2: Product(2, l, "P2", "P2", date, c, [ProductBooster(subExtensions[1], 1, 3)]),
    };
    var space    = PokeSpace();
    space.insertProduct(products[2], UserProductCounter.fromOpened(1));
    space.insertSideProduct(sideProducts[1], UserProductCounter.fromOpened(4));
    space.insertSideProduct(sideProducts[2], UserProductCounter.fromOpened(5));

    space.insertSubExtension(subExtensions[1]);
    space.myCards[subExtensions[1]]!.cards[0][0].countBySet[1] = 3;
    space.myCards[subExtensions[1]]!.cards[1][0].countBySet[0] = 2;
    space.insertSubExtension(subExtensions[2]);
    space.myCards[subExtensions[2]]!.cards[1][0].countBySet[0] = 4;

    // Save and restore
    var newSpace = PokeSpace.fromBytes(space.toBytes(), subExtensions, products, sideProducts);

    parseDualMap<SubExtension, UserCardCounter>(space.myCards, newSpace.myCards, (mKey, mElement, oKey, oElement) {
      expect(mKey, oKey);

      parseDualArray<List<CodeDraw>>(mElement.cards, oElement.cards, (mElement, oElement){
        parseDualArray<CodeDraw>(mElement, oElement, (mElement, oElement) {
          parseDualArray<int>(mElement.countBySet, oElement.countBySet, (mElement, oElement) {
            expect(mElement, oElement);
          });
        });
      });
      parseDualArray<CodeDraw>(mElement.energies, oElement.energies, (mElement, oElement) {
        parseDualArray<int>(mElement.countBySet, oElement.countBySet, (mElement, oElement) {
          expect(mElement, oElement);
        });
      });
      parseDualArray<CodeDraw>(mElement.noNumbers, oElement.noNumbers, (mElement, oElement) {
        parseDualArray<int>(mElement.countBySet, oElement.countBySet, (mElement, oElement) {
          expect(mElement, oElement);
        });
      });
    });

    parseDualMap<Product, UserProductCounter>(space.myProducts, newSpace.myProducts, (mKey, mElement, oKey, oElement) {
      expect(mKey, oKey);
      expect(mElement.opened, oElement.opened);
      expect(mElement.seal,   oElement.seal);
    });

    parseDualMap<ProductSide, UserProductCounter>(space.mySideProducts, newSpace.mySideProducts, (mKey, mElement, oKey, oElement) {
      expect(mKey, oKey);
      expect(mElement.opened, oElement.opened);
      expect(mElement.seal,   oElement.seal);
    });
  });
}