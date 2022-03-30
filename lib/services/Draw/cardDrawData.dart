import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class ExtensionDrawCards {
  late List<List<CodeDraw>> drawCards;
  late List<CodeDraw>       drawEnergies;   ///< Energy inside booster.
  late List<CodeDraw>       drawNoNumber;   ///< No Number inside booster.

  static const int version = 5; // Warning: Limited to 256

  ExtensionDrawCards.fromSubExtension(SubExtension subExtension) {
    var allCardsSE = subExtension.seCards.cards;
    drawCards = List<List<CodeDraw>>.generate(allCardsSE.length, (index) {
      var cardForNumber = allCardsSE[index];
      return List<CodeDraw>.generate(cardForNumber.length, (subIndex) {
        return CodeDraw.fromSet(cardForNumber[subIndex].sets.length);
      });
    });

    var energiesCards = subExtension.seCards.energyCard;
    drawEnergies = List<CodeDraw>.generate(energiesCards.length, (index) {
      return CodeDraw.fromSet(energiesCards[index].sets.length);
    });

    var noNumberCards = subExtension.seCards.noNumberedCard;
    drawNoNumber = List<CodeDraw>.generate(noNumberCards.length, (index) {
      return CodeDraw.fromSet(noNumberCards[index].sets.length);
    });
  }

  ExtensionDrawCards.fromBytes(SubExtension subExtension, List<int> zipBytes) {
    this.drawCards    = [];
    this.drawEnergies = [];
    this.drawNoNumber = [];

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
      if(!noNumberCardList.moveNext())
        throw StatitikException("Unknown Card");
      drawNoNumber.add(CodeDraw.fromSet(noNumberCardList.current.sets.length, code));
    }
    return parser;
  }

  ByteParser _fromBytesV4(SubExtension subExtension, List<int> zipBytes) {
    List<int> bytes = gzip.decode(zipBytes.sublist(1));
    var parser = ByteParser(bytes);
    var cardsList = subExtension.seCards.cards.iterator;

    int nbCards = parser.extractInt16();
    for(int id=0; id < nbCards; id +=1) {
      if(!cardsList.moveNext())
        throw StatitikException("Unknown Cards");

      int count = parser.extractInt8();
      List<CodeDraw> cardCode = [];
      var cardEx = cardsList.current.iterator;
      for(int idCard=0; idCard < count; idCard +=1) {
        var code = parser.extractInt8();
        if(!cardEx.moveNext())
          throw StatitikException("Unknown Card");
        cardCode.add(CodeDraw.fromSet(cardEx.current.sets.length, code));
      }
      assert(cardCode.isNotEmpty);
      drawCards.add(cardCode);
    }

    // Extract Energy card
    var energiesList = subExtension.seCards.energyCard.iterator;
    int nbEnergiesCards = parser.extractInt16();
    for(int id=0; id < nbEnergiesCards; id +=1) {
      var code = parser.extractInt8();
      if(!energiesList.moveNext())
        throw StatitikException("Unknown Card");
      drawEnergies.add(CodeDraw.fromSet(energiesList.current.sets.length, code));
    }
    return parser;
  }

  /// Fill current draw with another (generally full Subextension with saved and truncate data)
  int fillWith(ExtensionDrawCards savedData) {
    int count = 0;

    var itCurrent = drawCards.iterator;

    savedData.drawCards.forEach((saveCards) {
      if(!itCurrent.moveNext())
        throw StatitikException("ExtensionDrawCards - Draw Data corruption : more cards into Expansion than expected ${drawCards.length} < ${savedData.drawCards.length}!");
      var itCard = itCurrent.current.iterator;
      saveCards.forEach((card) {
        if(!itCard.moveNext())
          throw StatitikException("ExtensionDrawCards - Draw Data corruption : more card than expected !");
        // Copy data
        itCard.current.copy(card);

        count += card.count();
      });
    });

    var energyIt = drawEnergies.iterator;
    savedData.drawEnergies.forEach((drawEnergy) {
      if(!energyIt.moveNext())
        throw StatitikException("ExtensionDrawCards - Draw Energy Data corruption : more cards into Expansion than expected ${drawEnergies.length} < ${savedData.drawEnergies.length}!");

      energyIt.current.copy(drawEnergy);
      count += drawEnergy.count();
    });

    var noNumberIt = drawNoNumber.iterator;
    savedData.drawNoNumber.forEach((draw) {
      if(!noNumberIt.moveNext())
        throw StatitikException("ExtensionDrawCards - Draw no number Data corruption : more cards into Expansion than expected ${drawNoNumber.length} < ${savedData.drawNoNumber.length}!");

      noNumberIt.current.copy(draw);
      count += draw.count();
    });

    return count;
  }

  /// Remove all empty code to reduce memory size
  List<int> toBytes() {
    // Clean code to minimal binary data
    List<List<int>> allCardsCodes = [];
    drawCards.forEach((codeCards) {
      List<int> localCard = [];
      codeCards.forEach((card) { localCard.add(card.toInt()); });
      allCardsCodes.add(localCard);
    });
    // Parse and Clear empty
    while(allCardsCodes.isNotEmpty) {
      int count=0;
      allCardsCodes.last.forEach((element) { count += element; });
      if(count == 0)
        allCardsCodes.removeLast();
      else
        break;
    }
    int validEnergy = drawEnergies.length;
    if(drawEnergies.isNotEmpty) {
      for(var element in drawEnergies.reversed) {
        if(element.count() > 0)
          break;
        else {
          validEnergy -= 1;
        }
      }
    }
    int validNoNumber = drawNoNumber.length;
    if(drawNoNumber.isNotEmpty) {
      for(var element in drawNoNumber.reversed) {
        if(element.count() > 0)
          break;
        else {
          validNoNumber -= 1;
        }
      }
    }

    // Build binary data
    List<int> bytes = ByteEncoder.encodeInt16(allCardsCodes.length);
    allCardsCodes.forEach((cards) {
      bytes.add(cards.length);
      cards.forEach((code) { bytes.add(code);});
    });
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
}

