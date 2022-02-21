import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

import 'Tools.dart';

class ExtensionDrawCards {
  List<List<CodeDraw>> draw = [];

  static const int version = 3; // Warning: Limited to 256

  ExtensionDrawCards();
  ExtensionDrawCards.from(draw) : this.draw = draw;

  ExtensionDrawCards.fromSubExtension(SubExtension subExtension) {
    var allCardsSE = subExtension.seCards.cards;
    draw = List<List<CodeDraw>>.generate(allCardsSE.length, (index) {
      return List<CodeDraw>.generate(allCardsSE[index].length, (index) {return CodeDraw.fromSet(allCardsSE[index][0].sets.length); });
    });
  }

  ExtensionDrawCards.fromBytes(List<int> zipBytes) {
    int currentVersion = zipBytes[0];
    if(currentVersion != version) {
      throw StatitikException("ExtensionDrawCards need migration !");
    }

    List<int> bytes = gzip.decode(zipBytes.sublist(1));

    int pointer = 0;
    while(pointer < bytes.length) {
      int count = bytes[pointer];
      pointer += 1;

      List<CodeDraw> cardCode = [];
      bytes.sublist(pointer, pointer+count).forEach(
        (code){
          cardCode.add(CodeDraw.fromCode(code));
        }
      );
      assert(cardCode.isNotEmpty);

      draw.add(cardCode);
      pointer += count;
    }
  }

  /// Fill current draw with another (generally full Subextension with saved and truncate data)
  int fillWith(ExtensionDrawCards savedData) {
    int count = 0;

    var itCurrent = draw.iterator;

    savedData.draw.forEach((saveCards) {
      if(!itCurrent.moveNext())
        throw StatitikException("ExtensionDrawCards - Draw Data corruption : more cards into Expansion than expected ${draw.length} < ${savedData.draw.length}!");
      var itCard = itCurrent.current.iterator;
      saveCards.forEach((card) {
        if(!itCard.moveNext())
          throw StatitikException("ExtensionDrawCards - Draw Data corruption : more card than expected !");
        // Copy data
        itCard.current.copy(card);

        count += card.count();
      });
    });
    return count;
  }

