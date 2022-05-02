import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

abstract class GenericCardSelector {
  bool fullSetsImages=false;

  GenericCardSelector();

  SubExtension         subExtension();
  CardIdentifier       cardIdentifier();
  PokemonCardExtension cardExtension();
  CodeDraw             codeDraw();

  void increase(int idSet, [int idImage=0]);
  void decrease(int idSet, [int idImage=0]);
  void setOnly(int idSet, [int idImage=0]);

  Widget? advancedWidget(BuildContext context, Function refresh);

  Color backgroundColor();
  Widget cardWidget();

  void toggle();
}

class CardSelector extends StatefulWidget {
  final GenericCardSelector cardSelector;

  final Function? refresh;
  final bool      readOnly;

  CardSelector(this.cardSelector, {this.refresh, this.readOnly=false});

  @override
  _CardSelectorState createState() => _CardSelectorState();
}

class _CardSelectorState extends State<CardSelector> {
  List<Widget> cardModes = [];

  @override
  void initState() {
    // Create for all set each widget
    int idSet=0;
    cardModes.clear();
    if( !widget.cardSelector.fullSetsImages ) {
      widget.cardSelector.cardExtension().sets.forEach((set) {
        cardModes.add(IconCard(widget.cardSelector, idSet, set, refresh: widget.refresh, readOnly: widget.readOnly));
        idSet += 1;
      });
    } else {
      var card = widget.cardSelector.cardExtension();
      card.sets.forEach((set) {
        List<Widget> wrapCard = [];
        for(int idImage=0; idImage < max(1, card.images[idSet].length); idImage+=1) {
          var cardImageId = CardImageIdentifier(idSet, idImage);
          wrapCard.add(ImageSetCounter(widget.cardSelector, cardImageId, refresh: widget.refresh, readOnly: widget.readOnly));
        }

        cardModes.add(
          Card(child:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        set.imageWidget(width: 20.0),
                        SizedBox(width: 6.0),
                        Text(set.names.name(widget.cardSelector
                            .subExtension()
                            .extension
                            .language)),
                      ]
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                      children: wrapCard
                  )
                ],
              ),
            )
          )
        );
        idSet += 1;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(! widget.cardSelector.fullSetsImages) {
      Widget? advanced = widget.cardSelector.advancedWidget(context, () {setState(() {});} );
      return SimpleDialog(
        title: Text(StatitikLocale.of(context).read('V_B4')),
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
      return Wrap(
        children: cardModes
      );
    }
  }
}

class IconCard extends StatefulWidget {
  final GenericCardSelector cardSelector;
  final int           setId;
  final CardSet       set;

  final Function?     refresh;
  final bool          readOnly;

  IconCard(this.cardSelector, this.setId, this.set, {required this.refresh, required this.readOnly});

  @override
  _IconCardState createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  final Color? background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.cardSelector.codeDraw().getCountFrom(widget.setId);
    return  Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: count > 0 ? widget.set.color : background,
                child: TextButton(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [widget.set.imageWidget(width: 75.0),
                        SizedBox(height: 6.0),
                        Text(widget.set.names.name(widget.cardSelector.subExtension().extension.language)),
                      ]),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                  onPressed: widget.readOnly ? null : () {
                    widget.cardSelector.setOnly(widget.setId);

                    Navigator.of(context).pop();
                    if(widget.refresh!=null)
                      widget.refresh!();
                  },
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: widget.readOnly ? null : () {
                        setState(() {
                          widget.cardSelector.increase(widget.setId);
                        });
                        if(widget.refresh!=null)
                          widget.refresh!();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: background, // background
                      ),
                      child: Container(
                        child: Text('+', style: TextStyle(fontSize: 20)),
                      )
                  ),
                  Container(
                      child: Text('$count', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),)
                  ),
                  ElevatedButton(
                      onPressed: widget.readOnly ? null : () {
                        setState(() {
                          widget.cardSelector.decrease(widget.setId);
                        });
                        if(widget.refresh!=null)
                          widget.refresh!();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: background, // background
                      ),
                      child: Container(
                        child: Text('-', style: TextStyle(fontSize: 20)),
                      )
                  ),
                ],
              )
            ],
          )
      );
  }
}

class ImageSetCounter extends StatefulWidget {
  final GenericCardSelector cardSelector;
  final CardImageIdentifier imageId;

  final Function?     refresh;
  final bool          readOnly;

  const ImageSetCounter(this.cardSelector, this.imageId, {required this.refresh, required this.readOnly});

  @override
  State<ImageSetCounter> createState() => _ImageSetCounterState();
}

class _ImageSetCounterState extends State<ImageSetCounter> {
  late CardImageIdentifier designId;

  @override
  void initState() {
    var card = widget.cardSelector.cardExtension();
    designId = card.images[widget.imageId.idSet].isEmpty
        ? CardImageIdentifier(0, 0) // Show always first valid image
        : CardImageIdentifier(widget.imageId.idSet, widget.imageId.idImage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const splashRadius = 14.0;
    const iconPadding  = 2.0;
    var card  = widget.cardSelector.cardExtension();
    var count = widget.cardSelector.codeDraw().getCountFrom(widget.imageId.idSet, widget.imageId.idImage);
    return Container(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardImage(widget.cardSelector.subExtension(), card, widget.cardSelector.cardIdentifier(), designId, height: 110),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.all(iconPadding),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: (){
                  setState(() {
                    widget.cardSelector.decrease(widget.imageId.idSet, widget.imageId.idImage);
                  });
                },
                splashRadius: splashRadius,
              ),
              Expanded(child:
                Text(count.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: count > 199 ? 26 : 27, fontWeight: FontWeight.bold,
                    color: count > 0 ? Colors.green.shade300 : Colors.white)
                )
              ),
              IconButton(icon: const Icon(Icons.add_circle_outline),
                padding: const EdgeInsets.all(iconPadding),
                constraints: const BoxConstraints(),
                onPressed: (){
                  setState(() {
                    widget.cardSelector.increase(widget.imageId.idSet, widget.imageId.idImage);
                  });
                },
                splashRadius: splashRadius,
              )
            ]
          ),
        ]
      ),
    );
  }
}

