import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class BoosterPage extends StatefulWidget {
  final BoosterDraw boosterDraw;
  final Language    language;

  BoosterPage({required this.language, required this.boosterDraw});

  @override
  _BoosterPageState createState() => _BoosterPageState();
}

class _BoosterPageState extends State<BoosterPage> {
  late List<Widget> widgets;
  late List<Widget> widgetEnergies;

  @override
  void initState() {
    super.initState();

    createCards();
  }

  void createCards() {
    // Build one time all widgets
    Function refresh = () => setState( () {} );
    widgets = [];
    int id=0;
    for(PokeCard card in widget.boosterDraw.subExtension!.info().cards) {
      widgets.add( PokemonCard(card: card, idCard: id, boosterDraw: widget.boosterDraw, refresh:refresh ) );
      id += 1;
    }

    widgetEnergies = [];
    for(Type type in energies) {
      widgetEnergies.add(EnergyButton(
          type: type, boosterDraw: widget.boosterDraw, refresh: refresh ));
    }
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
          buttonLabel = Row(children:[Icon(Icons.warning_amber_outlined), Icon(Icons.battery_charging_full)]);
          break;
        case Validator.ErrorReverse:
          buttonColor = Colors.deepOrange;
          buttonLabel = Row(children:[Icon(Icons.warning_amber_outlined), Image(image: AssetImage('assets/carte/${modeImgs[Mode.Reverse]}.png'), height: 30.0)]);
          break;
        case Validator.ErrorTooManyGood:
          buttonColor = Colors.deepOrange;
          buttonLabel = Row(children:[Icon(Icons.warning_amber_outlined), Icon(Icons.star_border)]);
          break;
        default:
      }
    }

    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
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
              Container(
                height: 60.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  children: widgetEnergies,

                ),
              ),
              CheckboxListTile(
                title: Text(StatitikLocale.of(context).read('TB_B0')),
                subtitle: Text(StatitikLocale.of(context).read('TB_B1'), style: TextStyle(fontSize: 12)),
                value: widget.boosterDraw.abnormal,
                onChanged: (newValue) async {

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
                children: widgets,
              ),
            ],
          ),
    );
  }
}
