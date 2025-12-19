import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

import '../collection.dart';

class ByteEncoder
{
  static List<int> encodeDouble(double value) {
    var byteData = ByteData(8);
    byteData.setFloat64(0, value);
    return byteData.buffer.asUint8List();
  }

  static List<int> encodeInt32(int value) {
    return <int>[
      (value & 0xFF000000) >> 24,
      (value & 0xFF0000) >> 16,
      (value & 0xFF00) >> 8,
      (value & 0xFF)
    ];
  }

  static List<int> encodeInt8(int value) {
    assert(value < 256);
    return <int>[
      (value & 0xFF)
    ];
  }

  static List<int> encodeInt16(int value) {
    assert(value < 65536);
    return <int>[
      (value & 0xFF00) >> 8,
      (value & 0xFF)
    ];
  }

  static List<int> encodeString16(List<int> stringInfo) {
    assert(stringInfo.length * 2 <= pow(2,32));
    var imageCode = ByteEncoder.encodeInt32(stringInfo.length * 2);
    for (var element in stringInfo) {
      assert(element < 65536);
      imageCode += ByteEncoder.encodeInt16(element);
    }
    return imageCode;
  }

  static List<int> encodeBytesArray16(List<int> byteArray) {
    assert(byteArray.length < 65536);
    return encodeInt16(byteArray.length) + byteArray;
  }
  static List<int> encodeBytesArray32(List<int> byteArray) {
    return encodeInt32(byteArray.length) + byteArray;
  }

  static List<int> encodeBool(bool value) {
    return <int>[value ? 1 : 0];
  }

  static List<int> encodeListString16(List<String> strings) {
    var bytes = ByteEncoder.encodeInt16(strings.length);
    for(final string in  strings) {
      bytes += ByteEncoder.encodeString16(string.codeUnits);
    }
    return bytes;
  }

  static List<int> encodeArray16<ValueType>(List array, List<int> Function(ValueType) encodeValue) {
    var bytes = ByteEncoder.encodeInt16(array.length);
    for(final iterator in array) {
      bytes += encodeValue(iterator.value);
    }
    return bytes;
  }

  static List<int> encodeMap<IDType, ValueType>(Map map, List<int> Function(IDType id) encodeId, List<int> Function(ValueType) encodeValue) {
    var bytes = ByteEncoder.encodeInt32(map.length);
    for(final iterator in map.entries) {
      bytes += encodeId(iterator.key);
      bytes += encodeValue(iterator.value);
    }
    return bytes;
  }

  static List<int> encodeMultiLanguage(MultiLanguageString? multiNames) {
    return multiNames != null
        ? encodeBool(true) + encodeListString16(multiNames.names())
        : encodeBool(false);
  }

  static List<int> encodeColor(Color color) {
    return encodeInt32(color.toARGB32());
  }

  static List<int> encodeIconData(IconData? iconData) {
    return iconData != null
        ? encodeBool(true) + encodeInt32(iconData.codePoint)
        : encodeBool(false);
  }

  static List<int> encodeOptional(value, List<int> Function() encodeValue) {
    return value != null
    ? encodeBool(true) + encodeValue()
    : encodeBool(false);
  }

  static List<int> encodeDateTime(DateTime dateTime) {
    final time = dateTime.toUtc();
    return encodeInt16(time.year)
      + encodeInt8(time.month)
      + encodeInt8(time.day)
      + encodeInt8(time.hour)
      + encodeInt8(time.minute)
      + encodeInt8(time.second)
      + encodeInt16(time.microsecond);
  }
}

class ByteParser
{
  List<int> byteArray;
  Iterator<int>  it;
  late bool canParse;

  ByteParser(this.byteArray) : it = byteArray.iterator {
    canParse = it.moveNext();
  }

  String extractString16() {
    List<int> charCodes = [];
    int length = extractInt32();
    assert(length % 2 == 0);
    for(int i = 0; i < length/2; i +=1) {
      charCodes.add(extractInt16());
    }
    return String.fromCharCodes(charCodes);
  }

  double extractDouble() {
    var list = _extractBytes(8);
    final bdata = ByteData.view(list.buffer);
    return bdata.getFloat64(0);
  }

  int extractInt32() {
    var list = _extractBytes(4);
    return ByteData.view(list.buffer).getInt32(0);
  }

  int extractUInt32() {
    var list = _extractBytes(4);
    return ByteData.view(list.buffer).getUint32(0);
  }

  Uint8List _extractBytes(int nbBytes) {
    var list = Uint8List(nbBytes);
    for(int id=0; id < nbBytes; id += 1) {
      list[id] = it.current;
      canParse = it.moveNext();
    }
    return list;
  }

  int extractInt16() {
    var list = _extractBytes(2);
    return ByteData.view(list.buffer).getInt16(0);
  }

  int extractUInt16() {
    int v = it.current << 8;
    canParse = it.moveNext();
    v |= it.current;
    canParse = it.moveNext();
    return v;
  }

  int extractInt8() {
    int v = it.current;
    canParse = it.moveNext();
    return v;
  }

  bool extractBool() {
    int v = it.current;
    canParse = it.moveNext();
    return v != 0;
  }

  List<int> extractBytesArray16() {
    int nbItems = extractInt16();
    List<int> extract = [];
    for(int i = 0 ; i < nbItems; i +=1) {
      extract.add(extractInt8());
    }
    return extract;
  }

  List<int> extractBytesArray32() {
    int nbItems = extractInt32();
    List<int> extract = [];
    for(int i = 0 ; i < nbItems; i +=1) {
      extract.add(extractInt8());
    }
    return extract;
  }

  List<String> extractListString16() {
    int nbItems = extractInt16();
    List<String> strings = [];
    for(int i = 0 ; i < nbItems; i +=1) {
      strings.add(extractString16());
    }
    return strings;
  }

  MultiLanguageString? extractMultiLanguage() {
    return extractBool() ? MultiLanguageString(extractListString16()) : null;
  }

  Color extractColor() {
    return Color(extractInt32());
  }

  DateTime extractDateTime() {
    return DateTime.utc(extractInt16(), extractInt8(), extractInt8(),
        extractInt8(), extractInt8(), extractInt8(), extractInt16());
  }

  IconData? extractIconData() {
    return extractBool() ? Collection.getIcon(extractInt32()) : null;
  }

  ValueType? extractOptional<ValueType>( ValueType Function(ByteParser parser) extractValue ) {
    return extractBool() ? extractValue(this) : null;
  }

  List<ValueType> extractArray16<ValueType>( ValueType Function(ByteParser parser) extractValue ) {
    var nbValues = extractInt16();
    List<ValueType> array = [];
    for(var i = 0; i < nbValues; i += 1) {
      array.add( extractValue(this) );
    }
    return array;
  }

  Map<IDType, ValueType> extractMap<IDType, ValueType>( IDType Function(ByteParser parser) extractId, ValueType Function(ByteParser parser) extractValue) {
    var nbValues = extractInt32();
    Map<IDType, ValueType> map = {};
    for(var i = 0; i < nbValues; i += 1) {
      map[extractId(this)] = extractValue(this);
    }
    return map;
  }
  Map extractMapWithOrder<IDType, ValueType>( IDType Function(ByteParser parser) extractId, ValueType Function(ByteParser parser) extractValue, List<ValueType> ordered) {
    var nbValues = extractInt32();
    Map map = {};
    for(var i = 0; i < nbValues; i += 1) {
      final value = extractValue(this);
      map[extractId(this)] = value;
      ordered.add(value);
    }
    return map;
  }
}