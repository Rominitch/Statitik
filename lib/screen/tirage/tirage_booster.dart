import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/models.dart';

class BoosterPage extends StatefulWidget {
  final BoosterDraw boosterDraw;

  BoosterPage({this.boosterDraw});

  @override
  _BoosterPageState createState() => _BoosterPageState();
}

class _BoosterPageState extends State<BoosterPage> {
  List<Widget> widgets;
  List<Widget> widgetEnergies;

  @override
  void initState() {
    super.initState();

    // Build one time all widgets
    Function refresh = () => setState( () {} );
    widgets = [];
    int id=0;
    for(PokeCard card in widget.boosterDraw.subExtension.cards) {
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
                Text('Booster ${widget.boosterDraw.id}'),
                SizedBox(width: 10.0),
                widget.boosterDraw.subExtension.image(hSize: iconSize),
                SizedBox(width: 10.0),
                Text('${widget.boosterDraw.count}/${widget.boosterDraw.nbCards}'),
              ],
            ),
          ),
        ),
        body:
         ListView(
            children: [
              Container(
                height: 60.0,
                child:
                ListView(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  children: widgetEnergies,
                ),
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
