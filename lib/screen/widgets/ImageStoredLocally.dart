import 'dart:async';
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
  bool loading = true;
  File? image;
  StreamController afterLoad = new StreamController();

  @override
  void initState() {
    afterLoad = new StreamController();
    afterLoad.stream.listen((data) async {
      image = await Environment.instance.storage.imageFromPath(data);
      loading = false;
      if(!afterLoad.isClosed) {
        setState(() {});
      }
    }, onDone: () {
      loading = false;
    }, onError: (error) {
      loading = false;
      if(!afterLoad.isClosed) {
        setState(() {});
      }
    });

    afterLoad.add(StorageData(afterLoad, widget.path, widget.imageName, widget.webAddress));

    super.initState();
  }

  @override
  void dispose() {
    afterLoad.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(loading)
      return CircularProgressIndicator(color: Colors.orange[300]);
    else {
      if(image != null) {
        return widget.reloader ?
          GestureDetector(
              onLongPress: () {
                setState(() {
                  loading = true;
                });
                afterLoad.add(StorageData(afterLoad, widget.path, widget.imageName, widget.webAddress, force: true));
              },
              child: Image.file(image!, width: widget.width, height: widget.height)
          )
        : Image.file(image!, width: widget.width, height: widget.height);
      } else {
        return widget.alternativeRendering!= null ? widget.alternativeRendering! : Icon(Icons.help_outline);
      }
    }
  }
}