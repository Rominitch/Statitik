import 'dart:async';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

import 'package:path_provider/path_provider.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class StorageData {
  final List<String> folders;
  final String    imageLocalPath;
  final List<Uri> urls;

  const StorageData(this.folders, this.imageLocalPath, this.urls);
}

class ImageStorage {
  static const List formats = const["webp", "png" , "jpg"];

  Future<String> imageLocalPath(List<String> folders, String file, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    return ([directory.path]+folders+["$file.$extension"]).join(Platform.pathSeparator);
  }

  Future<File?> storeImageToFile(String imageLocalPath, List<Uri> urls) async {
    var file;
    for (var url in urls) {
      if(file == null) {
        // Try to download image
        final client = RetryClient(Client(), retries: 3, );
        try {
          var bodyBytes = await client.readBytes(url);
          var dots = url.path.split(".");
          var ext = url.path.substring(url.path.length - dots[dots.length-1].length);
          // Save on local (to webp format)
          file = File(imageLocalPath+ext);
          try {
            await file.create(recursive: true);
            await file.writeAsBytes(bodyBytes, flush: true);
            printOutput("ImageStorage: Find ${url.toString()}");

            if(ext != "webp") {
              try {
                var newFile = await FlutterImageCompress.compressAndGetFile(
                  imageLocalPath + ext,
                  imageLocalPath + "webp",
                  quality: 98,
                  format: CompressFormat.webp,
                );
                printOutput("Convert image from $ext to webp: from ${bodyBytes.length} to ${newFile!.lengthSync()}");
                // Clean original file save
                if(file != null && file.existsSync())
                  file.deleteSync();
                file = newFile;
              } catch(e) {
                printOutput("ImageStorage : convert Error: ${e.toString()}");
              }
            }
          } catch(e) {
            printOutput("ImageStorage : error ${e.toString()}");
            // Clean bad file save
            if(file != null && file.existsSync())
              file.deleteSync();

            file = null;
          }
        } catch(e) {
          printOutput("ImageStorage: Not found ${url.toString()}");
        } finally {
          client.close();
        }
      }
    }
    return file;
  }

  Future<File?> imageFromPath(StorageData data) async {
    try {
      var imageLocale = await imageLocalPath(data.folders, data.imageLocalPath, "");
      var ok = false;
      var file;
      for(var format in formats) {
        file = File(imageLocale+format);
        ok = file.existsSync();
        if(ok)
          break;
      }

      if(ok) {
        return file;
      } else {
        return await storeImageToFile(imageLocale, data.urls);
      }
    }
    catch(error) {
      return null;
    }
  }

  Future<void> cleanCardFile(SubExtension se, CardIdentifier idCard) async {
    await cleanImageFile(["images", "card", se.extension.language.image, se.icon], idCard.toString());
  }

  Future<void> cleanImageFile(List<String> pathParts, String imageName) async {
    for(var format in formats) {
      var path = await imageLocalPath(pathParts, imageName, format);
      var file = File(path);
      if(file.existsSync()) {
        file.deleteSync();
        break;
      }
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