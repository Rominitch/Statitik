
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/services/environment.dart';

class CardImage extends StatefulWidget {
  final PokeCardViewerIdentifier cvId;
  final double              height;
  final List<Uri>           cardImage;

  CardImage(this.cvId, {this.height=400, super.key}) :
    cardImage = cvId.computeImageURI(Environment.instance.pkConfig().showTCGImages);

  @override
  State<CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<CardImage> {
  StreamController<int> onURLError = StreamController<int>();

  @override
  void initState() {
    onURLError.stream.listen((event) {
      setState(() {
        widget.cardImage.removeAt(0);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    onURLError.close();
    super.dispose();
  }

  Widget buildCachedImage([bool admin=false]) {
    var img = widget.cvId.cardDesign();
    if(widget.cardImage.isNotEmpty) {
      // Save current name (to avoid search in future)
      img.finalImage = widget.cardImage.first.toString();

      // Show image if possible
      return CachedNetworkImage(
        imageUrl: widget.cardImage.first.toString(),
        errorWidget: (context, url, error) {
          img.resetCache();
          onURLError.add(0);
          return const Icon(Icons.help_outline);
        },
        filterQuality: widget.height > 300 ? FilterQuality.low : FilterQuality.medium,
        placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
        height: widget.height,
      );
    } else {
      return Center(child: Text(widget.cvId.readTitleOfCard()));
    }
  }
  @override
  Widget build(BuildContext context) {
    if(Environment.instance.isAdministrator()) {
      var img = widget.cvId.cardInExp().tryGetImage(widget.cvId.idImage!);
      return Tooltip(
          message: img.finalImage.isNotEmpty ? img.finalImage : widget.cardImage.join("\n"),
          child: buildCachedImage(true)
      );
    } else {
      return buildCachedImage();
    }
  }
}