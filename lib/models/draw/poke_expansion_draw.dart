import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/services/environment.dart';

class PokeExpansionDraw {
  late List<List<PokeCardDraw>> drawCards;
  late List<PokeCardDraw>       drawEnergies;   ///< Energy inside booster.
  late List<PokeCardDraw>       drawNoNumber;   ///< No Number inside booster.

  static const int version = 5; // Warning: Limited to 256

  PokeExpansionDraw.fromSubExtension(PokeExpansion subExtension) {
    var allCardsSE = subExtension.cards.cards;
    drawCards = List<List<PokeCardDraw>>.generate(allCardsSE.length, (index) {
      var cardForNumber = allCardsSE[index];
      return List<PokeCardDraw>.generate(cardForNumber.length, (subIndex) {
        return PokeCardDraw.fromPokeCardExtension(cardForNumber[subIndex]);
      });
    });

    var energiesCards = subExtension.cards.energyCard;
    drawEnergies = List<PokeCardDraw>.generate(energiesCards.length, (index) {
      return PokeCardDraw.fromPokeCardExtension(energiesCards[index]);
    });

    var noNumberCards = subExtension.cards.noNumberedCard;
    drawNoNumber = List<PokeCardDraw>.generate(noNumberCards.length, (index) {
      return PokeCardDraw.fromPokeCardExtension(noNumberCards[index]);
    });
  }
/*
  ExtensionDrawCards.fromBytes(SubExtension subExtension, List<int> zipBytes) {
    drawCards    = [];
    drawEnergies = [];
    drawNoNumber = [];

    int currentVersion = zipBytes[0];
    if(currentVersion == 5) {
      _fromBytesV5(subExtension, zipBytes);
    } else if(currentVersion == 4) {
      _fromBytesV4(subExtension, zipBytes);
    } else {
      throw StatitikException("ExtensionDrawCards need migration !");
    }
  }

  ByteParser _fromBytesV5(SubExtension subExtension, List<int> zipBytes) {
    ByteParser parser = _fromBytesV4(subExtension, zipBytes);

    // Extract No number card
    var noNumberCardList = subExtension.seCards.noNumberedCard.iterator;
    int nbNoNumberCards = parser.extractInt16();
    for(int id=0; id < nbNoNumberCards; id +=1) {
      var code = parser.extractInt8();
      if(noNumberCardList.moveNext()) {
        drawNoNumber.add(CodeDraw.fromPokeCardExtension(noNumberCardList.current, code));
      } else {
        printOutput("Error into User CardDrawData: More nonumber cards");
        break;
      }
    }
    return parser;
  }

  ByteParser _fromBytesV4(SubExtension subExtension, List<int> zipBytes) {
    List<int> bytes = gzip.decode(zipBytes.sublist(1));
    var parser = ByteParser(bytes);
    var cardsList = subExtension.seCards.cards.iterator;

    int nbCards = parser.extractInt16();
    for(int id=0; id < nbCards; id +=1) {
      if(cardsList.moveNext()) {
        int count = parser.extractInt8();
        List<CodeDraw> cardCode = [];
        var cardEx = cardsList.current.iterator;
        for (int idCard = 0; idCard < count; idCard += 1) {
          var code = parser.extractInt8();
          if (!cardEx.moveNext()) {
            throw StatitikException("Unknown Card");
          }
          cardCode.add(CodeDraw.fromPokeCardExtension(cardEx.current, code));
        }
        assert(cardCode.isNotEmpty);
        drawCards.add(cardCode);
      } else {
        printOutput("Error into User CardDrawData: More cards");
        break;
      }
    }

    // Extract Energy card
    var energiesList = subExtension.seCards.energyCard.iterator;
    int nbEnergiesCards = parser.extractInt16();
    for(int id=0; id < nbEnergiesCards; id +=1) {
      var code = parser.extractInt8();
      if(energiesList.moveNext()) {
        drawEnergies.add(
            CodeDraw.fromPokeCardExtension(energiesList.current, code));
      } else {
        printOutput("Error into User CardDrawData: More energy");
        break;
      }
    }
    return parser;
  }
*/
  /// Fill current draw with another (generally full Subextension with saved and truncate data)
  int fillWith(PokeExpansionDraw savedData) {
    int count = 0;

    var itCurrent = drawCards.iterator;

    for (var saveCards in savedData.drawCards) {
      if(!itCurrent.moveNext()) {
        throw StatitikException(ErrorCode.unknown, "ExtensionDrawCards - draw Data corruption : more cards into Expansion than expected ${drawCards.length} < ${savedData.drawCards.length}!");
      }
      var itCard = itCurrent.current.iterator;
      for (var card in saveCards) {
        if(!itCard.moveNext()) {
          throw StatitikException(ErrorCode.unknown, "ExtensionDrawCards - draw Data corruption : more card than expected !");
        }
        // Copy data
        itCard.current.copy(card);

        count += card.count();
      }
    }

    var energyIt = drawEnergies.iterator;
    for (var drawEnergy in savedData.drawEnergies) {
      if(!energyIt.moveNext()) {
        throw StatitikException(ErrorCode.unknown, "ExtensionDrawCards - draw Energy Data corruption : more cards into Expansion than expected ${drawEnergies.length} < ${savedData.drawEnergies.length}!");
      }

      energyIt.current.copy(drawEnergy);
      count += drawEnergy.count();
    }

    var noNumberIt = drawNoNumber.iterator;
    for (var draw in savedData.drawNoNumber) {
      if(!noNumberIt.moveNext()) {
        throw StatitikException(ErrorCode.unknown, "ExtensionDrawCards - draw no number Data corruption : more cards into Expansion than expected ${drawNoNumber.length} < ${savedData.drawNoNumber.length}!");
      }

      noNumberIt.current.copy(draw);
      count += draw.count();
    }

    return count;
  }
/*
  /// Remove all empty code to reduce memory size
  List<int> toBytes() {
    // Clean code to minimal binary data
    List<List<int>> allCardsCodes = [];
    for (var codeCards in drawCards) {
      List<int> localCard = [];
      for (var card in codeCards) { localCard.add(card.toInt()); }
      allCardsCodes.add(localCard);
    }
    // Parse and Clear empty
    while(allCardsCodes.isNotEmpty) {
      int count=0;
      for (var element in allCardsCodes.last) { count += element; }
      if(count == 0) {
        allCardsCodes.removeLast();
      } else {
        break;
      }
    }
    int validEnergy = drawEnergies.length;
    if(drawEnergies.isNotEmpty) {
      for(var element in drawEnergies.reversed) {
        if(element.count() > 0) {
          break;
        } else {
          validEnergy -= 1;
        }
      }
    }
    int validNoNumber = drawNoNumber.length;
    if(drawNoNumber.isNotEmpty) {
      for(var element in drawNoNumber.reversed) {
        if(element.count() > 0) {
          break;
        } else {
          validNoNumber -= 1;
        }
      }
    }

    // Build binary data
    List<int> bytes = ByteEncoder.encodeInt16(allCardsCodes.length);
    for (var cards in allCardsCodes) {
      bytes.add(cards.length);
      for (var code in cards) { bytes.add(code);}
    }
    // Make for energies
    bytes += ByteEncoder.encodeInt16(validEnergy);
    drawEnergies.sublist(0, validEnergy).forEach((element) {
      bytes.add(element.toInt());
    });
    // Make for no Number
    bytes += ByteEncoder.encodeInt16(validNoNumber);
    drawNoNumber.sublist(0, validNoNumber).forEach((element) {
      bytes.add(element.toInt());
    });

    // Final data
    List<int> finalBytes = [version];
    finalBytes += gzip.encode(bytes);

    printOutput("ExtensionDrawCards: data: ${bytes.length+1} compressed: ${finalBytes.length}");
    return finalBytes;
  }
  */
}