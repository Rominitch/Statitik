import 'dart:math';

import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeCardDraw {
  //List<List<int>> _countBySetByImage;
  Map<PokeSet, List<int>> _countBySetByImage;

  PokeCardDraw.emptyCopy(PokeCardDraw copy) :
        _countBySetByImage = {}
  {
    copy._countBySetByImage.forEach((set, images){
      assert(images.isNotEmpty);
      _countBySetByImage[set] = List<int>.generate(images.length, (id) => 0);
    });
  }

  PokeCardDraw.fromPokeCardExtension(PokeCardInExpansion card, [int? code]) :
        _countBySetByImage = {}
  {
    card.setInfo.forEach((set, images){
      _countBySetByImage[set] = List<int>.generate(max(1, images.length), (id) => 0);
    });
    assert(_countBySetByImage.length == card.setInfo.length);

    if(code != null) {
      setCode(code);
    }
  }

  PokeCardDraw.fromBytes(BinaryReader reader, PokeCollection collection) :
    _countBySetByImage = reader.readSmallMap(
      (readKey) => collection.sets(PokeIdentifier.fromBytes(readKey))!,
      (readList) => readList.readSmallList(
        (readItem) => readItem.readUint8()) );

  void toBytes(BinaryWriter writer) {
    writer.writeMap(_countBySetByImage, 
      (writer, key)   => key.toBytesID(writer),
      (writer, value) => writer.writeSmallList(value, (writer, item) => writer.writeUint8(item)));
  }
  
  PokeCardDraw.fromOldDBBytes(BinaryReader reader, PokeCardInExpansion card) :
    _countBySetByImage = {}
  {
    assert(card.setInfo.keys.length == _countBySetByImage.length);
    for(int id=0; id < _countBySetByImage.length; id+=1) {
      final set = card.orderedSets()[id];
      final nbImages = reader.readUint8();
      List<int> images = [];
      for(int idImage=0; idImage < nbImages; idImage+=1) {
        images.add(reader.readUint8());
      }
      _countBySetByImage[set] = images;
    }
    reader.readSmallList(
      (readList) => readList.readSmallList(
      (readItem) => readItem.readUint8()) );
  }

  Map<PokeSet, List<int>> data() { return _countBySetByImage; }

/*
  PokeCodeDraw.fromSet(int nbSets, [int? code]) :
        _countBySetByImage = List<List<int>>.generate(nbSets, (value) => List<int>.generate(1, (id) => 0))
  {
    if(code != null) {
      setCode(code);
    }
  }

  PokeCodeDraw.fromOld([countNormal = 0, countReverse = 0, countHalo = 0]) :
        _countBySetByImage = List<List<int>>.generate(2, (index) => List<int>.generate(1, (index) => 0))
  {
    _countBySetByImage[0][0] = countNormal + countHalo;
    _countBySetByImage[1][0] = countReverse;

    assert(_countBySetByImage[0][0] <= 7);
    assert(_countBySetByImage[1][0] <= 7);
  }

  PokeCodeDraw.fromOldCode(int nbSets, int code) :
        _countBySetByImage = List<List<int>>.generate(nbSets, (id) => List<int>.generate(1, (id) =>0))
  {
    _countBySetByImage[0][0] = code & 0x07 + (code>>6) & 0x07;
    if(_countBySetByImage.length >= 2) {
      _countBySetByImage[1][0] = (code>>3) & 0x07;
    }
  }

  PokeCodeDraw.fromBytesV1(ByteParser parser) :
        _countBySetByImage = List<List<int>>.generate(parser.extractInt8(), (id) => List<int>.generate(1, (id) =>0))
  {
    for(int id=0; id < _countBySetByImage.length; id+=1) {
      _countBySetByImage[id][0] = parser.extractInt8();
    }
  }

  PokeCodeDraw.fromBytes(ByteParser parser) :
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
    for (var countByImage in _countBySetByImage) {
      bytes += ByteEncoder.encodeInt8(countByImage.length);
      for (var count in countByImage) {
        assert(count < 256);
        bytes += ByteEncoder.encodeInt8(count);
      }
    }
    return bytes;
  }

  Iterable get iterator {
    return _countBySetByImage.entries;
  }
*/
  void setCount(int newCount, PokeSet set, [int idImage=0]) {
    assert(newCount >= 0);
    assert(_countBySetByImage.containsKey(set));
    assert(idImage < _countBySetByImage[set]!.length);

    _countBySetByImage[set]![idImage] = newCount;
  }

  void setCode(int code) {
    assert(_countBySetByImage.isNotEmpty);

    int mul = 0;
    for(final set in _countBySetByImage.keys)
    {
      _countBySetByImage[set]!.first = (code>>mul) & 0x07;
      mul += 3;
    }
    assert((code>>mul) == 0); // Missing set
  }

  void copy(PokeCardDraw other) {
    _countBySetByImage = {};
    for (final entry in other._countBySetByImage.entries) {
      _countBySetByImage[entry.key] = List<int>.from(entry.value);
    }
  }

  void reset() {
    for(final set in _countBySetByImage.keys)
    {
      _countBySetByImage[set] = List<int>.generate(_countBySetByImage[set]!.length, (id) =>0);
    }
  }

  int getCountFrom(PokeSet set, [int image=0]) {
    assert(_countBySetByImage.containsKey(set), "Set is not valid");
    final countByImage = _countBySetByImage[set]!;
    assert(image < countByImage.length, "Image is not valid: $set $image >= ${countByImage.length}");

    return countByImage[image];
  }
/*
  int toInt() {
    int code = _countBySetByImage.keys.first;
    int mul = 3;
    _countBySetByImage.skip(1).forEach((element) {
      code += element.first << mul;
      mul += 3;
    });
    return code;
  }
*/
  int countBySet(PokeSet set) {
    int c = 0;
    final countByImage = _countBySetByImage[set];
    if(countByImage!.isNotEmpty) {
      c = countByImage.reduce((value, currentItem) => value + currentItem);
    }
    return c;
  }

  int nbSetsRegistred() {
    return _countBySetByImage.length;
  }

  int count() {
    int c = 0;
    for (var countByImage in _countBySetByImage.values) {
      if(countByImage.isNotEmpty) {
        c += countByImage.reduce((value, currentItem) => value + currentItem);
      }
    }
    return c;
  }

  bool isEmpty() {
    return count()==0;
  }
/*
  Color color(PokeCardInExpansion card) {
    assert( _countBySetByImage.length == card.setInfo.length, "CodeDraw.Color: size count != card : ${_countBySetByImage.length} == ${card.sets.length}" );
    var setInfo = card.setInfo.reversed.iterator;

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
*/
  bool increase(PokeSet set, int limit, [int image=0]) {
    assert(_countBySetByImage.containsKey(set));
    final countByImage = _countBySetByImage[set]!;
    var v = countByImage[image];
    var finalV = min(v + 1, limit);
    countByImage[image] = finalV;
    return v != finalV;
  }

  bool decrease(PokeSet set, [int image=0]) {
    assert(_countBySetByImage.containsKey(set));
    final countByImage = _countBySetByImage[set]!;
    var v = countByImage[image];
    var finalV = max(v - 1, 0);
    countByImage[image] = finalV;
    return v != finalV;
  }

  PokeCardDraw? add(PokeCardDraw cardCode, [int mulFactor=1]) {
    bool newResult=false;
    // Create copy for report of new card
    var newCards = PokeCardDraw.emptyCopy(this);

    throw "todo";
    /*
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
    */
  }
/*
  /// Check if card is in reverse position
  int countBoosterReversePosition(PokemonCardExtension card) {
    // Check global rarity
    if( Environment.instance.collection.otherThanReverse.contains(card.rarity) ) {
      return count();
    } else {
      int alternativeSet = 0;
      var countSet = _countBySetByImage.iterator;
      // or for each set, check reverse
      for (var set in card.sets) {
        if (countSet.moveNext()) {
          if (set.isParallel || set.replaceRevertIntoBooster) {
            alternativeSet +=
                countSet.current.reduce((value, currentItem) => value +
                    currentItem);
          }
        }
      }
      return alternativeSet;
    }
  }
*/
  Map<PokeSet, int> allCounts() {
    Map<PokeSet, int> counts = {};
    for(final entry in _countBySetByImage.entries) {
      counts[entry.key] = entry.value.reduce((value, currentItem) => value + currentItem);
    }
    return counts;
  }
}