import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const CardSelector(this.cardSelector, {Key? key, this.refresh, this.readOnly=false}) : super(key: key);

  @override
  State<CardSelector> createState() => _CardSelectorState();
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
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? advanced = widget.cardSelector.advancedWidget(context, () {setState(() {});} );
    if(! widget.cardSelector.fullSetsImages) {
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
      const spacing = 2.0;
      cardModes = [];

      int idSet=0;
      var card = widget.cardSelector.cardExtension();
      card.sets.forEach((set) {
        List<Widget> wrapCard = [];
        for(int idImage=0; idImage < max(1, card.images[idSet].length); idImage+=1) {
          var cardImageId = CardImageIdentifier(idSet, idImage);
          wrapCard.add(ImageSetCounter(widget.cardSelector, cardImageId, refresh: widget.refresh, readOnly: widget.readOnly));
        }
        var setName = set.names.name(widget.cardSelector.subExtension().extension.language);
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
        idSet += 1;
      });

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: cardModes
          ),
          if(advanced != null) advanced
        ],
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

  const IconCard(this.cardSelector, this.setId, this.set, {Key? key, required this.refresh, required this.readOnly}) : super(key: key);

  @override
  State<IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  final Color? background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.cardSelector.codeDraw().getCountFrom(widget.setId);
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
            color: count > 0 ? widget.set.color : background,
            child: TextButton(
              style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
              onPressed: widget.readOnly ? null : () {
                widget.cardSelector.setOnly(widget.setId);

                Navigator.of(context).pop();
                if(widget.refresh!=null) {
                  widget.refresh!();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [widget.set.imageWidget(width: 75.0),
                  const SizedBox(height: 6.0),
                  Text(widget.set.names.name(widget.cardSelector.subExtension().extension.language)),
                ]
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton(
                onPressed: widget.readOnly ? null : () {
                  setState(() {
                    widget.cardSelector.increase(widget.setId);
                  });
                  if(widget.refresh!=null) {
                    widget.refresh!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: background, // background
                ),
                child: const Text('+', style: TextStyle(fontSize: 20))
              ),
              Text('$count', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),),
              ElevatedButton(
                  onPressed: widget.readOnly ? null : () {
                    setState(() {
                      widget.cardSelector.decrease(widget.setId);
                    });
                    if(widget.refresh!=null) {
                      widget.refresh!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: background, // background
                  ),
                  child: const Text('-', style: TextStyle(fontSize: 20))
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

  const ImageSetCounter(this.cardSelector, this.imageId, {required this.refresh, required this.readOnly, Key? key}) : super(key: key);

  @override
  State<ImageSetCounter> createState() => _ImageSetCounterState();
}

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {

    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}

class _ImageSetCounterState extends State<ImageSetCounter> {
  late CardImageIdentifier designId;
  late TextEditingController textController;

  @override
  void initState() {
    var card = widget.cardSelector.cardExtension();
    designId = card.images[widget.imageId.idSet].isEmpty
        ? CardImageIdentifier(0, 0) // Show always first valid image
        : CardImageIdentifier(widget.imageId.idSet, widget.imageId.idImage);
    var count = widget.cardSelector.codeDraw().getCountFrom(widget.imageId.idSet, widget.imageId.idImage);
    textController = TextEditingController(text: count.toString());
    super.initState();
  }

  int countCard() {
    return widget.cardSelector.codeDraw().getCountFrom(widget.imageId.idSet, widget.imageId.idImage);
  }

  @override
  Widget build(BuildContext context) {
    const splashRadius = 14.0;
    const iconPadding  = 2.0;
    const iconSize  = 20.0;
    var card  = widget.cardSelector.cardExtension();
    var count = countCard();

    return SizedBox(
      width: 100.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              card.tryGetImage(designId).cardDesign.icon(width: iconSize, height: iconSize)
            ]
          ),
          const SizedBox(height: 3.0),
          genericCardWidget( widget.cardSelector.subExtension(), widget.cardSelector.cardIdentifier(), designId, height: 110, language: widget.cardSelector.subExtension().extension.language ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.all(iconPadding),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: (){
                  widget.cardSelector.decrease(widget.imageId.idSet, widget.imageId.idImage);
                  textController.text = countCard().toString();
                },
                splashRadius: splashRadius,
              ),
              Expanded(child:
                TextField(
                  controller: textController,
                  inputFormatters: [
                    NumericalRangeFormatter(min: 0, max: 255),
                  ],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 3,
                  onSubmitted: (String value) {
                    var finalValue = max(0, min(int.parse(value.isEmpty ? "0" : value), 255));
                    widget.cardSelector.codeDraw().setCount(finalValue, widget.imageId.idSet, widget.imageId.idImage);
                  },
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      color: count > 0 ? Colors.green.shade300 : Colors.white
                  ),
                  decoration: const InputDecoration(border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    counterText: "",
                  ),
                )
              ),
              IconButton(icon: const Icon(Icons.add_circle_outline),
                padding: const EdgeInsets.all(iconPadding),
                constraints: const BoxConstraints(),
                onPressed: (){
                  widget.cardSelector.increase(widget.imageId.idSet, widget.imageId.idImage);
                  textController.text = countCard().toString();
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

