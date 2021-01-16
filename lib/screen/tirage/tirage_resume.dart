import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/screen/extensionPage.dart';
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
      Function fillBoosterInfo = (BuildContext context) async {
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
      Function afterSelectExtension = (BuildContext context, Language language, SubExtension subExt) async
      {
        // Quit page
        Navigator.of(context).pop();
        if(subExt != null) {
          boosterDraw.subExtension = subExt;
          boosterDraw.fillCard();
          // Go to booster fill
          await fillBoosterInfo(context);
        }
      };

      Function navigateAndDisplaySelection = (BuildContext context) async {
        // First fill extension is not the case
        if(!boosterDraw.hasSubExtension()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExtensionPage(language: current.language, afterSelected: afterSelectExtension)),
          );
        }
        else {
          await fillBoosterInfo(context);
        }
      };

      boosters.add(createBoosterDrawTitle(boosterDraw, context, navigateAndDisplaySelection, update));

      allFinished &= boosterDraw.isFinished();
      if( current.boosterDraws.first.subExtension != null && boosterDraw.subExtension != null)
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
        title: Text(current.product.name, style: TextStyle(fontSize: 15)),
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
                    if(current.productAnomaly && current.needReset())
                    {
                      showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) { return showAlert(context, current); });
                    }
                    else // Toggle
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

  AlertDialog showAlert(BuildContext context, SessionDraw current) {
      return AlertDialog(
        title: Text('Attention'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Les données seront réinitialisées.'),
              Text('Voulez-vous continuer ?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Oui'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                current.revertAnomaly();
              });
            },
          ),
          TextButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
  }
}
