import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statitik_pokemon/screen/Wrapper.dart';
import 'package:statitik_pokemon/screen/tirage/tirage_booster.dart';
import 'package:statitik_pokemon/screen/view.dart';
import 'package:statitik_pokemon/services/environment.dart';
import 'package:statitik_pokemon/services/models.dart';

class ResumePage extends StatefulWidget {

  final Product product;
  final bool productAnomaly=false;

  ResumePage({ this.product });

  @override
  _ResumePageState createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {

  @override
  Widget build(BuildContext context) {
    List<Widget> boosters = [];
    bool allFinished = true;
    bool sameExt = true;
    for( var boosterDraw in Environment.instance.boosterDraws) {
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

      boosters.add(createBoosterDrawTitle(boosterDraw, context, navigateAndDisplaySelection));

      allFinished &= boosterDraw.isFinished();
      sameExt &= (Environment.instance.boosterDraws.first.subExtension.idExtension == boosterDraw.subExtension.idExtension);
    }
    List<Widget> actions = [];
    if(allFinished) {
      actions.add(
          Card( child: FlatButton(
              child: Text("Envoyer"),
              onPressed: () async {
                Environment env = Environment.instance;
                bool valid = await env.sendDraw(widget.product, widget.productAnomaly);
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
