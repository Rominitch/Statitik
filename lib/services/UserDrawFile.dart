

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';

class UserDrawCollection {

  List<UserDrawFile> collection = [];

  static Future<Directory> folder() async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory([directory.path,"StatitikCard","save"].join(Platform.pathSeparator));
  }

  Future<void> readCollection() async {
    collection.clear();

    Directory saveFolder = await folder();

    if(!saveFolder.existsSync()) {
      saveFolder.createSync();
    } else {
      saveFolder.listSync().forEach((element) {
        collection.add( UserDrawFile(element.path) );
      });
    }
  }
}

class UserDrawFile {
  final String    filePath;

  static const int currentVersion = 1;

  UserDrawFile(this.filePath);

  Future<SessionDraw> read(Map language, Map products, Map subExtensions) async {
    var file = File(filePath);
    var bytes = await file.readAsBytes();
    ByteParser parser = ByteParser(bytes);
    var version = parser.extractInt8();
    if(version == currentVersion) {
      return SessionDraw.fromFile(ValueKey(file.uri.pathSegments.last), parser, language, products, subExtensions);
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