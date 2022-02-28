import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/tirage/tirage_booster.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/UserDrawFile.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';

class ResumePage extends StatefulWidget {
  final SessionDraw _activeSession;
  final bool        _readOnly;

  @override
  _ResumePageState createState() => _ResumePageState();

  ResumePage([activeSession]) :
    this._readOnly      = activeSession != null,
    this._activeSession = activeSession != null ? activeSession! : Environment.instance.currentDraw;

  ResumePage.fromSave(SessionDraw session) :
        this._readOnly      = false,
        this._activeSession = session;
}

class _ResumePageState extends State<ResumePage> {
  @override
  void initState() {
    if( widget._activeSession.boosterDraws.length <= 0 )
      throw StatitikException(StatitikLocale.of(context).read('TR_B0'));

    super.initState();
  }

  Future<bool> backAction(BuildContext context) async {
    if( widget._readOnly ) {
      Navigator.of(context).pop(true);
    } else {
     var exit = await showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) { return showExit(context); });
      if(exit)
        Navigator.of(context).pop(true);
      else
        return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Function update = () { setState(() {}); };
    List<Widget> boosters = [];
    bool atLeastOne  = false;
    bool allFinished = true;
    bool sameExt     = true;

    for( var boosterDraw in widget._activeSession.boosterDraws) {
      Function fillBoosterInfo = (BuildContext context) async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BoosterPage(language: widget._activeSession.language, boosterDraw: boosterDraw, readOnly: widget._readOnly,)),
        );

        //below you can get your result and update the view with setState
        //changing the value if you want, i just wanted know if i have to
        //update, and if is true, reload state
        if (result == null || result) {
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
            MaterialPageRoute(builder: (context) => ExtensionPage(language: widget._activeSession.language, afterSelected: afterSelectExtension, addMode: true)),
          );
        }
        else {
          await fillBoosterInfo(context);
        }
      };

      boosters.add(createBoosterDrawTitle(widget._activeSession, boosterDraw, context, navigateAndDisplaySelection, update));

      var isFinished = boosterDraw.isFinished();
      atLeastOne  |= isFinished;
      allFinished &= isFinished;
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
    if(!widget._readOnly) {
      if(allFinished) {
        actions.add(
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: TextButton(
                style: TextButton.styleFrom( backgroundColor: button, ),
                child: Text(StatitikLocale.of(context).read('send')),
                onPressed: () {
                  EasyLoading.show();
                  Environment env = Environment.instance;
                  env.sendDraw().then((valid) {
                    EasyLoading.dismiss();
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
                      );
                    }
                  }).onError((error, stackTrace) {
                    EasyLoading.showError('Error');
                  });
                },
              ),
            )
        );
      }
      else if(!widget._readOnly && atLeastOne) {
          var errorFunction =  (error, stackTrace){
          printOutput("Write file error:\n${stackTrace.toString()}");
          EasyLoading.dismiss();
          showDialog(
              context: context,
              builder: (_) =>
              new AlertDialog(
                title: new Text(
                    StatitikLocale.of(context).read('error')),
                content: Text(
                    StatitikLocale.of(context).read('TR_B9')),
              )
          );
        };

        actions.add(
            Card(
              color: Colors.amber.shade600,
              margin: const EdgeInsets.all(2.0),
              child: TextButton(
                child: Text(StatitikLocale.of(context).read('TR_B8')),
                onPressed: () async {
                  EasyLoading.show();
                  Environment env = Environment.instance;

                  // Create save folder
                  UserDrawCollection.prepareCollectionFolder().then((collectionFolder) {
                    String savedFile = [collectionFolder.path, "demo.bin"].join(Platform.pathSeparator);
                    UserDrawFile udf = UserDrawFile(savedFile);
                    udf.save(env.currentDraw!).then((value) {
                      EasyLoading.dismiss();
                      showDialog(
                          context: context,
                          builder: (_) =>
                          new AlertDialog(
                            title: new Text(
                                StatitikLocale.of(context).read('TR_B11')),
                            content: Text(
                                StatitikLocale.of(context).read('TR_B10')),
                          )
                      ).then((value) {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        // Clean data
                        env.currentDraw!.closeStream();
                        env.currentDraw = null;
                      });
                    }).onError(errorFunction);
                  }).onError(errorFunction);
                },
              ),
            )
        );
      }
    }

    return WillPopScope(
      onWillPop: () { return backAction(context); },
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget._activeSession.product.name, style: TextStyle(fontSize: 15)),
        actions: actions,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            backAction(context);
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
                          widget._activeSession.revertAnomaly(Environment.instance.collection.subExtensions);
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
      )
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
