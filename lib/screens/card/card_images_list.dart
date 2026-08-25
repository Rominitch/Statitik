import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/services/environment.dart';

class CardImagesList extends StatefulWidget {
  final List<PokeCardViewerIdentifier> ids;
  final PokeCardViewerIdentifier selection;

  const CardImagesList(this.ids, this.selection, {super.key});

  @override
  State<CardImagesList> createState() => _CardImagesListState();
}

class _CardImagesListState extends State<CardImagesList> with TickerProviderStateMixin {
  late TabController imagesController;

  @override
  void initState() {
    var index = max(0, widget.ids.indexWhere((element) => element.expansion == widget.selection.expansion && element.idCard.compareTo(widget.selection.idCard)==0));
    imagesController = TabController(length: widget.ids.length, initialIndex: index,
        vsync: this,
        animationDuration: Duration.zero
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rendering = Environment.instance.pkRendering();
    List<Widget> imageTabHeaders = [];
    List<Widget> imageTabPages   = [];
    for (var cvId in widget.ids) {
      var card = cvId.cardInExp();
      imageTabHeaders.add(
          Row(
              children: [
                cvId.expansion.image(cvId.specificLanguage!, wSize: 40, hSize: 40),
                const SizedBox(width: 2),
                rendering.iconFullDesign(cvId.cardDesign(), height: 26)
              ]
          )
      );
      imageTabPages.add(
          rendering.genericCardWidget(cvId, quality: FilterQuality.high, reloader: true,
            fit: BoxFit.fitWidth, photoView: true,
            language: cvId.specificLanguage!
          )
      );
    }

    return Column(
        children: [
          TabBar(
            controller: imagesController,
            indicatorPadding: const EdgeInsets.all(1),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
            tabs: imageTabHeaders,
            isScrollable: true,
          ),
          Expanded(
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: imagesController,
                children: imageTabPages
            ),
          ),
        ]
    );
  }
}