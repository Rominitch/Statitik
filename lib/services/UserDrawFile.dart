import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/Draw/SessionDraw.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';

class UserDrawCollection {
  static Future<Directory> folder() async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory([directory.path, "StatitikCardCollection"].join(Platform.pathSeparator));
  }

  static Future<List<UserDrawFile>> readSavedDraws() async {
    List<UserDrawFile> savedDraws = [];

    Directory saveFolder = await folder();

    if(!saveFolder.existsSync()) {
      saveFolder.createSync();
    } else {
      saveFolder.listSync().forEach((element) {
        savedDraws.add( UserDrawFile(element.path) );
      });
    }
    return savedDraws;
  }

  static Future<Directory> prepareCollectionFolder() async {
    Directory saveFolder = await folder();

    if(!saveFolder.existsSync()) {
      saveFolder.createSync();
    }
    return saveFolder;
  }
}

class UserDrawFile {
  final String filePath;

  static const int currentVersion = 2;

  UserDrawFile(this.filePath);

  Future<SessionDraw> read(Map language, Map products, Map subExtensions) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    ByteParser parser = ByteParser(bytes);
    var version = parser.extractInt8();
    if(version <= currentVersion) {
      return SessionDraw.fromFile(ValueKey(file.uri.pathSegments.last), version, parser, language, products, subExtensions);
    }
    throw StatitikException("Unknown file");
  }

  Future save(SessionDraw draw) async {
    var file = File(filePath);

    var bytes = <int>[currentVersion] + draw.toBytes();

    return file.writeAsBytes(bytes, flush: true);
  }

  void remove() {
    File(filePath).deleteSync();

    assert(!File(filePath).existsSync());
  }

}