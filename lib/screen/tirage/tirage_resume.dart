import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/tirage/tirage_booster.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class ResumePage extends StatefulWidget {
  final SessionDraw _activeSession;
  final bool        _readOnly;

  @override
  _ResumePageState createState() => _ResumePageState();

  ResumePage([activeSession]) :
    this._readOnly      = activeSession != null,
    this._activeSession = activeSession != null ? activeSession! : Environment.instance.currentDraw;
}

class _ResumePageState extends State<ResumePage> {
  bool isSending = false;

  @override
  void initState() {
    if( widget._activeSession.boosterDraws.length <= 0 )
      throw StatitikException(StatitikLocale.of(context).read('TR_B0'));

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Function update = () { setState(() {}); };
    List<Widget> boosters = [];
    bool allFinished = true;
    bool sameExt = true;

    for( var boosterDraw in widget._activeSession.boosterDraws) {
      Function fillBoosterInfo = (BuildContext context) async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BoosterPage(language: widget._activeSession.language, boosterDraw: boosterDraw, readOnly: widget._readOnly,)),
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
            MaterialPageRoute(builder: (context) => ExtensionPage(language: widget._activeSession.language, afterSelected: afterSelectExtension)),
          );
        }
        else {
          await fillBoosterInfo(context);
        }
      };

      boosters.add(createBoosterDrawTitle(widget._activeSession, boosterDraw, context, navigateAndDisplaySelection, update));

      allFinished &= boosterDraw.isFinished();
      if( widget._activeSession.boosterDraws.first.subExtension != null && boosterDraw.subExtension != null)
        sameExt &= (widget._activeSession.boosterDraws.first.subExtension!.extension == boosterDraw.subExtension!.extension);
    }

    // Add booster button
    if(widget._activeSession.productAnomaly) {
      boosters.add(Card(
          color: Colors.grey[900],
          child: TextButton(
              child: Center(
                child: Icon(Icons.add_circle_outline, size: 30.0,),
              ),
            onPressed: () {
              setState(() {
                if(!isSending)
                  widget._activeSession.addNewBooster();
              });
            },
          )
        )
      );
    }

    // Choose best color button on first error
    Color button = greenValid;
    for( BoosterDraw booster in widget._activeSession.boosterDraws) {
      if(booster.isFinished() && booster.validationWorld(widget._activeSession.language) != Validator.Valid) {
        button = Colors.deepOrange;
        break;
      }
    }

    List<Widget> actions = [];
    if(allFinished && !widget._readOnly) {
      actions.add(
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextButton(
              style: TextButton.styleFrom( backgroundColor: button, ),
              child: Text(StatitikLocale.of(context).read('send')),
              onPressed: () async {
                if(!isSending) {
                  Environment env = Environment.instance;
                  env.sendDraw().then((valid) {
                    isSending = false;
                    if( valid ) {
                      showDialog(
                          context: context,
                          builder: (_) => new AlertDialog(
                            title: new Text(StatitikLocale.of(context).read('TR_B1')),
                            content: Text(StatitikLocale.of(context).read('TR_B2')),
                          )
                      ).then((value) {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        // Clean data
                        env.currentDraw!.closeStream();
                        env.currentDraw = null;
                      });
                    } else {
                    showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                      title: new Text(StatitikLocale.of(context).read('error')),
                      content: Text(StatitikLocale.of(context).read('TR_B3')),
                      )
                      ).then((value) {
                        setState((){
                          isSending=false;
                        });
                    });
                    }
                  }).whenComplete((){
                    setState(() {
                      isSending=true;
                    });
                  });
                }
              },
            ),
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._activeSession.product.name, style: TextStyle(fontSize: 15)),
        actions: isSending ? [Container(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.orange[300]))] :  actions,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            if( widget._readOnly ) {
              Navigator.of(context).pop(true);
            } else {
              showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) { return showExit(context); }).then((exit)
                  {
                    if(exit)
                      Navigator.of(context).pop(true);
                  });
            }
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
                value: widget._activeSession.productAnomaly,
                onChanged: widget._readOnly ? null : (newValue) async {
                    if(widget._activeSession.productAnomaly && widget._activeSession.needReset())
                    {
                      bool reset = await showDialog(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) { return showAlert(context); });

                      if(reset) {
                        setState(() {
                          widget._activeSession.revertAnomaly();
                        });
                      }
                    } else { // Toggle
                      setState(() { widget._activeSession.productAnomaly = !widget._activeSession.productAnomaly; });
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
        Card(
          color: Colors.red,
          child: TextButton(
            child: Text(StatitikLocale.of(context).read('yes')),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
        Card(
          child: TextButton(
            child: Text(StatitikLocale.of(context).read('cancel')),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      ],
    );
  }
}
