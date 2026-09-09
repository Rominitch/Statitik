import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/products/poke_product_card.dart';
import 'package:statitikcard/models/report/poke_new_card_report.dart';
import 'package:statitikcard/services/environment.dart';

class PokeUserCardCounter
{
  PokeLanguage              language;
  PokeExpansion            expansion;
  List<List<PokeCardDraw>> cards     = [];
  List<PokeCardDraw>       energies  = [];
  List<PokeCardDraw>       noNumbers = [];

  //StatsCardUser        statsCards = StatsCardUser();

  // Stats part
  PokeUserCardCounter.fromExpansion({required this.language, required this.expansion}) {
    cards = List<List<PokeCardDraw>>.generate(expansion.cards.cards.length, (index) {
      return List<PokeCardDraw>.generate(expansion.cards.cards[index].length, (subIndex) {
        return PokeCardDraw.fromPokeCardExtension(expansion.cards.cards[index][subIndex]);
      });
    });

    energies = List<PokeCardDraw>.generate(expansion.cards.energyCard.length, (index) {
      return PokeCardDraw.fromPokeCardExtension(expansion.cards.energyCard[index]);
    });

    noNumbers = List<PokeCardDraw>.generate(expansion.cards.noNumberedCard.length, (index) {
      return PokeCardDraw.fromPokeCardExtension(expansion.cards.noNumberedCard[index]);
    });
  }
/*
  void fromByte(ByteParser parser) {
    int countCards = parser.extractInt16();
    for(var idCards = 0; idCards < countCards; idCards += 1) {
      int countSub  = parser.extractInt8();
      for(var idSubCards = 0; idSubCards < countSub; idSubCards += 1) {
        var code = CodeDraw.fromBytes(parser);
        // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
        if(idCards < cards.length && idSubCards < cards[idCards].length) {
          cards[idCards][idSubCards].add(code);
        }
      }
    }

    var countECards = parser.extractInt16();
    for(var idCards = 0; idCards < countECards; idCards += 1) {
      var code = CodeDraw.fromBytes(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < energies.length ) {
        energies[idCards].add(code);
      }
    }

    var countNCards = parser.extractInt16();
    for(var idCards = 0; idCards < countNCards; idCards += 1) {
      var code = CodeDraw.fromBytes(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < noNumbers.length ) {
        noNumbers[idCards].add(code);
      }
    }
  }

  void fromByteV1(ByteParser parser) {
    int countCards = parser.extractInt16();
    for(var idCards = 0; idCards < countCards; idCards += 1) {
      int countSub  = parser.extractInt8();
      for(var idSubCards = 0; idSubCards < countSub; idSubCards += 1) {
        var code = CodeDraw.fromBytesV1(parser);
        // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
        if(idCards < cards.length && idSubCards < cards[idCards].length) {
          cards[idCards][idSubCards].add(code);
        }
      }
    }

    var countECards = parser.extractInt16();
    for(var idCards = 0; idCards < countECards; idCards += 1) {
      var code = CodeDraw.fromBytesV1(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < energies.length ) {
        energies[idCards].add(code);
      }
    }

    var countNCards = parser.extractInt16();
    for(var idCards = 0; idCards < countNCards; idCards += 1) {
      var code = CodeDraw.fromBytesV1(parser);
      // Try to save into SubExtension (WARNING: NO guaranty of same size !!!)
      if(idCards < noNumbers.length ) {
        noNumbers[idCards].add(code);
      }
    }
  }

  List<int> toBytes() {
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt16(cards.length);
    for (var subCard in cards) {
      bytes += ByteEncoder.encodeInt8(subCard.length);
      for (var code in subCard) {
        bytes += code.toBytes();
      }
    }

    bytes += ByteEncoder.encodeInt16(energies.length);
    for (var code in energies) {
      bytes += code.toBytes();
    }

    bytes += ByteEncoder.encodeInt16(noNumbers.length);
    for (var code in noNumbers) {
      bytes += code.toBytes();
    }
    return bytes;
  }

  void computeStats() {
    statsCards.computeStats(expansion, cards);
  }

  void add(ExtensionDrawCards edc, [PokeNewCardsReport? report]) {
    int idCard = 0;
    var subCard = cards.iterator;
    for (var element in edc.drawCards) {
      if(subCard.moveNext()) {
        addList(expansion, element, subCard.current, [0, idCard], report);
        idCard += 1;
      }
    }

    addList(expansion, edc.drawEnergies, energies, [1], report);
  }
*/
  void addRandomCard(PokeProductCard card, PokeCardDraw counter, [PokeNewCardsReport? report]) {
    var idCard = card.expansion.cards.computeIdCard(card.card())!;

    PokeCardDraw? code;
    switch(idCard.listId) {
      case 0:
        code = cards[idCard.numberId][idCard.alternativeId].add(counter);
        break;
      case 1:
        code = energies[idCard.numberId].add(counter);
        break;
      case 2:
        code = noNumbers[idCard.numberId].add(counter);
        break;
      default:
        throw StatitikException(ErrorCode.unknown, "Missing list !");
    }
    if(code != null && report!= null) {
      report.add(card.expansion, PokeNewCardReport(idCard, code));
    }
  }

  void addList(PokeExpansion se, List<PokeCardDraw> from, List<PokeCardDraw> to, List<int> listId, [PokeNewCardsReport? report]) {
    int idCard = 0;
    var dstCode = to.iterator;
    for (var cardCode in from) {
      if(dstCode.moveNext()) {
        var code = dstCode.current.add(cardCode);
        if(code != null && report!= null) {
          report.add(se, PokeNewCardReport(PokeCardIdentifier.from(listId + [idCard]), code));
        }
        idCard +=1;
      }
    }
  }

  PokeNewCardReport? addProductCard(PokeProductCard productCard, [int mulFactor=1]) {
    assert(productCard.expansion == expansion);
    if( !productCard.isRandom ) {
      PokeCardDraw? report;
      var idCards = expansion.cards.computeIdCard(productCard.card())!;
      switch(idCards.listId) {
        case 0:
          if (idCards.numberId < cards.length &&
              idCards.alternativeId < cards[idCards.numberId].length) {
            report = cards[idCards.numberId][idCards.alternativeId].add(
                productCard.counter, mulFactor);
          }
          break;
        case 1:
          if (idCards.numberId < energies.length) {
            report = energies[idCards.numberId].add(productCard.counter, mulFactor);
          }
          break;
        case 2:
          if (idCards.numberId < noNumbers.length) {
            report = noNumbers[idCards.numberId].add(productCard.counter, mulFactor);
          }
          break;
        default:
          throw StatitikException(ErrorCode.unknown, "Unknown List");
      }
      return (report != null) ? PokeNewCardReport(idCards, report) : null;
    }
    return null;
  }
}