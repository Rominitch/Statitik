import 'package:statitikcard/services/Draw/SessionDraw.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/product.dart';

/// All information about product draw (randomize card)
class ProductDraw {
  SessionDraw? session;
  int count = 0;
  Map<ProductCard, CodeDraw> randomProductCard = {};

  ProductDraw.empty();

  ProductDraw(this.session, [ByteParser? parser]) {
    randomProductCard.clear();
    session!.product.otherCards.forEach((productCard) {
      if(productCard.isRandom) {
        randomProductCard[productCard] = CodeDraw.fromSet(productCard.card.sets.length);
      }
    });

    if(parser != null) {
      var itRandom = randomProductCard.entries.iterator;
      var nbCard = parser.extractInt8();
      for(int id=0; id < nbCard; id +=1) {
        if(itRandom.moveNext()) {
          var code = parser.extractInt8();
          itRandom.current.value.setCode(code);
          count += itRandom.current.value.count();
        }
      }
      assert(count <= session!.product.nbRandomPerProduct || session!.productAnomaly);
    }
  }

  List<int> toBytes() {
    List<int> bytes = [];

    bytes += ByteEncoder.encodeInt8(randomProductCard.length);
    randomProductCard.forEach((key, value) {
      bytes += ByteEncoder.encodeInt8(value.toInt()); // Save 7 card per sets
    });

    return bytes;
  }

  bool canAdd() {
    assert(session != null);
    return count < session!.product.nbRandomPerProduct || session!.productAnomaly;
  }

  void increase(ProductCard card, int idSet) {
    if(canAdd()) {
      if(randomProductCard[card]!.increase(idSet, 7)) {
        count += 1;
      }
    }
  }

  void decrease(ProductCard card, int idSet) {
    if(randomProductCard[card]!.decrease(idSet)) {
      count -= 1;
    }
  }

  void setOnly(ProductCard card, int idSet) {
    count -= randomProductCard[card]!.count();
    randomProductCard[card]!.reset();
    increase(card, idSet);
  }

  void toggle(ProductCard card, int idSet) {
    var nb = randomProductCard[card]!.count();
    if(nb == 0) {
      increase(card, idSet);
    } else {
      count -= nb;
      randomProductCard[card]!.reset();
    }
  }
}