
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/pokemonCard.dart';

void main() {
  void parseDualArray<T>(List<T> main, List<T> other, Function(T mElement, T oElement) parser) {
    expect(main.length, other.length);
    var itOther = other.iterator;
    main.forEach((element) {
      itOther.moveNext();
      parser(element, itOther.current);
    });
  }

  void parseDualMap<T, T1>(Map<T, T1> main, Map<T, T1> other, Function(T mKey, T1 mElement, T oKey, T1 oElement) parser) {
    expect(main.length, other.length);
    var itOther = other.keys.iterator;
    main.forEach((key, element) {
      itOther.moveNext();
      parser(key, element, itOther.current, other[itOther.current]!);
    });
  }

  test('Product.Bytes', () async {
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

    var se = SubExtension(1, "Demo", "D", ex, DateTime.now(), seCard, SerieType.Normal, ["D"], 10 );

    Map subExts = {1: se };
    Map sideProduct = {
      1: ProductSide(1, c, "SP1", "SP1", DateTime.now()),
      2: ProductSide(2, c, "SP2", "SP2", DateTime.now()),
    };

    var idP  = 1;
    var prodL= l;
    var name ="DemoProduct";
    var img  = "None";
    var date = DateTime.now();
    var cat  = c;

    List<ProductBooster> boosters = [ProductBooster(se, 1, 3)];
    var p = Product(idP, prodL, name, img, date, cat, boosters);
    p.sideProducts[sideProduct[1]] = 1;
    p.sideProducts[sideProduct[2]] = 5;
    var code = CodeDraw.fromSet(2);
    code.countBySet[0] = 1;
    p.otherCards.add(ProductCard(se, cards[1], AlternativeDesign.Basic, false, code));

    var newP = Product.fromBytes(idP, prodL, name, img, date, cat,
        p.toBytes(), subExts, sideProduct);

    expect(p.boosters.length,     newP.boosters.length);
    parseDualArray<ProductBooster>(p.boosters, newP.boosters, (ref, booster){
      expect(ref.subExtension,      booster.subExtension);
      expect(ref.nbCardsPerBooster, booster.nbCardsPerBooster);
      expect(ref.nbBoosters,        booster.nbBoosters);
    });

    expect(p.sideProducts.length, newP.sideProducts.length);
    parseDualMap<ProductSide, int>(p.sideProducts, newP.sideProducts, (rBooster, rCount, booster, count){
      expect(rBooster,  booster);
      expect(rCount,    count);
    });

    expect(p.otherCards.length,   newP.otherCards.length);
    parseDualArray<ProductCard>(p.otherCards, newP.otherCards, (ref, card){
      expect(ref.card,  card.card);
      expect(ref.design,  card.design);
      expect(ref.jumbo,  card.jumbo);
      expect(ref.subExtension,  card.subExtension);
      expect(ref.counter.countBySet[0], card.counter.countBySet[0]);
    });
  });

  test('filter', () async {
    var languages  = [
      Language(id: 1, image: "FR"),
      Language(id: 2, image: "EN"),
    ];

    var categories = [
      ProductCategory(1, MultiLanguageString(["C1", "C", "C"]), true),
      ProductCategory(2, MultiLanguageString(["C2", "C", "C"]), true),
      ProductCategory(3, MultiLanguageString(["C3", "C", "C"]), true),
    ];

    var extension = [
      Extension(0, "Ex FR", languages[0]),
      Extension(1, "Ex EN", languages[1]),
    ];
    Map cards = {
      0: PokemonCardExtension.empty(PokemonCardData.empty(), Rarity.fromText(0, MultiLanguageString(["S0","S0","S0"]), Colors.green)),
    };

    var refTime = DateTime.now();
    var seCard = SubExtensionCards([[cards[0]]], [], 0);
    var se = [
      SubExtension(1, "S1 FR", "D", extension[0], refTime, seCard, SerieType.Normal, ["D"], 10 ),
      SubExtension(2, "S2 FR", "D", extension[0], refTime, seCard, SerieType.Normal, ["D"], 10 ),
      SubExtension(3, "S1 EN", "D", extension[1], refTime, seCard, SerieType.Normal, ["D"], 10 ),
    ];

    {
      List<ProductBooster> boosters = [ProductBooster(se[0], 1, 3)];
      var p0 = Product(1, languages[0], "A", "", refTime, categories[0], boosters);
      var p1 = Product(2, languages[1], "A", "", refTime, categories[1], boosters);
      // Mandatory filter
      expect(true,  filter(p0, languages[0], se[0], null, {}));
      expect(false, filter(p0, languages[0], se[1], null, {}));
      expect(false, filter(p0, languages[1], se[0], null, {}));

      // Optional: Category
      expect(true,  filter(p0, languages[0], se[0], categories[0], {}));
      expect(false, filter(p0, languages[0], se[0], categories[1], {}));
      expect(false, filter(p0, languages[1], se[1], categories[1], {}));

      // Optional: User
      Map<Product, List<SubExtension>> selection1 = { p0: [se[0]], p1: [se[0]] };
      expect(true,  filter(p0, languages[0], se[0], null,          selection1));
      expect(true,  filter(p0, languages[0], se[0], categories[0], selection1));

      Map<Product, List<SubExtension>> selection2 = { p1: [se[0]] };
      expect(false,  filter(p0, languages[0], se[0], null,         selection2));
  }

    // Random booster
    {
      var afterTime = refTime.add(Duration(days: 1));
      var random1 = Product(1, languages[0], "A", "", afterTime, categories[0], [ProductBooster(null, 1, 3)]);
      var random2 = Product(2, languages[0], "A", "", afterTime, categories[0], [ProductBooster(null, 1, 3)]);
      // Mandatory filter
      expect(true,  filter(random1, languages[0], se[0], null, {}, onlyShowRandom: true));
      expect(true,  filter(random1, languages[0], se[1], null, {}, onlyShowRandom: true));
      expect(false, filter(random1, languages[1], se[0], null, {}, onlyShowRandom: true));

      var beforeTime = refTime.add(Duration(days: -1));
      var random3 = Product(1, languages[0], "A", "", beforeTime, categories[0], [ProductBooster(null, 1, 3)]);
      expect(false, filter(random3, languages[0], se[0], null, {}, onlyShowRandom: true));
      expect(false, filter(random3, languages[0], se[1], null, {}, onlyShowRandom: true));
      expect(false, filter(random3, languages[1], se[0], null, {}, onlyShowRandom: true));

      // Optional: Category
      expect(true,  filter(random1, languages[0], se[0], categories[0], {}, onlyShowRandom: true));
      expect(false, filter(random1, languages[0], se[0], categories[1], {}, onlyShowRandom: true));
      expect(false, filter(random1, languages[1], se[1], categories[0], {}, onlyShowRandom: true));
      expect(true,  filter(random1, languages[0], se[0], categories[0], {}, onlyShowRandom: true));

      // Optional: User
      Map<Product, List<SubExtension>> selection1 = { random1: [se[0], se[1]] };
      expect(true,  filter(random1, languages[0], se[0], null,          selection1, onlyShowRandom: true));
      expect(true,  filter(random1, languages[0], se[0], categories[0], selection1, onlyShowRandom: true));

      Map<Product, List<SubExtension>> selection2 = { random1: [se[1]] };
      expect(false,  filter(random1, languages[0], se[0], null,         selection2, onlyShowRandom: true));

      Map<Product, List<SubExtension>> selection3 = { random2: [se[0]] };
      expect(false,  filter(random1, languages[0], se[0], null,         selection3, onlyShowRandom: true));
    }
  });
}