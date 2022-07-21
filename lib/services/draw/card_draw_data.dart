import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

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
        return CodeDraw.fromPokeCardExtension(cardForNumber[subIndex]);
      });
    });

    var energiesCards = subExtension.seCards.energyCard;
    drawEnergies = List<CodeDraw>.generate(energiesCards.length, (index) {
      return CodeDraw.fromPokeCardExtension(energiesCards[index]);
    });

    var noNumberCards = subExtension.seCards.noNumberedCard;
    drawNoNumber = List<CodeDraw>.generate(noNumberCards.length, (index) {
      return CodeDraw.fromPokeCardExtension(noNumberCards[index]);
    });
  }

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

  /// Fill current draw with another (generally full Subextension with saved and truncate data)
  int fillWith(ExtensionDrawCards savedData) {
    int count = 0;

    var itCurrent = drawCards.iterator;

    savedData.drawCards.forEach((saveCards) {
      if(!itCurrent.moveNext()) {
        throw StatitikException("ExtensionDrawCards - draw Data corruption : more cards into Expansion than expected ${drawCards.length} < ${savedData.drawCards.length}!");
      }
      var itCard = itCurrent.current.iterator;
      saveCards.forEach((card) {
        if(!itCard.moveNext()) {
          throw StatitikException("ExtensionDrawCards - draw Data corruption : more card than expected !");
        }
        // Copy data
        itCard.current.copy(card);

        count += card.count();
      });
    });

    var energyIt = drawEnergies.iterator;
    savedData.drawEnergies.forEach((drawEnergy) {
      if(!energyIt.moveNext()) {
        throw StatitikException("ExtensionDrawCards - draw Energy Data corruption : more cards into Expansion than expected ${drawEnergies.length} < ${savedData.drawEnergies.length}!");
      }

      energyIt.current.copy(drawEnergy);
      count += drawEnergy.count();
    });

    var noNumberIt = drawNoNumber.iterator;
    savedData.drawNoNumber.forEach((draw) {
      if(!noNumberIt.moveNext()) {
        throw StatitikException("ExtensionDrawCards - draw no number Data corruption : more cards into Expansion than expected ${drawNoNumber.length} < ${savedData.drawNoNumber.length}!");
      }

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
  List<List<int>> _countBySetByImage;

  CodeDraw.emptyCopy(CodeDraw copy) :
    _countBySetByImage = []
  {
    copy._countBySetByImage.forEach((images) {
      assert(images.isNotEmpty);
      _countBySetByImage.add(List<int>.generate(images.length, (id) => 0));
    });
  }

  CodeDraw.fromPokeCardExtension(PokemonCardExtension card, [int? code]) :
    _countBySetByImage = []
  {
    assert(card.sets.length == card.images.length);
    card.images.forEach((images) {
      _countBySetByImage.add(List<int>.generate(max(1, images.length), (id) => 0));
      assert(_countBySetByImage.last.length == images.length || _countBySetByImage.last.length == 1);
    });
    assert(_countBySetByImage.length == card.images.length);

    if(code != null) {
      setCode(code);
    }
  }
  CodeDraw.fromSet(int nbSets, [int? code]) :
    _countBySetByImage = List<List<int>>.generate(nbSets, (value) => List<int>.generate(1, (id) => 0))
  {
    if(code != null) {
      setCode(code);
    }
  }

  CodeDraw.fromOld([countNormal = 0, countReverse = 0, countHalo = 0]) :
    _countBySetByImage = List<List<int>>.generate(2, (index) => List<int>.generate(1, (index) => 0))
  {
    _countBySetByImage[0][0] = countNormal + countHalo;
    _countBySetByImage[1][0] = countReverse;

    assert(_countBySetByImage[0][0] <= 7);
    assert(_countBySetByImage[1][0] <= 7);
  }

  CodeDraw.fromOldCode(int nbSets, int code) :
    _countBySetByImage = List<List<int>>.generate(nbSets, (id) => List<int>.generate(1, (id) =>0))
  {
    _countBySetByImage[0][0] = code & 0x07 + (code>>6) & 0x07;
    if(_countBySetByImage.length >= 2) {
      _countBySetByImage[1][0] = (code>>3) & 0x07;
    }
  }

  CodeDraw.fromBytesV1(ByteParser parser) :
    _countBySetByImage = List<List<int>>.generate(parser.extractInt8(), (id) => List<int>.generate(1, (id) =>0))
  {
    for(int id=0; id < _countBySetByImage.length; id+=1) {
      _countBySetByImage[id][0] = parser.extractInt8();
    }
  }

  CodeDraw.fromBytes(ByteParser parser) :
    _countBySetByImage = List<List<int>>.generate(parser.extractInt8(), (id) => [])
  {
    for(int id=0; id < _countBySetByImage.length; id+=1) {
      var nbImages = parser.extractInt8();
      for(int idImage=0; idImage < nbImages; idImage+=1) {
        _countBySetByImage[id].add(parser.extractInt8());
      }
    }
  }

  List<int> toBytes() {
    List<int> bytes = ByteEncoder.encodeInt8(_countBySetByImage.length);
    _countBySetByImage.forEach((List<int> countByImage) {
      bytes += ByteEncoder.encodeInt8(countByImage.length);
      countByImage.forEach((count) {
        assert(count < 256);
        bytes += ByteEncoder.encodeInt8(count);
      });
    });
    return bytes;
  }

  Iterator get iterator {
    return _countBySetByImage.iterator;
  }

  void setCount(int newCount, int idSet, [int idImage=0]) {
    assert(newCount >= 0);
    assert(idSet < _countBySetByImage.length);
    assert(idImage < _countBySetByImage[idSet].length);

    _countBySetByImage[idSet][idImage] = newCount;
  }

  void setCode(int code) {
    assert(_countBySetByImage.isNotEmpty);

    int mul = 0;
    for(int i=0; i < _countBySetByImage.length; i +=1)
    {
      _countBySetByImage[i].first = (code>>mul) & 0x07;
      mul += 3;
    }
    assert((code>>mul) == 0); // Missing set
  }

  void copy(CodeDraw other) {
    _countBySetByImage = [];
    other._countBySetByImage.forEach((element) {
      _countBySetByImage.add(List<int>.from(element));
    });
  }

  void reset() {
    for(int i=0; i < _countBySetByImage.length; i +=1)
    {
      _countBySetByImage[i] = List<int>.generate(_countBySetByImage[i].length, (id) =>0);
    }
  }

  int getCountFrom(int set, [int image=0]) {
    assert(set < _countBySetByImage.length, "Set is not valid: $set >= ${_countBySetByImage.length}");
    assert(image < _countBySetByImage[set].length, "Image is not valid: $set $image >= ${_countBySetByImage[set].length}");

    return _countBySetByImage[set][image];
  }

  int toInt() {
    int code = _countBySetByImage.first.first;
    int mul = 3;
    _countBySetByImage.skip(1).forEach((element) {
      code += element.first << mul;
      mul += 3;
    });
    return code;
  }

  int countBySet(int idSet) {
    int c = 0;
    if(idSet < _countBySetByImage.length) {
      if(_countBySetByImage[idSet].isNotEmpty) {
        c = _countBySetByImage[idSet].reduce((value, currentItem) => value + currentItem);
      }
    }
    return c;
  }

  int nbSetsRegistred() {
    return _countBySetByImage.length;
  }

  int count() {
    int c = 0;
    _countBySetByImage.forEach((countByImage) {
      if(countByImage.isNotEmpty) {
        c += countByImage.reduce((value, currentItem) => value + currentItem);
      }
    });
    return c;
  }

  bool isEmpty() {
    return count()==0;
  }

  Color color(PokemonCardExtension card) {
    assert( _countBySetByImage.length == card.sets.length, "CodeDraw.Color: size count != card : ${_countBySetByImage.length} == ${card.sets.length}" );
    var setInfo = card.sets.reversed.iterator;

    for(var element in _countBySetByImage.reversed) {
      if(setInfo.moveNext()) {
        var count = element.reduce((value, currentItem) => value + currentItem);
        if (count > 0) {
          return setInfo.current.color;
        }
      }
    }
    return Colors.grey[900]!;
  }

  bool increase(int set, int limit, [int image=0]) {
    assert(0 <= set && set < _countBySetByImage.length);
    var v = _countBySetByImage[set][image] + 1;
    var finalV = min(v, limit);
    _countBySetByImage[set][image] = finalV;
    return v != finalV;
  }

  bool decrease(int set, [int image=0]) {
    assert(0 <= set && set < _countBySetByImage.length);
    var v = _countBySetByImage[set][image] - 1;
    var finalV = max(v, 0);
    _countBySetByImage[set][image] = finalV;
    return v != finalV;
  }

  CodeDraw? add(CodeDraw cardCode, [int mulFactor=1]) {
    bool newResult=false;
    // Create copy for report of new card
    var newCards = CodeDraw.emptyCopy(this);

    var itByImage = cardCode._countBySetByImage.iterator;
    for(int idSet=0; idSet < _countBySetByImage.length; idSet += 1){
      if(itByImage.moveNext()) {
        var it = itByImage.current.iterator;
        for(int id=0; id < _countBySetByImage[idSet].length; id += 1){
          if(it.moveNext()) {
            if(it.current > 0) {
              newResult |= _countBySetByImage[idSet][id] == 0;
              if(newResult) {
                newCards._countBySetByImage[idSet][id] = 1;
              }
              _countBySetByImage[idSet][id] += it.current * mulFactor;
            }
          }
        }
      }
    }
    return newResult ? newCards: null;
  }

  /// Check if card is in reverse position
  int countBoosterReversePosition(PokemonCardExtension card) {
    // Check global rarity
    if( Environment.instance.collection.otherThanReverse.contains(card.rarity) ) {
      return count();
    } else {
      int alternativeSet = 0;
      var countSet = _countBySetByImage.iterator;
      // or for each set, check reverse
      card.sets.forEach((set) {
        if (countSet.moveNext()) {
          if (set.isParallel || set.replaceRevertIntoBooster) {
            alternativeSet +=
                countSet.current.reduce((value, currentItem) => value +
                    currentItem);
          }
        }
      });
      return alternativeSet;
    }
  }

  List<int> allCounts() {
    List<int> counts = List.generate(_countBySetByImage.length, (id) => 0);
    for(int idSet=0; idSet < _countBySetByImage.length; idSet += 1) {
      counts[idSet] = _countBySetByImage[idSet].reduce((value, currentItem) => value + currentItem);
    }
    return counts;
  }
}