class CodeDraw {
  List<int> countBySet;

  CodeDraw.fromSet(int nbSets, [int? code]) : countBySet = List<int>.filled(nbSets, 0)
  {
    if(code != null) {
      setCode(code);
    }
  }

  CodeDraw.fromOld([countNormal = 0, countReverse = 0, countHalo = 0]) :
    countBySet = List<int>.filled(2, 0)
  {
    countBySet[0] = countNormal + countHalo;
    countBySet[1] = countReverse;

    assert(countBySet[0] <= 7);
    assert(countBySet[1] <= 7);
  }

  CodeDraw.fromOldCode(int nbSets, int code) :
        countBySet = List<int>.filled(nbSets, 0)
  {
    countBySet[0] = code & 0x07 + (code>>6) & 0x07;
    if(countBySet.length >= 2)
      countBySet[1] = (code>>3) & 0x07;
  }

  CodeDraw.fromBytes(ByteParser parser) :
    countBySet = List<int>.filled(parser.extractInt8(), 0)
  {
    for(int id=0; id < countBySet.length; id+=1) {
      countBySet[id] = parser.extractInt8();
    }
  }

  List<int> toBytes() {
    List<int> bytes = ByteEncoder.encodeInt8(countBySet.length);
    countBySet.forEach((code) {
      bytes += ByteEncoder.encodeInt8(code);
    });
    return bytes;
  }

  void setCode(int code) {
    assert(countBySet.isNotEmpty);

    int mul = 0;
    for(int i=0; i < countBySet.length; i +=1)
    {
      countBySet[i] = (code>>mul) & 0x07;
      mul += 3;
    }
    assert((code>>mul) == 0); // Missing set
  }

  void copy(CodeDraw other) {
    countBySet = List<int>.from(other.countBySet);
  }

  void reset() {
    countBySet = List<int>.filled(countBySet.length, 0);
  }

  int getCountFrom(int set) {
    return countBySet[set];
  }

  int toInt() {
    int code = countBySet.first;
    int mul = 3;
    countBySet.skip(1).forEach((element) {
      code += element << mul;
      mul += 3;
    });
    return code;
  }
  int count() {
    return countBySet.reduce((value, element) => value + element);
  }

  bool isEmpty() {
    return count()==0;
  }

  Color color(PokemonCardExtension card) {
    assert( countBySet.length == card.sets.length, "CodeDraw.Color: size count != card : ${countBySet.length} == ${card.sets.length}" );
    var setInfo = card.sets.reversed.iterator;

    for(var element in countBySet.reversed) {
      setInfo.moveNext();
      if(element > 0)
        return setInfo.current.color;
    }
    return Colors.grey[900]!;
  }

  void increase(int set, int limit) {
    assert(0 <= set && set < countBySet.length);
    countBySet[set] = min(countBySet[set] + 1, limit);
  }

  void decrease(int set) {
    assert(0 <= set && set < countBySet.length);
    countBySet[set] = max(countBySet[set] - 1, 0);
  }

  CodeDraw? add(CodeDraw cardCode, [int mulFactor=1]) {
    bool newResult=false;
    var newCard = CodeDraw.fromSet(countBySet.length);
    var it = cardCode.countBySet.iterator;
    for(int id=0; id < countBySet.length; id += 1){
      if(it.moveNext()) {
        if(it.current > 0) {
          newResult |= countBySet[id] == 0;
          if(newResult)
            newCard.countBySet[id] = 1;
          countBySet[id] += it.current * mulFactor;
        }
      }
    }
    return newResult ? newCard: null;
  }
}


