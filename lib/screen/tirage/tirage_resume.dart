import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/screen/tirage/tirage_booster.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class ResumePage extends StatefulWidget {
  ResumePage()
  {
    if( Environment.instance.currentDraw.product == null ||
        Environment.instance.currentDraw.boosterDraws.length <= 0 )
      throw StatitikException("Erreur de création du produit");
  }

  @override
  _ResumePageState createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {

  @override
  Widget build(BuildContext context) {
    SessionDraw current = Environment.instance.currentDraw;
    Function update = () { setState(() {}); };
    List<Widget> boosters = [];
    bool allFinished = true;
    bool sameExt = true;
    for( var boosterDraw in current.boosterDraws) {
      Function navigateAndDisplaySelection = (BuildContext context) async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BoosterPage(boosterDraw: boosterDraw)),
        );

        //below you can get your result and update the view with setState
        //changing the value if you want, i just wanted know if i have to
        //update, and if is true, reload state
        if (result) {
          setState(() {});
        }
      };

      boosters.add(createBoosterDrawTitle(boosterDraw, context, navigateAndDisplaySelection, update));

      allFinished &= boosterDraw.isFinished();
      sameExt &= (current.boosterDraws.first.subExtension.idExtension == boosterDraw.subExtension.idExtension);
    }

    // Add booster button
    if(current.productAnomaly) {
      boosters.add(Card(
          color: Colors.grey[900],
          child: FlatButton(
              child: Center(
                child: Icon(Icons.add_circle_outline, size: 30.0,),
              ),
            onPressed: () {
              setState(() {
                current.addNewBooster();
              });
            },
          )
        )
      );
    }

    List<Widget> actions = [];
    if(allFinished) {
      actions.add(
          Card( child: FlatButton(
              child: Text("Envoyer"),
              onPressed: () async {
                Environment env = Environment.instance;
                bool valid = await env.sendDraw();
                if( valid ) {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } else {
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                          title: new Text("Erreur"),
                          content: Text('L\'envoi des données n\'a pu être fait.\nVérifier votre connexion et réessayer !'),
                      )
                  );
                }
              },
            )
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tirage'),
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: !sameExt,
                child:Row(
                    children: [
                      Icon(Icons.warning),
                      Text( ' Attention aux diverses extensions' ),
                    ],
                  ),
              ),
              CheckboxListTile(
                title: Text('Le produit n\'est pas conforme'),
                subtitle: Text('Exemple: il n\'y a pas le bon nombre de boosters'),
                value: current.productAnomaly,
                onChanged: (newValue) {
                  setState(() {
                    current.productAnomaly = !current.productAnomaly;
                  });
                },
              ),
              GridView.count(
                    crossAxisCount: 5,
                    padding: const EdgeInsets.all(8.0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    children: boosters,
              ),
            ],
        ),
      ),
    );
  }
}
