import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';

class PokemonCard extends StatefulWidget {
  final GenericCardSelector  selector;

  final Function             refresh;
  final Function?            afterOpenSelector;
  final bool                 readOnly;
  final bool                 singlePress;   // Access to menu with single press

  const PokemonCard(this.selector, { required this.refresh, required this.readOnly, this.singlePress=false, this.afterOpenSelector, Key? key}) : super(key: key);

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late List<Widget> icons;

  @override
  void initState() {
    var card = widget.selector.cardExtension();
    icons =
    [
      if(card.isValid())
        Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [card.imageType()] + card.imageRarity(widget.selector.subExtension().extension.language)),
      if(card.isValid()) const SizedBox(height: 6.0),
    ];
    super.initState();
  }

  void update() {
    setState(() {});
    widget.refresh();
  }

  void showSelectorDialog() {
    if(widget.selector.fullSetsImages) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,//const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
            child: CardSelector(widget.selector, refresh: update, readOnly: widget.readOnly),
          );
        }
      ).then((value) {
        // Refresh card info
        setState(()
        {
          if(widget.afterOpenSelector != null) {
            widget.afterOpenSelector!();
          }
          widget.refresh();
        });
      });
    } else {
      // Show more info if many rendering of more cards
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CardSelector(
            widget.selector, refresh: update, readOnly: widget.readOnly);
        }
      ).then((value) {
        if (widget.afterOpenSelector != null) {
          widget.afterOpenSelector!();
        }
        widget.refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: widget.selector.backgroundColor(),
          padding: const EdgeInsets.all(2.0)
        ),
        onLongPress: showSelectorDialog,
        onPressed: widget.readOnly ? null : (widget.singlePress ? showSelectorDialog :
          () {
            setState(() {
              // WARNING: default press is always on first set
              widget.selector.toggle();

              widget.refresh();
            });
        }),
        child: widget.selector.cardWidget()
      ),
    );
  }
}