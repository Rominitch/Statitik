import 'package:flutter/material.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

abstract class GenericCardSelector {

  GenericCardSelector();

  SubExtension         subExtension();
  PokemonCardExtension cardExtension();
  CodeDraw             codeDraw();

  void increase(int idSet);
  void decrease(int idSet);
  void setOnly(int idSet);

  Widget? advancedWidget(BuildContext context, Function refresh);

  Color backgroundColor();
  Widget cardWidget();

  void toggle();
}

class CardSelector extends StatefulWidget {
  final GenericCardSelector cardSelector;

  final Function? refresh;
  final bool     readOnly;

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
    widget.cardSelector.cardExtension().sets.forEach((set) {
      cardModes.add(IconCard(widget.cardSelector, idSet, set, refresh: widget.refresh, readOnly: widget.readOnly));
      idSet += 1;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? advanced = widget.cardSelector.advancedWidget(context, () {setState(() {})} );
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
