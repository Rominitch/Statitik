import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/collection.dart';

class BinaryWriter {
  final BytesBuilder _builder = BytesBuilder();

  Uint8List toBytes() => _builder.toBytes();

  void writeUint8List(Uint8List data) {
    _builder.add(data);
  }

  void writeGZip(BinaryWriter w) {
    _builder.add(gzip.encode(w.toBytes()));
  }

  void writeCompressBuffer(BinaryWriter w) {
    final buffer = w.toBytes();
    final zip = gzip.encode(w.toBytes());
    // Choose best buffer
    final isZip = buffer.length > zip.length;
    writeBool(isZip);
    _builder.add( isZip ? zip : buffer);
  }

  void writeInt8(int value) {
    final data = ByteData(1);
    data.setInt8(0, value);
    _builder.add(data.buffer.asUint8List());
  }
  void writeUint8(int value) {
    final data = ByteData(1);
    data.setUint8(0, value);
    _builder.add(data.buffer.asUint8List());
  }

  void writeInt16(int value) {
    final data = ByteData(2);
    data.setInt16(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  void writeUint16(int value) {
    final data = ByteData(2);
    data.setUint16(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  void writeInt32(int value) {
    final data = ByteData(4);
    data.setInt32(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  void writeUint32(int value) {
    final data = ByteData(4);
    data.setUint32(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  void writeInt64(int value) {
    final data = ByteData(8);
    data.setInt64(0, value, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  void writeFloat32(double float) {
    final data = ByteData(4);
    data.setFloat32(0, float, Endian.little);
    _builder.add(data.buffer.asUint8List());
  }

  void writeString(String value) {
    final bytes = utf8.encode(value);

    // longueur sur int16
    writeInt16(bytes.length);

    _builder.add(bytes);
  }

  void writeSmallString(String value) {
    assert(value.length < 256);
    final bytes = utf8.encode(value);

    // longueur sur int8
    writeUint8(bytes.length);
    _builder.add(bytes);
  }

  void writeHugeList<T>(
      List<T> list,
      void Function(BinaryWriter writer, T item) encoder,
      ) {
    writeUint32(list.length);

    for (final item in list) {
      encoder(this, item);
    }
  }

  void writeList<T>(
      List<T> list,
      void Function(BinaryWriter writer, T item) encoder,
      ) {
    writeUint16(list.length);

    for (final item in list) {
      encoder(this, item);
    }
  }
  void writeSmallList<T>(
      List<T> list,
      void Function(BinaryWriter writer, T item) encoder,
      )
  {
    assert(list.length <= 256);
    writeUint8(list.length);

    for (final item in list) {
      encoder(this, item);
    }
  }

  void writeSmallMap<K, V>(
      Map<K, V> map,
      void Function(BinaryWriter writer, K key) keyEncoder,
      void Function(BinaryWriter writer, V value) valueEncoder,
      ) {
    writeUint8(map.length);

    map.forEach((key, value) {
      keyEncoder(this, key);
      valueEncoder(this, value);
    });
  }

  void writeMap<K, V>(
      Map<K, V> map,
      void Function(BinaryWriter writer, K key) keyEncoder,
      void Function(BinaryWriter writer, V value) valueEncoder,
      ) {
    writeInt32(map.length);

    map.forEach((key, value) {
      keyEncoder(this, key);
      valueEncoder(this, value);
    });
  }

  void writeDateTime(DateTime date) {
    final data = ByteData(4);
    data.setInt16(0, date.year, Endian.little);
    data.setInt8(2, date.month);
    data.setInt8(3, date.day);
    _builder.add(data.buffer.asUint8List());
  }

  void writeBool(bool b) {
    writeInt8(b ? 1 : 0);
  }

  void writeColor(Color c){
    writeInt32(c.toARGB32());
  }

  void writeIconData(IconData iconData) {
    writeInt32(iconData.codePoint);
  }

  void writeOptional(dynamic value, void Function(BinaryWriter w) encodeValue) {
    if( value != null) {
      writeBool(true);
      encodeValue(this);
    } else {
      writeBool(false);
    }
  }
}

class BinaryReader {
  final Uint8List _buffer;
  int _offset = 0;

  BinaryReader(this._buffer);

  bool canParse() {
    return _offset < _buffer.lengthInBytes;
  }

  BinaryReader readGZip() {
    return BinaryReader(Uint8List.fromList(gzip.decode(readBuffer())));
  }

  BinaryReader readCompressBuffer() {
    // Choose best buffer
    final isZip = readBool();
    if( isZip  ) {
      return readGZip();
    } else {
      return this;
    }
  }

  Uint8List readBuffer() {
    return _buffer.sublist(_offset);
  }

  int readInt8() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 1,
    ).getInt8(0);

    _offset += 1;
    return value;
  }

  int readUint8() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 1,
    ).getUint8(0);

    _offset += 1;
    return value;
  }

  int readInt16() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 2,
    ).getInt16(0, Endian.little);

    _offset += 2;
    return value;
  }

  int readUint16() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 2,
    ).getUint16(0, Endian.little);

    _offset += 2;
    return value;
  }

  int readInt32() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 4,
    ).getInt32(0, Endian.little);

    _offset += 4;
    return value;
  }

