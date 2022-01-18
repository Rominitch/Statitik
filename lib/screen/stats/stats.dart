import 'dart:math';

import 'package:flutter/material.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/stats/statsExtensionWidget.dart';
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

  Future<void> waitStats(refresh) async {
    var sData = statsData;

    // Clean old result
    sData.userStats = null;
    sData.stats     = null;
    sData.cardStats.stats = CardStats();

    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(statsData.subExt!, sData.product, sData.category).then( (stats) {
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
            refresh();
          }
        });
      }
      refresh();
    });
  }
}


class StatsPage extends StatefulWidget {
  final StatsConfiguration info = StatsConfiguration();

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late CustomRadioController menuBarController = CustomRadioController(onChange: (value) { afterChangeMenu(value); });
  PageController _pageController = PageController(keepPage: false);

  @override
  void initState() {
    menuBarController.currentValue = StateStatsExtension.Cards;
    super.initState();
  }

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
    _pageController.jumpToPage(idPage);

    //Launch compute stats
    widget.info.waitStats( () { setState(() {}); } );
  }

  Widget menuBar(BuildContext context) {
    return Row( 
      children: [
        Expanded(child: CustomRadio(value: StateStatsExtension.Cards,       controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_0')))),
        Expanded(child: CustomRadio(value: StateStatsExtension.GlobalStats, controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_1')))),
        Expanded(child: CustomRadio(value: StateStatsExtension.Draw,        controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_2')))),
    ]);
  }

  Widget extensionButton(BuildContext context) {
    return Card(
        color: Colors.grey.shade600,
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
          title: (widget.info.se.isEmpty && widget.info.statsData.subExt == null) ?
            Text(StatitikLocale.of(context).read('H_T1'), style: Theme.of(context).textTheme.headline3)
            : TextButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.menu),
                  SizedBox(width: 8.0),
                  Image(image: widget.info.statsData.language!.create(), height: 30),
                  SizedBox(width: 8.0),
                  widget.info.statsData.subExt!.image(hSize: 30),
                  SizedBox(width: 8.0),
                  Flexible(child: Text(widget.info.statsData.subExt!.name, style: Theme.of(context).textTheme.headline6, softWrap: true, maxLines: 3)),
                ]
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension, addMode: false)));
              },
            ),
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
                  widget.info.waitStats( () { setState(() {}); } );
                }
              });
            },
            itemBuilder: (context, position) {
              return SingleChildScrollView(
                child: (widget.info.se.isEmpty) ?
                  startPage(context) :
                  Column(
                    children: [
                      menuBar(context),
                      StatsExtensionWidget(widget.info)
                    ],
                  )
              );
            }
        )
    );
  }
}
