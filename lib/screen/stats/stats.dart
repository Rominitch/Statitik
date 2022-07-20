import 'dart:math';

import 'package:flutter/material.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/stats/statsExtensionWidget.dart';
import 'package:statitikcard/screen/tutorial/TutorialCaption.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/models.dart';

enum StateStatsExtension {
  Cards,
  GlobalStats,
  Draw,
  Product,
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

    var product = sData.pr != null ? sData.pr!.product : null;
    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(statsData.subExt!, product, sData.category).then( (stats) {
      sData.stats = stats;
      // Compute Cards stats
      int idCard=0;
      sData.subExt!.seCards.cards.forEach((listCardSE) {
        listCardSE.forEach((cardSE) {
          sData.cardStats.stats!.add(sData.subExt!, cardSE, CardIdentifier.from([0, idCard, 0]));
          idCard +=1;
        });
      });

      // Get user info after
      if(env.user != null) {
        env.getStats(sData.subExt!, product, sData.category, env.user!.idDB).then( (ustats) {
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

  StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late CustomRadioController menuBarController = CustomRadioController(onChange: (value) { afterChangeMenu(value); });
  late PageController _pageController;

  @override
  void initState() {
    // Restore good page when return or select 0
    var idPage = 0;
    if(widget.info.statsData.subExt != null) {
      idPage = widget.info.se.indexOf(widget.info.statsData.subExt!);
    }
    _pageController = PageController(initialPage: idPage, keepPage: false);

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
      widget.info.statsData.category = null;
      widget.info.statsData.pr       = null;
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
        if(widget.info.statsData.subExt != null && widget.info.statsData.subExt!.type == SerieType.Normal)
          Expanded(child: CustomRadio(value: StateStatsExtension.Draw,      controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_2')))),
    ]);
  }

  Widget extensionButton(BuildContext context) {
    return Card(
        color: Colors.grey.shade600,
        child: TextButton(
          child: widget.info.statsData.language != null ? Row(
              children: [
                Text(StatitikLocale.of(context).read('S_B0')),
                const SizedBox(width: 8.0),
                Image(image: widget.info.statsData.language!.create(), height: 30),
                const SizedBox(width: 8.0),
                Tooltip(message: widget.info.statsData.subExt!.name,
                    child:widget.info.statsData.subExt!.image(hSize: 30)),
              ]) : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                drawImagePress(context, 'Minccino', 40),
                const SizedBox(width: 15.0),
                Text(StatitikLocale.of(context).read('S_B0'), style: Theme.of(context).textTheme.headline5),
                const SizedBox(width: 15.0),
                drawImagePress(context, 'pika', 40),
            ]),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension, addMode: false)));
          },
        )
    );
  }

  Widget buildExplain(BuildContext context, String image, String title, String explains) {
    return Expanded(child: // Rowlet
      Card(
        margin: const EdgeInsets.all(2.0),
        color: Colors.grey.shade800,
        child: Container(height:165,
          padding: const EdgeInsets.all(4.0),
          child: Column(children: [
            drawImagePress(context, image, 40.0),
            Text(StatitikLocale.of(context).read(title), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Expanded(child: Text(StatitikLocale.of(context).read(explains), style: const TextStyle(fontSize: 8.2))),
            const Icon(Icons.arrow_drop_down_circle_outlined)
          ])
        )
      )
    );
  }

  Widget startPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children : [
        const SizedBox(height: 5.0),
        extensionButton(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Image(image: AssetImage('assets/arrowL.png'), height: 20.0,),
            const SizedBox(width: 5.0),
            Text(StatitikLocale.of(context).read('S_B2'), style: Theme.of(context).textTheme.headline6),
            const SizedBox(width: 5.0),
            const Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
          ]),
        ),
        const SizedBox(height: 5.0),
        Expanded(child: MovingImageWidget(Padding(
          padding: const EdgeInsets.all(8.0),
          child: drawImagePress(context, 'Artwork', 300.0),
        ))),
        const SizedBox(height: 5),
        Row(
          children: [
            buildExplain(context, "Rowlet",  "S_TOOL_T0", "S_TOOL_B0"),
            buildExplain(context, "Growl",   "S_TOOL_T1", "S_TOOL_B1"),
            buildExplain(context, "Voltorb", "S_TOOL_T2", "S_TOOL_B2"),
            buildExplain(context, "news",    "S_TOOL_T3", "S_TOOL_B3"),
            if(Environment.instance.isAdministrator())
              buildExplain(context, "Voltorb",    "", ""),
          ]
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (widget.info.se.isEmpty && widget.info.statsData.subExt == null) ?
            Center(child: Text(Environment.instance.nameApp, style: Theme.of(context).textTheme.headline3))
            : TextButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.menu),
                  const SizedBox(width: 8.0),
                  Image(image: widget.info.statsData.language!.create(), height: 30),
                  const SizedBox(width: 8.0),
                  widget.info.statsData.subExt!.image(hSize: 30),
                  const SizedBox(width: 8.0),
                  Flexible(child: Text(widget.info.statsData.subExt!.name, style: TextStyle(
                    fontFamily: Theme.of(context).textTheme.headline6!.fontFamily,
                    fontSize: widget.info.statsData.subExt!.name.length > 25 ? 10 : 16,
                  ), softWrap: true, maxLines: 3)),
                ]
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension, addMode: false)));
              },
            ),
          actions: widget.info.se.isEmpty ? [] :
          [
            IconButton(
              icon: const Icon(Icons.info_outline),
              visualDensity: VisualDensity.comfortable,
              splashColor: Colors.orangeAccent,
              tooltip: StatitikLocale.of(context).read('S_TOOL_T4'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TutorialCaption(widget.info.statsData.subExt!.extension.language)));
              },
            ),
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
                widget.info.waitStats( () { setState(() {}); } );
              }
            });
          },
          itemBuilder: (context, position) {
            return (widget.info.se.isEmpty) ?
              startPage(context) :
              StatsExtensionWidget(widget.info, _pageController);
          }
        )
    );
  }
}
