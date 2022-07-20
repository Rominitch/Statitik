import 'dart:io';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/ImageStorage.dart';

class ImageStoredLocally extends StatefulWidget {
  final List<Uri>    webAddress;
  final List<String> path;
  final String       imageName;

  final FilterQuality? quality;
  final double?      width;
  final double?      height;
  final Widget?      alternativeRendering;
  final bool         reloader;
  final BoxFit?      fit;

  const ImageStoredLocally(this.path, this.imageName, this.webAddress, {
    this.quality, this.width, this.height, this.alternativeRendering, this.reloader=false, this.fit, Key? key
  }) : super(key: key);

  @override
  State<ImageStoredLocally> createState() => _ImageStoredLocallyState();
}

class _ImageStoredLocallyState extends State<ImageStoredLocally> {
  void reloadImage() async {
    await Environment.instance.storage.cleanImageFile(widget.path, widget.imageName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
        future: Environment.instance.storage.imageFromPath(StorageData(widget.path, widget.imageName, widget.webAddress)), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
          try {
            if(snapshot.connectionState == ConnectionState.done) {
              if(snapshot.hasData ) {
                if (snapshot.data == null) {
                  return widget.alternativeRendering != null ? widget
                      .alternativeRendering! : const Icon(Icons.help_outline);
                } else {
                  var cardWidget = Image.file(
                      snapshot.data!,
                      width: widget.width, height: widget.height,
                      filterQuality: widget.quality ?? FilterQuality.medium,
                      fit: widget.fit,
                      errorBuilder: (context, error, stackTrace) {
                        printOutput("ImageStored: Error ${error.toString()}\n$stackTrace");
                        try {
                          reloadImage();

                          return Card(child: IconButton(
                            onPressed: () {
                              setState(() {});
                            },
                            icon: const Icon(Icons.rotate_left),
                          ) );
                        }
                        catch(error) {
                          return const Icon(Icons.bug_report_outlined);
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
              else {
                return widget.alternativeRendering != null ? widget
                    .alternativeRendering! : const Icon(Icons.help_outline);
              }
            }
            else {
              return CircularProgressIndicator(color: Colors.orange[300]);
            }
          }
          catch(error) {
            return CircularProgressIndicator(color: Colors.orange[300]);
          }
        }

    );
  }
}