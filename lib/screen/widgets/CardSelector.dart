import 'package:flutter/material.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardSelector extends StatefulWidget {
  final PokemonCardExtension card;
  final BoosterDraw boosterDraw;
  final int      id;
  final Function refresh;
  final bool     isEnergy;
  final bool     readOnly;

  CardSelector(this.card, this.boosterDraw, this.id, this.refresh, this.isEnergy, this.readOnly);

  @override
  _CardSelectorState createState() => _CardSelectorState();
}

class _CardSelectorState extends State<CardSelector> {
  List<Widget> cardModes = [];

  @override
  void initState() {
    // Read code data
    CodeDraw code;
    if( widget.isEnergy  ) {
      code = widget.boosterDraw.cardDrawing!.drawEnergies[widget.id];
    } else {
      // WARNING: always work on first (migration)
      code = widget.boosterDraw.cardDrawing!.drawCards[widget.id][0];
    }

    // Create for all set each widget
    int idSet=0;
    cardModes.clear();
    widget.card.sets.forEach((set) {
      cardModes.add(IconCard(widget.boosterDraw, set, idSet, code, refresh: widget.refresh, readOnly: widget.readOnly));
      idSet += 1;
    });

    /*
    if( widget.isEnergy  ) {
      CodeDraw code = widget.boosterDraw.energiesBin[widget.id];
      cardModes =
      [
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Normal, refresh: widget.refresh, readOnly: widget.readOnly),
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh, readOnly: widget.readOnly),
      ];
    } else {
      // WARNING: always work on first (migration)
      var seCard = widget.boosterDraw.subExtension!.seCards;
      var card = seCard.cards[widget.id][0];
      bool forceEnable = widget.boosterDraw.abnormal || card.rarity == unknownRarity;

      CodeDraw code = widget.boosterDraw.cardDrawing!.draw[widget.id][0];
      if(widget.boosterDraw.subExtension!.extension.language.isJapanese())
        cardModes =
        [
          IconCard(boosterDraw: widget.boosterDraw, code: code, refresh: widget.refresh, readOnly: widget.readOnly),
          if( forceEnable || (seCard.hasAlternativeSet() && card.hasMultiSet())) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh, readOnly: widget.readOnly),
        ];
      else
        cardModes =
        [
          if( forceEnable || card.data.design != Design.Holographic) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Normal, refresh: widget.refresh, readOnly: widget.readOnly),
          if( forceEnable || card.hasMultiSet())                     IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh, readOnly: widget.readOnly),
          if( forceEnable || card.data.design == Design.Holographic) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Halo, refresh: widget.refresh, readOnly: widget.readOnly),
        ];
    }
*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Text(StatitikLocale.of(context).read('V_B4')),
        children: [Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: cardModes
        ),]
    );
  }
}

class IconCard extends StatefulWidget {
  final CardSet set;
  final BoosterDraw boosterDraw;
  final CodeDraw code;
  final Function refresh;
  final int setId;
  final bool readOnly;

  IconCard(this.boosterDraw, this.set, this.setId, this.code, {required this.refresh, required this.readOnly});

  @override
  _IconCardState createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  final Color? background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.code.getCountFrom(widget.setId);
    return  Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: count > 0 ? widget.set.color : background,
                child: TextButton(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Image(image: AssetImage('assets/carte/${widget.set.image}.png'), width: 75.0),
                        SizedBox(height: 6.0),
                        Text(widget.set.names.name(widget.boosterDraw.subExtension!.extension.language)),
                      ]),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                  onPressed: widget.readOnly ? null : () {
                    widget.boosterDraw.setOtherRendering(widget.code, widget.setId);
                    Navigator.of(context).pop();
                    widget.refresh();
                  },
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: widget.readOnly ? null : () {
                        setState(() {
                          widget.boosterDraw.increase(widget.code, widget.setId);
                        });
                        widget.refresh();
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
                          widget.boosterDraw.decrease(widget.code, widget.setId);
                        });
                        widget.refresh();
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
