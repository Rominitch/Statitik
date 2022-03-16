import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/commonPages/UserNewCardsDraw.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/PokeSpace/PokeSpaceDrawBooster.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/CardSelector/CardSelectorProductDraw.dart';
import 'package:statitikcard/screen/widgets/PokemonCard.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/UserDrawFile.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/models.dart';

class PokeSpaceDrawResume extends StatefulWidget {
  final SessionDraw   _activeSession;
  final bool          _readOnly;
  final UserDrawFile? _file;

  @override
  _PokeSpaceDrawResumeState createState() => _PokeSpaceDrawResumeState();

  PokeSpaceDrawResume([activeSession]) :
    this._file = null,
    this._readOnly      = activeSession != null,
    this._activeSession = activeSession != null ? activeSession! : Environment.instance.currentDraw;

  PokeSpaceDrawResume.fromSave(SessionDraw session, this._file) :
        this._readOnly      = false,
        this._activeSession = session
  {
    Environment.instance.currentDraw = session;
  }
}

class _PokeSpaceDrawResumeState extends State<PokeSpaceDrawResume> {
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

  void refresh() {
    setState(() {

    });
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
      allFinished &= widget._activeSession.productDraw.count == widget._activeSession.product.nbRandomPerProduct;
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
                  env.sendDraw().then((report) {
                    assert(env.user != null);
                    assert(env.currentDraw != null);

                    EasyLoading.dismiss();
                    if( report != null ) {
                      // Show registration report
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => new AlertDialog(
                            title: Center(child: Text(StatitikLocale.of(context).read('TR_B1'), style: Theme.of(context).textTheme.headline4)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(StatitikLocale.of(context).read('TR_B2')),
                                SizedBox(height: 10),
                                Card(
                                  color: Colors.green,
                                  child: TextButton(
                                    child: Text(StatitikLocale.of(context).read('TR_B12')),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ),
                                SizedBox(height: 30),
                                Text(StatitikLocale.of(context).read( report.result.isNotEmpty ? 'TR_B14': 'TR_B13')),
                                SizedBox(height: 10),
                                if(report.result.isNotEmpty)
                                  Container(
                                      width: 2 * MediaQuery.of(context).size.width / 3,
                                      height: MediaQuery.of(context).size.height / 2,
                                    child: UserNewCardDraw(report)),
                              ]
                            )
                          )
                      ).then((value) {
                        // Clean from saved draw
                        if(widget._file != null) {
                          widget._file!.remove();
                        }

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
                    EasyLoading.showError(StatitikLocale.of(context).read('error'));
                    printOutput("$error\n${stackTrace.toString()}");
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

        // Save to file action
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
                            title: new Text(StatitikLocale.of(context).read('TR_B11'), style: Theme.of(context).textTheme.headline4),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                          widget._activeSession.revertAnomaly();
                        });
                      }
                    } else { // Toggle
                      setState(() { widget._activeSession.productAnomaly = !widget._activeSession.productAnomaly; });
                    }
                },
              ),
              if(widget._activeSession.productDraw.randomProductCard.isNotEmpty)
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 6.0, 12.0, 3.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(StatitikLocale.of(context).read('TR_B15'), style: Theme.of(context).textTheme.headline6),
                            Expanded(
                              child: Text("${widget._activeSession.productDraw.count} / ${widget._activeSession.product.nbRandomPerProduct}",
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.headline6?.copyWith(
                                  color: widget._activeSession.product.nbRandomPerProduct == widget._activeSession.productDraw.count ? Colors.green : Colors.red,
                                  )
                              ),
                            ),
                          ]
                        ),
                      ),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, crossAxisSpacing: 2, mainAxisSpacing: 2,
                          childAspectRatio: 1.2),
                        padding: const EdgeInsets.all(2.0),
                        shrinkWrap: true,
                        primary: false,
                        itemCount: widget._activeSession.productDraw.randomProductCard.length,
                        itemBuilder: (BuildContext context, int index) {
                          var productCard = widget._activeSession.productDraw.randomProductCard.keys.elementAt(index);
                          var selector = CardSelectorProductDraw(widget._activeSession.productDraw, productCard);
                          return PokemonCard(selector, readOnly: widget._readOnly, refresh: () { setState(() {}); } );
                        }
                      ),
                    ],
                  ),
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
      title: Text(StatitikLocale.of(context).read('DC_B20')),
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
