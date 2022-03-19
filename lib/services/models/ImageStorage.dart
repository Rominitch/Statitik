import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/retry.dart';

import 'package:path_provider/path_provider.dart';
import 'package:statitikcard/services/Tools.dart';

class StorageData {
  //final StreamController controler;
  final List<String> folders;
  final String    imageLocalPath;
  final List<Uri> urls;
  final bool      force;

  const StorageData(/*this.controler,*/ this.folders, this.imageLocalPath, this.urls, {this.force=false});
}

class ImageStorage {
  Future<String> imageLocalPath(List<String> folders, String file, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    return ([directory.path, ]+folders+["$file.$extension"]).join(Platform.pathSeparator);
  }

  Future<File?> storeImageToFile(String imageLocalPath, List<Uri> urls) async {
    var file;
    for (var url in urls) {
      if(file == null) {
        // Try to download image
        final client = RetryClient(Client(), retries: 3);
        try {
          //printOutput("Try to extract: ${url.toString()} with ext= $ext");

          var bodyBytes = await client.readBytes(url);

          var ext = url.path.substring(url.path.length - 3);
          // Save on local
          file = File(imageLocalPath + ext);
          try {
            await file.create(recursive: true);
            await file.writeAsBytes(bodyBytes, flush: true);
          } catch(e) {
            // Clean bad file save
            if(file != null && file.existsSync())
              file.deleteSync();
          }
        } catch(e) {
          //printOutput("HTTP: ERROR $e\n$stack");
        } finally {
          client.close();
        }
      }
    }
    return file;
  }

  Future<File?> imageFromPath(StorageData data) async {
    var imageLocale = await imageLocalPath(data.folders, data.imageLocalPath, "");
    var file = File(imageLocale+"png");
    var ok = await file.exists();
    if(!ok) {
      file = File(imageLocale+"jpg");
      ok = await file.exists();
    }

    if(ok && !data.force) {
      return file;
    } else {
      return await storeImageToFile(imageLocale, data.urls);
    }
  }

  Future<void> clean() async {
    var directory = await getApplicationDocumentsDirectory();
    var dir = Directory([directory.path, "images"].join(Platform.pathSeparator));
    var ok = await dir.exists();
    if(ok)
      dir.delete(recursive: true);
  }

  Future<int> storageSize() async {
    var directory = await getApplicationDocumentsDirectory();
    var dir = Directory([directory.path, "images"].join(Platform.pathSeparator));

    int totalSize = 0;

    try {
      var ok = await dir.exists();
      if (ok) {
        var files = dir.listSync(recursive: true, followLinks: false);
        files.forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      printOutput(e.toString());
    }
    return totalSize;

  }
}