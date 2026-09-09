import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/services/environment.dart';

class ImageWithDecoration extends StatefulWidget {
  final double height;
  final PokeExpansion se;
  final PokeCardInExpansion card;
  final PokeCardIdentifier idCard;
  final PokeLanguage? language;
  final PokeCardImageIdentifier idImage;
  final PokeCardViewerIdentifier view;


  ImageWithDecoration(this.se, this.card, this.idCard, this.idImage, {this.height=400, required this.language, super.key}) :
        view = PokeCardViewerIdentifier(se, idCard, idImage: idImage, specificLanguage: language);

  @override
  State<ImageWithDecoration> createState() => _ImageWithDecorationState();
}

class _ImageWithDecorationState extends State<ImageWithDecoration> {
  StreamController<int> onURLError = StreamController<int>();
  List<Uri> imagesURI = [];

  @override
  void initState() {
    imagesURI = widget.view.computeImageURI(true);

    onURLError.stream.listen((event) {
      setState(() {
        imagesURI.removeAt(0);
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
    var img = widget.card.tryGetImage(widget.idImage)!;
    if(imagesURI.isNotEmpty) {
      // Save current name (to avoid search in future)
      img.finalImage = imagesURI.first.toString();

      // Show image if possible
      return CachedNetworkImage(
        imageUrl: imagesURI.first.toString(),
        errorWidget: (context, url, error) {
          img.finalImage = "";
          if(admin && widget.language!.code() == "JP") {
            widget.card.tryGetImage(widget.idImage)!.jpDBId = 0;
          }
          onURLError.add(0);
          return const Icon(Icons.help_outline);
        },
        filterQuality: widget.height > 300 ? FilterQuality.low : FilterQuality.medium,
        placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
        height: widget.height,
      );
    } else {
      return widget.language != null
          ? Center(child: Text(widget.se.cards.readTitleOfCard(widget.language!, widget.idCard)))
          : const Icon(Icons.help_outline);
    }
  }
  @override
  Widget build(BuildContext context) {
    if(Environment.instance.isAdministrator()) {
      var img = widget.card.tryGetImage(widget.idImage)!;
      return Tooltip(
          message: img.finalImage.isNotEmpty ? img.finalImage : imagesURI.join("\n"),
          child: buildCachedImage(true)
      );
    } else {
      return buildCachedImage();
    }
  }
}