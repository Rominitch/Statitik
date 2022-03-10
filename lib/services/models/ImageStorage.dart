import 'dart:io';

import 'package:http/http.dart';
import 'package:http/retry.dart';

import 'package:mutex/mutex.dart';

import 'package:path_provider/path_provider.dart';

class ImageStorage {

  final m = Mutex();

  Future<String> imageLocalPath(List<String> folders, String file, String extension) async {
    final directory = await getApplicationDocumentsDirectory();
    return ([directory.path, ]+folders+["$file.$extension"]).join(Platform.pathSeparator);
  }

  Future<File?> storeImageToFile(String imageLocalPath, List<Uri> urls) async {
    var file;
    // Avoid multi connexion on servers (can reject program !)
    await m.protect(() async {
      for (var url in urls) {
        if(file == null) {
          // Try to download image
          final client = RetryClient(Client(), retries: 2);
          try {
            var ext = url.path.substring(url.path.length - 3);
            //printOutput("Try to extract: ${url.toString()} with ext= $ext");

            var bodyBytes = await client.readBytes(url);
            // Save on local
            file = File(imageLocalPath + ext);
            await file.create(recursive: true);
            await file.writeAsBytes(bodyBytes, flush: true);
          } catch(e) {
            //printOutput("HTTP: ERROR $e\n$stack");
          } finally {
            client.close();
          }
        }
      }
    });
    return file;
  }

  Future<File?> imageFromPath(List<String> folders, String fileName, List<Uri> urls) async {
    var imageLocale = await imageLocalPath(folders, fileName, "");
    var file = File(imageLocale+"png");
    var ok = await file.exists();
    if(!ok) {
      file = File(imageLocale+"jpg");
      ok = await file.exists();
    }

    if(ok) {
      return file;
    } else {
      return await storeImageToFile(imageLocale, urls);
    }
  }

  Future<void> clean() async {
    var directory = await getApplicationDocumentsDirectory();
    var dir = Directory([directory.path, "images"].join(Platform.pathSeparator));
    var ok = await dir.exists();
    if(ok)
      dir.delete(recursive: true);
  }
}