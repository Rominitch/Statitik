import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Rarity.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

import 'Tools.dart';

class ExtensionDrawCards {
  List<List<CodeDraw>> draw = [];

  static const int version = 3; // Warning: Limited to 256

  ExtensionDrawCards();
  ExtensionDrawCards.from(draw) : this.draw = draw;

  ExtensionDrawCards.fromSubExtension(SubExtension subExtension) {
    var allCardsSE = subExtension.seCards.cards;
    draw = List<List<CodeDraw>>.generate(allCardsSE.length, (index) {
      return List<CodeDraw>.generate(allCardsSE[index].length, (index) {return CodeDraw(); });
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
          cardCode.add(CodeDraw.fromInt(code));
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
        itCard.current.countNormal  = card.countNormal;
        itCard.current.countReverse = card.countReverse;
        itCard.current.countHalo    = card.countHalo;

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
  int countNormal;
  int countReverse;
  int countHalo;

  CodeDraw([this.countNormal = 0, this.countReverse = 0, this.countHalo = 0]) {
    assert(this.countNormal <= 7);
    assert(this.countReverse <= 7);
    assert(this.countHalo <= 7);
  }

  CodeDraw.fromInt(int code) :
    this.countNormal      = code & 0x07,
    this.countReverse     = (code>>3) & 0x07,
    this.countHalo        = (code>>6) & 0x07;

  int getCountFrom(Mode mode) {
    List<int> byMode = [countNormal, countReverse, countHalo];
    return byMode[mode.index];
  }

  int toInt() {
    int code = countNormal
        + (countReverse<<3)
        + (countHalo   <<6);
        //+ (countAlternative <<9);
    return code;
  }
  int count() {
    return countNormal+countReverse+countHalo;
  }

  bool isEmpty() {
    return count()==0;
  }

  Color color() {
    return countHalo > 0
        ? modeColors[Mode.Halo]
        : (countReverse > 0
        ?modeColors[Mode.Reverse]
        : (countNormal > 0
        ? modeColors[Mode.Normal]
        : Colors.grey[900]));
  }

  void increase(Mode mode) {
    if( mode == Mode.Normal)
      countNormal = min(countNormal + 1, 7);
    else if( mode == Mode.Reverse)
      countReverse = min(countReverse + 1, 7);
    else
      countHalo = min(countHalo + 1, 7);
  }

  void decrease(Mode mode) {
    if( mode == Mode.Normal)
      countNormal = max(countNormal - 1, 0);
    else if( mode == Mode.Reverse)
      countReverse = max(countReverse - 1, 0);
    else
      countHalo = max(countHalo - 1, 0);
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
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(); });
    subExtension = creation;
    if(hasSubExtension()) {
      fillCard();
    }
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
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(); });
  }

  void resetExtensions() {
    resetBooster();
    cardDrawing  = null;
    subExtension = null;
  }

  void fillCard() {
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
  void toggleCard(List<CodeDraw> codes, Mode mode) {
    var code = codes[0];
    // Remove alternative state
    codes.sublist(1).forEach((otherCode) {
      count -= otherCode.count();
      otherCode.countNormal      = 0;
      otherCode.countReverse     = 0;
      otherCode.countHalo        = 0;
    });

    count -= code.count();
    if(code.isEmpty()) {
      if(canAdd()) {
        code.countNormal      = mode==Mode.Normal      ? 1 : 0;
        code.countReverse     = mode==Mode.Reverse     ? 1 : 0;
        code.countHalo        = mode==Mode.Halo        ? 1 : 0;
      }
    } else {
      code.countNormal      = 0;
      code.countReverse     = 0;
      code.countHalo        = 0;
    }
    count += code.count();
  }

  void increase(CodeDraw code, Mode mode) {
    if(canAdd()) {
      count -= code.count();
      code.increase(mode);
      count += code.count();
    }
  }

  void decrease(CodeDraw code, Mode mode) {
    if(count > 0) {
      count -= code.count();
      code.decrease(mode);
      count += code.count();
    }
  }

  void setOtherRendering(CodeDraw code, Mode mode) {
    if(canAdd()) {
      count -= code.count();

      code.countNormal      = mode==Mode.Normal      ? 1 : 0;
      code.countReverse     = mode==Mode.Reverse     ? 1 : 0;
      code.countHalo        = mode==Mode.Halo        ? 1 : 0;

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
          reverse += element.countReverse;

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
    energiesBin = List<CodeDraw>.generate(energies.length, (index) { return CodeDraw(); });

    // Fill with saved data (always less data because zero are deleted)
    count = cardDrawing!.fillWith(edc);
    int id=0;
    newEnergiesBin.forEach((element) {
      energiesBin[id] = CodeDraw.fromInt(element);
      count += energiesBin[id].count();
      id += 1;
    });
  }
}