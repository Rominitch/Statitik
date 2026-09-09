import 'package:flutter/material.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/widgets/widget/widget_selector_card_details.dart';

class WidgetSelectorCardViewer extends StatefulWidget {
  final PokeNavLanguage      _nav;
  final PokeCardSelector     selector;

  final Function             refresh;
  final Function?            afterOpenSelector;
  final bool                 readOnly;
  final bool                 singlePress;   // Access to menu with single press

  const WidgetSelectorCardViewer(this._nav, this.selector, { required this.refresh, required this.readOnly, this.singlePress=false, this.afterOpenSelector, super.key});

  @override
  State<WidgetSelectorCardViewer> createState() => _WidgetSelectorCardViewerState();
}

class _WidgetSelectorCardViewerState extends State<WidgetSelectorCardViewer> {
  late List<Widget> icons;

  @override
  void initState() {
    final card = widget.selector.card();
    icons =
    [
      Row( mainAxisAlignment: MainAxisAlignment.center,
           children: [card.imageType()] + widget._nav.rendering.imageRarity(card.rarity)),
      const SizedBox(height: 6.0),
    ];
    super.initState();
  }

  void update() {
    setState(() {});
    widget.refresh();
  }
  void showSelectorDialog() {
    if(widget.selector.specialButtonAction() != null) {
      widget.selector.specialButtonAction()!(context);
    } else {
      if(widget.selector.fullSetsImages) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,//const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                child: WidgetSelectorCardDetails(widget._nav, widget.selector, refresh: update, readOnly: widget.readOnly),
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
              return WidgetSelectorCardDetails(
                  widget._nav, widget.selector, refresh: update, readOnly: widget.readOnly);
            }
        ).then((value) {
          if (widget.afterOpenSelector != null) {
            widget.afterOpenSelector!();
          }
          widget.refresh();
        });
      }
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
          child: widget.selector.cardWidget(widget._nav)
      ),
    );
  }
}