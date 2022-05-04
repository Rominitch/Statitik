
import 'package:flutter/foundation.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';

class CardIdentifier {
  List<int> cardId;

  CardIdentifier.from(this.cardId) {
    assert(cardId.length >= 2);
  }

  CardIdentifier.copy(CardIdentifier idCard) :
    this.cardId = List<int>.generate(idCard.cardId.length, (index) => idCard.cardId[index]){
    assert(cardId.length >= 2);
  }

  CardIdentifier.fromBytes(ByteParser parser) : this.cardId = []{
    cardId = [parser.extractInt8(), parser.extractInt16()];
    if(cardId[0] == 0)
      cardId.add(parser.extractInt8());
  }

  int get alternativeId {
    assert(cardId.length >= 3);
    return cardId[2];
  }
  int get numberId {
    return cardId[1];
  }
  int get listId {
    return cardId[0];
  }

  String toString() {
    return "${cardId.join("_")}";
  }

  int compareTo(CardIdentifier other) {
    var itOther = other.cardId.iterator;
    for(var element in cardId) {
      if(itOther.moveNext()) {
        var cmp = element.compareTo(itOther.current);
        if(cmp != 0)
          return cmp;
      }
    }
    return 0;
  }

  bool isEqual(other) => listEquals(cardId, other.cardId);

  List<int> toBytes() {
    List<int> bytes = ByteEncoder.encodeInt8(listId);
    bytes += ByteEncoder.encodeInt16(numberId);
    if(cardId.length > 2)
      bytes += ByteEncoder.encodeInt8(alternativeId);
    return bytes;
  }

  CardIdentifier changeNumber(int position) {
    var newId = List<int>.from(cardId, growable: false);
    newId[1] = position;
    return CardIdentifier.from(newId);
  }
}

class CardImageIdentifier {
  int idSet;
  int idImage;

  CardImageIdentifier([this.idSet=0, this.idImage=0]);

  String toString() {
    return "${idSet}_$idImage";
  }
}