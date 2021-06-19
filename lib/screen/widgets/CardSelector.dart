import 'package:flutter/material.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardSelector extends StatefulWidget {
  final BoosterDraw boosterDraw;
  final int      id;
  final Function refresh;
  final bool     isEnergy;
  final bool     readOnly;

  CardSelector(this.boosterDraw, this.id, this.refresh, this.isEnergy, this.readOnly);

  @override
  _CardSelectorState createState() => _CardSelectorState();
}

class _CardSelectorState extends State<CardSelector> {
  late List<Widget> cardModes;

  @override
  void initState() {

    if( widget.isEnergy  ) {
      CodeDraw code = widget.boosterDraw.energiesBin[widget.id];
      cardModes =
      [
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Normal, refresh: widget.refresh, readOnly: widget.readOnly),
        IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh, readOnly: widget.readOnly),
      ];
    } else {
      PokeCard card = widget.boosterDraw.subExtension!.info().cards[widget.id];
      CodeDraw code = widget.boosterDraw.cardBin![widget.id];
      cardModes =
      [
        if( widget.boosterDraw.abnormal || card.rarity != Rarity.HoloRare) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Normal, refresh: widget.refresh, readOnly: widget.readOnly),
        if( widget.boosterDraw.abnormal || card.rarity.index <= Rarity.HoloRare.index) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Reverse, refresh: widget.refresh, readOnly: widget.readOnly),
        if( widget.boosterDraw.abnormal || card.rarity == Rarity.HoloRare) IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Halo, refresh: widget.refresh, readOnly: widget.readOnly),
        if( widget.boosterDraw.abnormal || card.hasAlternative)            IconCard(boosterDraw: widget.boosterDraw, code: code, mode: Mode.Alternative, refresh: widget.refresh, readOnly: widget.readOnly),
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
  final bool readOnly;

  IconCard({required this.boosterDraw, required this.code, required this.mode, required this.refresh, required this.readOnly});

  @override
  _IconCardState createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  final Color? background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.code.getCountFrom(widget.mode);
    return  Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: count > 0 ? modeColors[widget.mode] : background,
                child: TextButton(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Image(image: AssetImage('assets/carte/${modeImgs[widget.mode]}.png'), width: 75.0),
                        SizedBox(height: 6.0),
                        Text(StatitikLocale.of(context).read(modeNames[widget.mode])),
                      ]),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                  onPressed: widget.readOnly ? null : () {
                    widget.boosterDraw.setOtherRendering(widget.code, widget.mode);
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
                          widget.boosterDraw.increase(widget.code, widget.mode);
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
                          widget.boosterDraw.decrease(widget.code, widget.mode);
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
