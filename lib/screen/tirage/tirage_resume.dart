import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/tirage/tirage_booster.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class ResumePage extends StatefulWidget {
  @override
  _ResumePageState createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {

  @override
  void initState() {
    if( Environment.instance.currentDraw.boosterDraws.length <= 0 )
      throw StatitikException(StatitikLocale.of(context).read('TR_B0'));

    super.initState();
  }
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
          MaterialPageRoute(builder: (context) => BoosterPage(language: current.language, boosterDraw: boosterDraw)),
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

        boosterDraw.subExtension = subExt;
        boosterDraw.fillCard();
        // Go to booster fill
        await fillBoosterInfo(context);
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
        sameExt &= (current.boosterDraws.first.subExtension!.idExtension == boosterDraw.subExtension!.idExtension);
    }

    // Add booster button
    if(current.productAnomaly) {
      boosters.add(Card(
          color: Colors.grey[900],
          child: TextButton(
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

    // Choose best color button on first error
    Color button = greenValid;
    for( BoosterDraw booster in current.boosterDraws) {
      if(booster.isFinished() && booster.validationWorld(current.language) != Validator.Valid) {
        button = Colors.deepOrange;
        break;
      }
    }

    List<Widget> actions = [];
    if(allFinished) {
      actions.add(
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextButton(
              style: TextButton.styleFrom( backgroundColor: button, ),
              child: Text(StatitikLocale.of(context).read('send')),
              onPressed: () async {
                Environment env = Environment.instance;
                bool valid = await env.sendDraw();

                if( valid ) {
                  await showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                        title: new Text(StatitikLocale.of(context).read('TR_B1')),
                        content: Text(StatitikLocale.of(context).read('TR_B2')),
                      )
                  );
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } else {
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                          title: new Text(StatitikLocale.of(context).read('error')),
                          content: Text(StatitikLocale.of(context).read('TR_B3')),
                      )
                  );
                }
              },
          ),
            )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(current.product.name, style: TextStyle(fontSize: 15)),
        actions: actions,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () async {
            bool exit = await showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) { return showExit(context); });
            if(exit)
              Navigator.of(context).pop(true);
          },
        ),
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
                      Text(StatitikLocale.of(context).read('TR_B4')),
                    ],
                  ),
              ),
              CheckboxListTile(
                title: Text(StatitikLocale.of(context).read('TR_B5')),
                subtitle: Text(StatitikLocale.of(context).read('TR_B6'), style: TextStyle(fontSize: 12)),
                value: current.productAnomaly,
                onChanged: (newValue) async {
                    if(current.productAnomaly && current.needReset())
                    {
                      bool reset = await showDialog(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) { return showAlert(context); });

                      if(reset) {
                        setState(() {
                          current.revertAnomaly();
                        });
                      }
                    } else { // Toggle
                      setState(() { current.productAnomaly = !current.productAnomaly; });
                    }
                },
              ),
              GridView.count(
                    crossAxisCount: 5,
                    padding: const EdgeInsets.all(2.0),
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

  AlertDialog showExit(BuildContext context) {
    return AlertDialog(
      title: Text(StatitikLocale.of(context).read('warning')),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(StatitikLocale.of(context).read('TR_B7')),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(StatitikLocale.of(context).read('yes')),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          child: Text(StatitikLocale.of(context).read('cancel')),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
