import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

import 'package:path_provider/path_provider.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class StorageData {
  final List<String> folders;
  final String    imageLocalPath;
  final List<Uri> urls;

  const StorageData(this.folders, this.imageLocalPath, this.urls);
}

class ImageStorage {
  static const List formats = ["webp", "png" , "jpg"];

  Future<String> imageLocalPath(List<String> folders, String file, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    return ([directory.path]+folders+["$file.$extension"]).join(Platform.pathSeparator);
  }

  Future<File?> storeImageToFile(String imageLocalPath, List<Uri> urls) async {
    File? file;
    for (var url in urls) {
      if(file == null) {
        // Try to download image
        final client = RetryClient(Client(), retries: 4 );
        Uint8List? bodyBytes;
        String ext;
        try {
          bodyBytes = await client.readBytes(url);
          var dots = url.path.split(".");
          ext = url.path.substring(url.path.length - dots[dots.length-1].length);
        } catch(e) {
          printOutput("ImageStorage: Not found ${url.toString()} -> ${urls.indexOf(url)}/${urls.length}");
          file      = null;
          bodyBytes = null;
          ext       = "";
        }
        client.close();

        // If data
        if(bodyBytes != null && bodyBytes.isNotEmpty) {
          // Try to convert png data to webp (better format ?)
          if(ext != "webp") {
            try {
              var newData = await FlutterImageCompress.compressWithList(
                bodyBytes,
                quality: 98,
                format: CompressFormat.webp,
              );
              //Replace data
              if( newData.length <= bodyBytes.length ) {
                printOutput("ImageStorage: Convert from $ext to webp: from ${bodyBytes.length} to ${newData.length}");
                bodyBytes = newData;
                ext = "webp";
              } else {
                printOutput("ImageStorage: Keep original: size ${bodyBytes.length} (webp: ${newData.length})");
              }
            } catch(e) {
              printOutput("ImageStorage: convert Error: ${e.toString()}");
              bodyBytes!.clear();
            }
          }
          // Create final file (best size on device)
          if(bodyBytes.isNotEmpty) {
            try {
              file = File(imageLocalPath+ext);

              file.createSync(recursive: true);
              file.writeAsBytesSync(bodyBytes, flush: true);
              printOutput("ImageStorage: Find ${url.toString()} -> ${imageLocalPath+ext}");
            } catch(e) {
              printOutput("ImageStorage : error ${e.toString()}");
              // Clean bad file save
              if(file != null && file.existsSync()) {
                file.deleteSync();
              }
              file = null;
            }
          }
        }
      }
    }
    return file;
  }

  Future<File?> imageFromPath(StorageData data) async {
    try {
      var imageLocale = await imageLocalPath(data.folders, data.imageLocalPath, "");
      var ok = false;
      File? file;
      for(var format in formats) {
        file = File(imageLocale+format);
        ok = file.existsSync();
        if(ok) {
          break;
        }
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
        printOutput("Remove file: $path");
        file.deleteSync();
      }
    }
  }

  Future<void> clean() async {
    var directory = await getApplicationDocumentsDirectory();
    var dir = Directory([directory.path, "images"].join(Platform.pathSeparator));
    var ok = await dir.exists();
    if(ok) {
      dir.delete(recursive: true);
    }
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