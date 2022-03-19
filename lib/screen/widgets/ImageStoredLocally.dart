import 'dart:io';

import 'package:flutter/material.dart';
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
  bool force=false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
        future: Environment.instance.storage.imageFromPath(StorageData(widget.path, widget.imageName, widget.webAddress, force: force)), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
          if(snapshot.hasData ) {
            force = true;
            if (snapshot.data == null)
              return widget.alternativeRendering != null ? widget
                  .alternativeRendering! : Icon(Icons.help_outline);
            else {
              var cardWidget = Image.file(
                snapshot.data!, width: widget.width,
                height: widget.height,
                errorBuilder: (context, error, stackTrace) {
                  setState(() {
                    force = true;
                  });
                  return CircularProgressIndicator(color: Colors.orange[300]);
                }
              );
              return widget.reloader ?
                GestureDetector(
                  onLongPress: () {
                    // Reload widget
                    setState(() {
                      force = true;
                    });
                  },
                  child: cardWidget
                ) : cardWidget;
            }
          }
          else
            return CircularProgressIndicator(color: Colors.orange[300]);
        }
    );
  }
}