import 'package:flutter/material.dart';

import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/CardSelector/CardSelectorBoosterDraw.dart';
import 'package:statitikcard/screen/widgets/PokemonCard.dart';
import 'package:statitikcard/services/Draw/BoosterDraw.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/TypeCard.dart';


class BoosterPage extends StatefulWidget {
  final BoosterDraw boosterDraw;
  final Language    language;
  final bool        readOnly;

  BoosterPage({required this.language, required this.boosterDraw, required this.readOnly});

  @override
  _BoosterPageState createState() => _BoosterPageState();
}

class _BoosterPageState extends State<BoosterPage> {
  List<Widget> widgets        = [];
  List<Widget> widgetEnergies = [];
  List<Widget> widgetNoNumber = [];

  @override
  void initState() {
    super.initState();

    createCards();
  }

  void createCards() {
    // Build one time all widgets
    Function refresh = () => setState( () {} );
    widgets = [];
    int idInBooster=0;
    for(var cards in widget.boosterDraw.subExtension!.seCards.cards) {
      var selector = CardSelectorBoosterDraw(widget.boosterDraw, cards[0], widget.boosterDraw.cardDrawing!.drawCards[idInBooster][0]);
      widgets.add( PokemonCard(selector, refresh:refresh, readOnly: widget.readOnly) );
      idInBooster += 1;
    }

    widgetEnergies = [];
    idInBooster=0;
    widget.boosterDraw.subExtension!.seCards.energyCard.forEach((card) {
      var selector = CardSelectorBoosterDraw(widget.boosterDraw, card, widget.boosterDraw.cardDrawing!.drawEnergies[idInBooster]);
      widgetEnergies.add( PokemonCard(selector, refresh:refresh, readOnly: widget.readOnly) );
      idInBooster += 1;
    });

    widgetNoNumber = [];
    idInBooster=0;
    widget.boosterDraw.subExtension!.seCards.noNumberedCard.forEach((card) {
      var selector = CardSelectorBoosterDraw(widget.boosterDraw, card, widget.boosterDraw.cardDrawing!.drawNoNumber[idInBooster]);
      widgetNoNumber.add( PokemonCard(selector, refresh:refresh, readOnly: widget.readOnly) );
      idInBooster += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = greenValid;
    Widget buttonLabel = Text(StatitikLocale.of(context).read('ok'));
    if(widget.boosterDraw.isFinished()) {
      switch(widget.boosterDraw.validationWorld(widget.language))
      {
        case Validator.ErrorEnergy:
          buttonColor = Colors.deepOrange;
          buttonLabel = Row(children:const [Icon(Icons.warning_amber_outlined), Icon(Icons.battery_charging_full)]);
          break;
        case Validator.ErrorReverse:
          buttonColor = Colors.deepOrange;
          buttonLabel = Row(children:const [Icon(Icons.warning_amber_outlined), Image(image: AssetImage('assets/carte/set_parallel.png'), height: 30.0)]);
          break;
        case Validator.ErrorTooManyGood:
          buttonColor = Colors.deepOrange;
          buttonLabel = Row(children:const [Icon(Icons.warning_amber_outlined), Icon(Icons.star_border)]);
          break;
        case Validator.Valid:
          break;
      }
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          title: Container(
            child: Row(
              children:[
                Text(StatitikLocale.of(context).read('S_B4')+' ${widget.boosterDraw.id}'),
                SizedBox(width: 10.0),
                widget.boosterDraw.subExtension!.image(hSize: iconSize),
                SizedBox(width: 10.0),
                widget.boosterDraw.abnormal
                ? Text('${widget.boosterDraw.count}')
                : Text('${widget.boosterDraw.count}/${widget.boosterDraw.nbCards}'),
              ],
            ),
          ),
          actions: [
            if(widget.boosterDraw.isFinished()) Card(
              color: buttonColor,
              child: TextButton(
              child: buttonLabel,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              ),
            )
          ],
        ),
        body:
         ListView(
            children: [
              if(widget.boosterDraw.subExtension!.seCards.hasBoosterEnergy())
                GridView.count(
                  crossAxisCount: 7,
                  primary: false,
                  shrinkWrap: true,
                  childAspectRatio: 1.2,
                  children: widgetEnergies,
                ),
              CheckboxListTile(
                title: Text(StatitikLocale.of(context).read('TB_B0')),
                subtitle: Text(StatitikLocale.of(context).read('TB_B1'), style: TextStyle(fontSize: 12)),
                value: widget.boosterDraw.abnormal,
                onChanged: widget.readOnly ? null : (newValue) async {
                    if(widget.boosterDraw.abnormal && widget.boosterDraw.needReset())
                    {
                      bool reset = await showDialog(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) { return showAlert(context); });

                      if(reset)
                      {
                        widget.boosterDraw.revertAnomaly();
                        setState(() { createCards(); });
                      }
                    } else { // Toggle
                      setState(() { widget.boosterDraw.abnormal = !widget.boosterDraw.abnormal; });
                    }
                },
              ),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                primary: false,
                childAspectRatio: 1.15,
                children: widgets,
              ),
              if(widgetNoNumber.isNotEmpty)
                GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  primary: false,
                  childAspectRatio: 1.15,
                  children: widgetNoNumber,
                ),
            ],
          ),
    );
  }
}
