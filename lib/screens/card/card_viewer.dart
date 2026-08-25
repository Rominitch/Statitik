import 'package:flutter/material.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/screens/card/card_body.dart';

class CardViewer extends StatefulWidget {
  final PokeCardViewerIdentifier cvId;

  const CardViewer.from(this.cvId, {super.key});

  @override
  State<CardViewer> createState() => _CardViewerState();
}

class _CardViewerState extends State<CardViewer> {
  late PageController _pageController;
  CardBody? viewer;

  @override
  void initState() {
    _pageController = PageController(keepPage: false, initialPage: widget.cvId.idCard.numberId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewer ??= CardBody(widget.cvId);

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.cvId.expansion.cards.cardList(widget.cvId.idCard).length,
      pageSnapping: true,
      onPageChanged: (position) {
        setState(() {
          final newIdCard = PokeCardViewerIdentifier(
            widget.cvId.expansion,
            widget.cvId.idCard.changeNumber(position),
            specificLanguage: widget.cvId.specificLanguage,
            idImage: widget.cvId.idImage
          );
          viewer = CardBody(newIdCard);
        });
      },
      itemBuilder: (context, position) {
        final newIdCard = PokeCardViewerIdentifier(
            widget.cvId.expansion,
            widget.cvId.idCard.changeNumber(position),
            specificLanguage: widget.cvId.specificLanguage,
            idImage: widget.cvId.idImage
        );
        viewer = CardBody(newIdCard);
        return viewer!;
      }
    );
  }
}