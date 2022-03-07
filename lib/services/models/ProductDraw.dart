import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/models/product.dart';

/// All information about product draw (randomize card)
class ProductDraw {
  Product? product;
  int count = 0;
  Map<ProductCard, CodeDraw> randomProductCard = {};

  ProductDraw.empty();

  ProductDraw(this.product) {
    randomProductCard.clear();
    product!.otherCards.forEach((productCard) {
      if(productCard.isRandom) {
        randomProductCard[productCard] = CodeDraw.fromSet(productCard.card.sets.length);
      }
    });
  }

  bool canAdd() {
    assert(product != null);
    return count < product!.nbRandomPerProduct;
  }

  void increase(ProductCard card, int idSet) {
    if(canAdd()) {
      if(randomProductCard[card]!.countBySet[idSet] < 7) {
        randomProductCard[card]!.countBySet[idSet] += 1;
        count += 1;
      }
    }
  }

  void decrease(ProductCard card, int idSet) {
    if(canAdd()) {
      if(randomProductCard[card]!.countBySet[idSet] > 0) {
        randomProductCard[card]!.countBySet[idSet] -= 1;
        count -= 1;
      }
    }
  }

  void setOnly(ProductCard card, int idSet) {
    count -= randomProductCard[card]!.count();
    randomProductCard[card]!.reset();
    increase(card, idSet);
  }

  void toggle(ProductCard card, int idSet) {
    var nb = randomProductCard[card]!.count();
    if(nb == 0)
      increase(card, idSet);
    else
      randomProductCard[card]!.reset();
  }
}