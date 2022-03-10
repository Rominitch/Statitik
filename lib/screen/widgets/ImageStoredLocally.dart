import 'dart:io';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';

class ImageStoredLocally extends StatefulWidget {
  final Uri          webAddress;
  final List<String> path;
  final String       imageName;

  final double?      width;
  final double?      height;
  final Widget?      alternativeRendering;

  const ImageStoredLocally(this.path, this.imageName, this.webAddress, {this.width, this.height, this.alternativeRendering});

  @override
  State<ImageStoredLocally> createState() => _ImageStoredLocallyState();
}

class _ImageStoredLocallyState extends State<ImageStoredLocally> {
  bool loading = true;
  File? image;
  bool close=false;

  @override
  void dispose() {
    close = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if( image == null ) {
      //printOutput("Start show Image");
      Environment.instance.storage.imageFromPath(widget.path, widget.imageName, [widget.webAddress]).then((finalImage) {
        if(finalImage != null) {
          image = finalImage;
          //printOutput("File read: ${widget.idCard} = ${image!.path.toString()}");
        }
        if(!close) {
          setState(() {
            loading = false;
          });
        }
      }).whenComplete(() {
        if(!close) {
          setState(() {});
        }
      }).onError((error, stackTrace) {
        if(!close) {
          setState(() {
            loading = false;
          });
        }
      });
    }

    return loading
        ? CircularProgressIndicator(color: Colors.orange[300])
        : ((image != null)
        ? Image.file(image!, width: widget.width, height: widget.height) : (widget.alternativeRendering!= null ? widget.alternativeRendering! : Icon(Icons.help_outline)));
  }
}