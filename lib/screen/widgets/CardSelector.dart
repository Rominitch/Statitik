import 'package:flutter/material.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardSelector extends StatefulWidget {
  final SubExtension         subExtension;
  final PokemonCardExtension card;
  final CodeDraw             counter;

  final BoosterDraw? boosterDraw;
  //final int      id;
  final Function? refresh;
  //final bool     isEnergy;
  final bool     readOnly;

  CardSelector.fromDraw(this.card, this.counter, boosterDraw, {this.refresh, this.readOnly=false}):
    this.boosterDraw  = boosterDraw,
    this.subExtension = boosterDraw.creation!;

  CardSelector(this.subExtension, this.card, this.counter, {this.boosterDraw, this.refresh, this.readOnly=false});

  @override
  _CardSelectorState createState() => _CardSelectorState();
}

class _CardSelectorState extends State<CardSelector> {
  List<Widget> cardModes = [];

  @override
  void initState() {
    // Read code data
/*
    CodeDraw code;
    if( widget.isEnergy  ) {
      code = widget.boosterDraw.cardDrawing!.drawEnergies[widget.id];
    } else {
      // WARNING: always work on first (migration)
      code = widget.boosterDraw.cardDrawing!.drawCards[widget.id][0];
    }
*/
    // Create for all set each widget
    int idSet=0;
    cardModes.clear();
    widget.card.sets.forEach((set) {
      if(widget.boosterDraw != null) {
        cardModes.add(IconCard.fromDraw(widget.boosterDraw!, widget.subExtension, set, idSet, widget.counter, refresh: widget.refresh, readOnly: widget.readOnly));
      } else {
        cardModes.add(IconCard(widget.subExtension, set, idSet, widget.counter, refresh: widget.refresh, readOnly: widget.readOnly));
      }
      idSet += 1;
    });
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

  final BoosterDraw? boosterDraw;
  final SubExtension  subExtension;
  final CardSet       set;

  final int           setId;
  final CodeDraw      code;

  final Function?     refresh;
  final bool          readOnly;

  IconCard(this.subExtension, this.set, this.setId, this.code, {required this.refresh, required this.readOnly}) :
    this.boosterDraw = null;

  IconCard.fromDraw(this.boosterDraw, this.subExtension, this.set, this.setId, this.code, {required this.refresh, required this.readOnly});

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
                        Text(widget.set.names.name(widget.subExtension.extension.language)),
                      ]),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                  onPressed: widget.readOnly ? null : () {
                    if(widget.boosterDraw != null)
                      widget.boosterDraw!.setOtherRendering(widget.code, widget.setId);
                    else
                      widget.code.countBySet[widget.setId] += 1;

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
                          if(widget.boosterDraw != null)
                            widget.boosterDraw!.increase(widget.code, widget.setId);
                          else if(widget.code.countBySet[widget.setId] < 256)
                            widget.code.countBySet[widget.setId] += 1;
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
                          if(widget.boosterDraw != null)
                            widget.boosterDraw!.decrease(widget.code, widget.setId);
                          else if(widget.code.countBySet[widget.setId] > 0)
                            widget.code.countBySet[widget.setId] -= 1;
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