  int readUint32() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 4,
    ).getUint32(0, Endian.little);

    _offset += 4;
    return value;
  }

  int readInt64() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 8,
    ).getInt64(0, Endian.little);

    _offset += 8;
    return value;
  }

  double readFloat32() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 4,
    ).getFloat32(0, Endian.little);

    _offset += 4;
    return value;
  }

  String readSmallString() {
    final length = readInt8();
    final bytes = _buffer.sublist(
      _offset,
      _offset + length,
    );
    _offset += length;
    return utf8.decode(bytes);
  }

  String readString() {
    final length = readInt16();
    final bytes = _buffer.sublist(
      _offset,
      _offset + length,
    );
    _offset += length;
    return utf8.decode(bytes);
  }

  List<T> readHugeList<T>(
      T Function(BinaryReader reader) decoder,
      ) {
    final count = readUint32();

    return List.generate(
      count,
          (_) => decoder(this),
    );
  }

  List<T> readList<T>(
      T Function(BinaryReader reader) decoder,
      ) {
    final count = readUint16();

    return List.generate(
      count,
          (_) => decoder(this),
    );
  }

  List<T> readSmallList<T>(
      T Function(BinaryReader reader) decoder,
      ) {
    final count = readInt8();

    return List.generate( count, (_) => decoder(this), );
  }

  Map<K, V> readMap<K, V>(
      K Function(BinaryReader reader) keyDecoder,
      V Function(BinaryReader reader, K key) valueDecoder,
      ) {
    final count = readInt32();

    final result = <K, V>{};

    for (int i = 0; i < count; i++) {
      final key = keyDecoder(this);
      final value = valueDecoder(this, key);
      result[key] = value;
    }

    return result;
  }

  Map<K, V> readSmallMap<K, V>(
      K Function(BinaryReader reader) keyDecoder,
      V Function(BinaryReader reader) valueDecoder,
      ) {
    final count = readUint8();

    final result = <K, V>{};

    for (int i = 0; i < count; i++) {
      final key = keyDecoder(this);
      final value = valueDecoder(this);
      result[key] = value;
    }

    return result;
  }

  DateTime readDateTime() {
    return DateTime(readInt16(), readInt8(), readInt8());
  }

  bool readBool() {
    return readInt8() != 0;
  }

  Color readColor() {
    return Color(readInt32());
  }

  IconData readIconData() {
    return Collection.getIcon(readInt32());
  }

  ValueType? readOptional<ValueType>( ValueType? Function(BinaryReader r) extractValue ) {
    return readBool() ? extractValue(this) : null;
  }

  int tmpReadInt16BIG() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 2,
    ).getInt16(0);

    _offset += 2;
    return value;
  }

  int tmp_readInt32BIG() {
    final value = ByteData.sublistView(
      _buffer,
      _offset,
      _offset + 4,
    ).getInt32(0);

    _offset += 4;
    return value;
  }

  String tmpReadOldString16() {
    List<int> charCodes = [];
    int length = readUint8();
    assert(length % 2 == 0);
    for(int i = 0; i < length/2; i +=1) {
      charCodes.add(tmpReadInt16BIG());
    }
    return String.fromCharCodes(charCodes);
  }

  bool isFullyRead() {
    return _offset == _buffer.length;
  }
}