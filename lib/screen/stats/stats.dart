import 'dart:math';

import 'package:flutter/material.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/stats/statsExtensionWidget.dart';
import 'package:statitikcard/screen/stats/statsOptionDialog.dart';
import 'package:statitikcard/screen/stats/userReport.dart';
import 'package:statitikcard/screen/view.dart';

import 'package:statitikcard/screen/widgets/CustomRadio.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

enum StateStatsExtension {
  Cards,
  GlobalStats,
  Draw,
}

class StatsConfiguration {
  StateStatsExtension state     = StateStatsExtension.Cards;
  StatsData           statsData = StatsData();
  List<SubExtension>  se        = [];
  StatsViewOptions    options   = StatsViewOptions();
}


class StatsPage extends StatefulWidget {
  final StatsConfiguration info = StatsConfiguration();

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late CustomRadioController menuBarController = CustomRadioController(onChange: (value) { afterChangeMenu(value); });
  PageController _pageController = PageController(keepPage: false);

  void afterChangeMenu(value) {
    setState(() {
      widget.info.state = value;
    });
  }

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      // Set old filter
      widget.info.statsData.category = -1;
      widget.info.statsData.product = null;
      // Change selection
      widget.info.statsData.language = language;
      widget.info.statsData.subExt = subExt;

      widget.info.se.clear();
      for (Extension e in Environment.instance.collection.getExtensions(
          language)) {
        for (SubExtension se in Environment.instance.collection
            .getSubExtensions(e)) {
          widget.info.se.insert(0, se);
        }
      }
    });

    var idPage = widget.info.se.indexOf(subExt);
    //printOutput("Page after extension: $idPage");
    //_pageController = widget._se.isNotEmpty ? PageController(initialPage: idPage) : PageController();
    _pageController.jumpToPage(idPage);

    //Launch compute stats
    waitStats();
  }

  Future<void> waitStats() async {
    var sData = widget.info.statsData;

    // Clean old result
    sData.userStats = null;
    sData.stats     = null;
    sData.cardStats.stats = CardStats();

    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(widget.info.statsData.subExt!, sData.product, sData.category).then( (stats) {
      sData.stats = stats;
      // Compute Cards stats
      int idCard=0;
      sData.subExt!.seCards.cards.forEach((listCardSE) {
        listCardSE.forEach((cardSE) {
          sData.cardStats.stats!.add(sData.subExt!, cardSE, idCard);
          idCard +=1;
        });
      });

      // Get user info after
      if(env.user != null) {
        env.getStats(sData.subExt!, sData.product, sData.category, env.user!.idDB).then( (ustats) {
          if(ustats.nbBoosters > 0) {
            sData.userStats = ustats;
            setState(() {});
          }
        });
      }
      setState(() {});
    });
  }

  Widget menuBar(BuildContext context) {
    return Row( 
      children: [
        CustomRadio(value: StateStatsExtension.Cards,       controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_0'))),
        CustomRadio(value: StateStatsExtension.GlobalStats, controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_1'))),
        CustomRadio(value: StateStatsExtension.Draw,        controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_2'))),
    ]);
  }

  Widget extensionButton(BuildContext context) {
    return Card(
        child: TextButton(
          child: widget.info.statsData.language != null ? Row(
              children: [
                Text(StatitikLocale.of(context).read('S_B0')),
                SizedBox(width: 8.0),
                Image(image: widget.info.statsData.language!.create(), height: 30),
                SizedBox(width: 8.0),
                Tooltip(message: widget.info.statsData.subExt!.name,
                    child:widget.info.statsData.subExt!.image(hSize: 30)),
              ]) : Text(StatitikLocale.of(context).read('S_B0')),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension, addMode: false)));
          },
        )
    );
  }

  Widget startPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children : [
        extensionButton(context),
        Container( child:
          Row( children: [
            SizedBox(width: 40.0),
            Image(image: AssetImage('assets/arrow.png'), height: 30.0,),
            SizedBox(width: 25.0),
            Flexible(child: Text(StatitikLocale.of(context).read('S_B2'), style: Theme.of(context).textTheme.headline5)),
          ])
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: drawImagePress(context, 'PikaNoResult', 250.0),
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            StatitikLocale.of(context).read('H_T1'), style: Theme.of(context).textTheme.headline3),
          actions: [
            if(widget.info.se.isNotEmpty)
              menuBar(context)
            /*
            TextButton(
                  child: Icon(Icons.settings),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return createOptionDialog(context, widget.info.options);
                      }
                    ).then( (result) { setState((){}); } );
                  }
              ),
           */
          ],
        ),
        body: PageView.builder(
            controller: _pageController,
            itemCount: max(1, widget.info.se.length),
            pageSnapping: true,
            onPageChanged: (position) {
              setState(() {
                var se = position < widget.info.se.length ? widget.info.se[position] : null;
                if(se != widget.info.statsData.subExt) {
                  widget.info.statsData.subExt = se;
                  waitStats();
                }
              });
            },
            itemBuilder: (context, position) {
              return SingleChildScrollView(
                child: (widget.info.se.isEmpty) ?
                  startPage(context) :
                  Column(
                    children: [
                      extensionButton(context),
                      StatsExtensionWidget(widget.info)
                    ],
                  )
              );
            }
        )
    );
  }

  void afterSelectProduct(BuildContext context, Language language, Product? product, int category) {
    Navigator.pop(context);
    setState(() {
      if(product != null) {
        widget.info.statsData.product  = product;
        widget.info.statsData.category = -1;
      } else if( category != -1 ) {
        widget.info.statsData.product  = null;
        widget.info.statsData.category = category;
      } else { // All products
        widget.info.statsData.product  = null;
        widget.info.statsData.category = -1;
      }
      waitStats();
    });
  }
}