  /// Remove all empty code to reduce memory size
  List<int> toBytes() {
    // Clean code to minimal binary data
    List<List<int>> allCardsCodes = [];
    draw.forEach((codeCards) {
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
    assert(allCardsCodes.isNotEmpty);

    // Build binary data
    List<int> bytes = [];
    allCardsCodes.forEach((cards) {
      bytes.add(cards.length);
      cards.forEach((code) { bytes.add(code);});
    });

    List<int> finalBytes = [version];
    finalBytes += gzip.encode(bytes);

    printOutput("ExtensionDrawCards: data: ${bytes.length+1} compressed: ${finalBytes.length}");
    return finalBytes;
  }
}

class CodeDraw {
  List<int> countBySet;

  CodeDraw.fromSet(int nbSets) : countBySet = List<int>.filled(nbSets, 0);

  CodeDraw.fromOld([countNormal = 0, countReverse = 0, countHalo = 0]) :
    countBySet = List<int>.filled(2, 0)
  {
    countBySet[0] = countNormal + countHalo;
    countBySet[1] = countReverse;

    assert(countBySet[0] <= 7);
    assert(countBySet[1] <= 7);
  }

  CodeDraw.fromCode(int code) :
        countBySet = List<int>.filled(2, 0)
  {
    countBySet[0] = code & 0x07 + (code>>6) & 0x07;
    countBySet[1] = (code>>3) & 0x07;
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
    assert( countBySet.length == card.sets.length, "${countBySet.length} == ${card.sets.length}" );
    var setInfo = card.sets.reversed.iterator;

    for(var element in countBySet.reversed) {
      setInfo.moveNext();
      if(element > 0)
        return setInfo.current.color;
    }
    return Colors.grey[900]!;
  }

  void increase(int set) {
    assert(0 <= set && set < countBySet.length);
    countBySet[set] = min(countBySet[set] + 1, 7);
  }

  void decrease(int set) {
    assert(0 <= set && set < countBySet.length);
    countBySet[set] = max(countBySet[set] - 1, 0);
  }
}

class BoosterDraw {
  late int id;
  final SubExtension? creation;    ///< Keep product extension.
  final int nbCards;               ///< Number of cards inside booster
  ///
  late List<CodeDraw>      energiesBin;   ///< Energy inside booster.
  late ExtensionDrawCards? cardDrawing;   ///< All card select by extension.
  late SubExtension?       subExtension;  ///< Current extensions.
  int count = 0;
  bool abnormal = false;          ///< Packaging error

  // Event
  final StreamController onEnergyChanged = new StreamController.broadcast();

  BoosterDraw({this.creation, required this.id, required this.nbCards })
  {
    assert(this.nbCards > 0);
    subExtension = creation;
    fillCard();
    fillEnergies();
  }
  
  void fillEnergies() {
    if(hasSubExtension())
      energiesBin = List<CodeDraw>.generate(subExtension!.seCards.energyCard.length, (index) { return CodeDraw.fromSet(subExtension!.seCards.energyCard[index].sets.length); });
  }

  void closeStream() {
    onEnergyChanged.close();
  }

  bool isRandom() {
    return creation == null;
  }

  String nameCard(int id) {
    if(subExtension != null) {
      return subExtension!.seCards.numberOfCard(id);
    } else {
      return (id + 1).toString();
    }
  }

  void resetBooster() {
    count    = 0;
    abnormal = false;
    cardDrawing  = null;
    fillEnergies();
  }

  void resetExtensions() {
    resetBooster();
    cardDrawing  = null;
    subExtension = null;
  }

  void fillCard() {
    if(hasSubExtension())
      cardDrawing = ExtensionDrawCards.fromSubExtension(subExtension!);
  }

  bool isFinished() {
    return abnormal ? count >=1 : count == nbCards;
  }

  bool hasSubExtension() {
    return subExtension != null;
  }

  bool canAdd() {
    return abnormal ? true : count < nbCards;
  }

  int countEnergy() {
    int count=0;
    for( CodeDraw c in energiesBin ){
      count += c.count();
    }
    return count;
  }

  /// Toggle first card (but reset other)
  void toggleCard(List<CodeDraw> codes, int set) {
    var code = codes[0];
    // Remove alternative state
    codes.skip(1).forEach((otherCode) {
      count -= otherCode.count();
      otherCode.reset();
    });

    count -= code.count();
    if(code.isEmpty()) {
      if(canAdd()) {
        code.reset();
        code.increase(set);
      }
    } else {
      code.reset();
    }
    count += code.count();
  }

  void increase(CodeDraw code, int set) {
    if(canAdd()) {
      count -= code.count();
      code.increase(set);
      count += code.count();
    }
  }

  void decrease(CodeDraw code, int set) {
    if(count > 0) {
      count -= code.count();
      code.decrease(set);
      count += code.count();
    }
  }

  void setOtherRendering(CodeDraw code, int set) {
    if(canAdd()) {
      count -= code.count();

      code.reset();
      code.increase(set);

      count += code.count();
    }
  }

  bool needReset() {
    return true;
  }

  void revertAnomaly() {
    resetBooster();
    fillCard();
  }

  List<Object> buildQuery(int idAchat) {
    List<int> energyCode = [];
    for(CodeDraw c in energiesBin) {
      energyCode.add(c.toInt());
    }
    while(energyCode.isNotEmpty && energyCode.last == 0) {
      energyCode.removeLast();
    }

    return [idAchat, subExtension!.id, abnormal ? 1 : 0, Int8List.fromList(energyCode), Int8List.fromList(cardDrawing!.toBytes())];
  }

  Validator validationWorld(final Language language) {
    if(abnormal)
      return Validator.Valid;

    // Fr and US
    if(language.id == 1 || language.id == 2) {
      int count = 0;
      energiesBin.forEach((element) {
        count += element.count();
      });
      if (subExtension!.seCards.hasBoosterEnergy() && count != 1 && count != 2)
        return Validator.ErrorEnergy;

      int goodCard = 0;
      int reverse = 0;
      int id = 0;
      cardDrawing!.draw.forEach((cards) {
        int idLocalCard = 0;
        cards.forEach((element) {
          if (subExtension!.seCards.cards.isNotEmpty) {
            count = element.count();
            if (count > 0) {
              if (subExtension!.seCards.cards[id][idLocalCard].isGoodCard())
                goodCard += count;
              if (otherThanReverse.contains(subExtension!.seCards.cards[id][idLocalCard].rarity))
                reverse += count;
            }
          }

          if(element.countBySet.length > 1)
            reverse += element.countBySet[1];

          idLocalCard += 1;
        });
        id += 1;
      });
      if (subExtension!.seCards.hasAlternativeSet() && reverse != 1 && reverse != 2)
        return Validator.ErrorReverse;
      if (goodCard > 3)
        return Validator.ErrorTooManyGood;
    }
    return Validator.Valid;
  }

  void fill(SubExtension newSubExtension, bool abnormalBooster, ExtensionDrawCards edc, List<int> newEnergiesBin)
  {
    subExtension = newSubExtension;
    abnormal     = abnormalBooster;

    // Fill with full SubExtension data
    fillCard();
    fillEnergies();

    // Fill with saved data (always less data because zero are deleted)
    count = cardDrawing!.fillWith(edc);
    int id=0;
    newEnergiesBin.forEach((element) {
      energiesBin[id] = CodeDraw.fromCode(element);
      count += energiesBin[id].count();
      id += 1;
    });
  }
}