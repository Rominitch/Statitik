import 'dart:io';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/ImageStorage.dart';

class ImageStoredLocally extends StatefulWidget {
  final List<Uri>    webAddress;
  final List<String> path;
  final String       imageName;

  final double?      width;
  final double?      height;
  final Widget?      alternativeRendering;
  final bool         reloader;

  const ImageStoredLocally(this.path, this.imageName, this.webAddress, {this.width, this.height, this.alternativeRendering, this.reloader=false});

  @override
  State<ImageStoredLocally> createState() => _ImageStoredLocallyState();
}

class _ImageStoredLocallyState extends State<ImageStoredLocally> {
  void reloadImage() async {
    var path = await Environment.instance.storage.imageLocalPath(widget.path, widget.imageName, "png");
    var file = File(path);
    bool hasFile = file.existsSync();
    if( !hasFile ) {
      path = await Environment.instance.storage.imageLocalPath(widget.path, widget.imageName, "jpg");
      file = File(path);
      hasFile = file.existsSync();
    }

    if(hasFile) {
      file.deleteSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
        future: Environment.instance.storage.imageFromPath(StorageData(widget.path, widget.imageName, widget.webAddress)), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
          printOutput("Image state: ${snapshot.hasData.toString()} connexion: ${snapshot.connectionState.toString()}");
          if(snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasData ) {
              if (snapshot.data == null)
                return widget.alternativeRendering != null ? widget
                    .alternativeRendering! : Icon(Icons.help_outline);
              else {
                var cardWidget = Image.file(
                  snapshot.data!, width: widget.width,
                  height: widget.height,
                  errorBuilder: (context, error, stackTrace) {
                    try {
                      reloadImage();

                      return Card(child: IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: Icon(Icons.rotate_left),
                      ) );
                    }
                    catch(error) {
                      return Icon(Icons.bug_report_outlined);
                    }
                  }
                );
                return widget.reloader ?
                  GestureDetector(
                    onLongPress: () {
                      // Reload widget
                      reloadImage();
                      setState(() {});
                    },
                    child: cardWidget
                  ) : cardWidget;
              }
            }
          else
            return widget.alternativeRendering != null ? widget
                .alternativeRendering! : Icon(Icons.help_outline);
          }
          else return CircularProgressIndicator(color: Colors.orange[300]);
        }
    );
  }
}