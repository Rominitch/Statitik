import 'package:flutter/material.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardSelector extends StatefulWidget {
  final BoosterDraw boosterDraw;
  final int      id;
  final Function refresh;
  final bool isEnergy;

  CardSelector(this.boosterDraw, this.id, this.refresh, this.isEnergy);

  @override
  _CardSelectorState createState() => _CardSelectorState();
}

class _CardSelectorState extends State<CardSelector> {
  List<Widget> cardModes;

  @override
  void initState() {

    if( widget.isEnergy  ) {
      CodeDraw code = widget.boosterDraw.energiesBin[widget.id];
      cardModes =
      [
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Normal, refresh: widget.refresh),
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh),
      ];
    } else {
      PokeCard card = widget.boosterDraw.subExtension.cards[widget.id];
      CodeDraw code = widget.boosterDraw.cardBin[widget.id];
      cardModes =
      [
        if( card.rarity != Rarity.HoloRare) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Normal, refresh: widget.refresh),
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh),
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Halo, refresh: widget.refresh),
      ];
    }

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
  final BoosterDraw boosterDraw;
  final CodeDraw code;
  final Function refresh;
  final Mode mode;

  IconCard({this.boosterDraw, this.code, this.mode, this.refresh});

  @override
  _IconCardState createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  final Color background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.code.getCountFrom(widget.mode);
    return  Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: count > 0 ? modeColors[widget.mode] : background,
                child: FlatButton(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Image(image: AssetImage('assets/carte/${modeImgs[widget.mode]}.png'), width: 75.0),
                        SizedBox(height: 6.0),
                        Text(modeNames[widget.mode]),
                      ]),
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  onPressed: () {
                    widget.boosterDraw.setOtherRendering(widget.code, widget.mode);
                    Navigator.of(context).pop();
                    widget.refresh();
                  },
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  RaisedButton(
                      onPressed: () {
                        setState(() {
                          widget.boosterDraw.increase(widget.code, widget.mode);
                        });
                        widget.refresh();
                      },
                      color: background,
                      child: Container(
                        child: Text('+', style: TextStyle(fontSize: 20)),
                      )
                  ),
                  Container(
                      child: Text('$count', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),)
                  ),
                  RaisedButton(
                      onPressed: () {
                        setState(() {
                          widget.boosterDraw.decrease(widget.code, widget.mode);
                        });
                        widget.refresh();
                      },
                      color: background,
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
