import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/widgets/widget/widget_icon_card.dart';
import 'package:statitikcard/widgets/widget/widget_image_set_counter.dart';

class WidgetSelectorCardDetails extends StatefulWidget {
  final PokeNavLanguage  nav;
  final PokeCardSelector cardSelector;

  final Function? refresh;
  final bool      readOnly;

  const WidgetSelectorCardDetails(this.nav, this.cardSelector, {super.key, this.refresh, this.readOnly=false});

  @override
  State<WidgetSelectorCardDetails> createState() => _WidgetSelectorCardDetailsState();
}

class _WidgetSelectorCardDetailsState extends State<WidgetSelectorCardDetails> {
  List<Widget> cardModes = [];

  @override
  void initState() {
    // Create for all set each widget
    cardModes.clear();
    if( !widget.cardSelector.fullSetsImages ) {
      widget.cardSelector.card().orderedSets().forEach((set) {
        cardModes.add(WidgetIconCard(widget.cardSelector, set, refresh: widget.refresh, readOnly: widget.readOnly));
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? advanced = widget.cardSelector.advancedWidget(context, () {setState(() {});} );
    if(! widget.cardSelector.fullSetsImages) {
      return SimpleDialog(
          title: Text(AppLocalizations.of(context)!.v_b4),
          children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: cardModes
            ),
            if(advanced != null) advanced
          ]
      );
    } else {
      const spacing = 2.0;
      cardModes = [];

      final card = widget.cardSelector.card();
      for (final set in card.orderedSets()) {
        List<Widget> wrapCard = [];
        final images = card.setInfo[set]!;
        for(int idImage=0; idImage < max(1, images.length); idImage+=1) {
          final cardImageId = PokeCardImageIdentifier(set, idImage);
          wrapCard.add(WidgetImageSetCounter(widget.nav.rendering, widget.cardSelector, cardImageId, refresh: widget.refresh, readOnly: widget.readOnly));
        }
        final setName = set.name(widget.nav.language);
        cardModes.add(
            Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                set.imageWidget(width: 18.0),
                                const SizedBox(width: 6.0),
                                Text(setName, maxLines: 2, softWrap: true, style: TextStyle(fontSize: setName.length > 10 ? 12 : 16)),
                              ]
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: wrapCard
                          )
                        ],
                      ),
                    ],
                  ),
                )
            )
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: cardModes
          ),
          ?advanced
        ],
      );
    }
  }
}