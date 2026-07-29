import 'dart:math';

import 'package:align_dialog/align_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/screenOld/stats/stat_view.dart';
import 'package:statitikcard/screenOld/stats/stats.dart';
import 'package:statitikcard/screenOld/stats/stats_extension_widget.dart';
import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/screens/page_expansion_info.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/widgets/widget_card_version_selector.dart';

class PageExpansions extends StatefulWidget {
  const PageExpansions({super.key});

  @override
  State<PageExpansions> createState() => _PageExpansionsState();
}

class _PageExpansionsState extends State<PageExpansions> {

  late CustomRadioController menuBarController = CustomRadioController(onChange: (value) { afterChangeMenu(value); });
  late PageController _pageController;

  List<PokeExpansion> _se        = [];
  StatisticData       _statsData = StatisticData();

  @override
  void initState() {
    // Restore good page when return or select 0
    var idPage = 0;
    if(_statsData.selection.expansion != null) {
      idPage = _se.indexOf(_statsData.selection.expansion!);
    }
    _pageController = PageController(initialPage: idPage, keepPage: false);

    menuBarController.currentValue = StateStatsExtension.cards;
    super.initState();
  }

  /*
  Future<void> waitStats(refresh) async {
    var sData = statsData;

    // Clean old result
    sData.userStats = null;
    sData.stats     = null;
    sData.cardStats.stats = CardStats();

    var product = sData.pr?.product;
    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(statsData.subExt!, product, sData.category).then( (stats) {
      sData.stats = stats;
      // Compute Cards stats
      int idCard=0;
      for (var listCardSE in sData.subExt!.seCards.cards) {
        for (var cardSE in listCardSE) {
          sData.cardStats.stats!.add(sData.subExt!, cardSE, CardIdentifier.from([0, idCard, 0]));
          idCard +=1;
        }
      }

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
 */

  void afterChangeMenu(StateStatsExtension value) {
    setState(() {
      _statsData.state = value;
    });
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showAlignedDialog<void>(
      context: context,
      followerAnchor: Alignment.topRight,
      isGlobal: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black26,
            width: MediaQuery.of(context).size.width / 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: WidgetCardVersionSelector(_statsData.selection,
                onPress: () {
                  Navigator.of(context).pop();
                  setState(() {});
                }
              )
            )
          ),
        );
      },
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
                  Text(StatitikLocale.of(context).read('S_B2'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(width: 5.0),
                  const Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                ]),
          ),
          const SizedBox(height: 5.0),
          Expanded(child: MovingImageWidget(Padding(
            padding: const EdgeInsets.all(8.0),
            child: drawImagePress(context, 'Artwork', 300.0),
          ))),

        ]
    );
  }

  Widget menuBar(BuildContext context) {
    return Row(
        children: [
          Expanded(child: CustomRadio(value: StateStatsExtension.cards,       controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_0')))),
          Expanded(child: CustomRadio(value: StateStatsExtension.globalStats, controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_1')))),
          if(_statsData.selection.expansion != null && _statsData.selection.expansion!.type() == ExpansionType.Normal)
            Expanded(child: CustomRadio(value: StateStatsExtension.draw,      controller: menuBarController, widget: Text(StatitikLocale.of(context).read('SMENU_2')))),
        ]);
  }

  Widget extensionButton(BuildContext context) {
    return Card(
        color: Colors.grey.shade600,
        child: TextButton(
          child: _statsData.selection.language != null ? Row(
              children: [
                Text(StatitikLocale.of(context).read('S_B0')),
                const SizedBox(width: 8.0),
                Image(image: _statsData.selection.language!.create(), height: 30),
                const SizedBox(width: 8.0),
                Tooltip(message: _statsData.selection.expansion!.label(_statsData.selection.language!),
                    child: _statsData.selection.expansion!.image(_statsData.selection.language!, hSize: 30)),
              ]) : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                drawImagePress(context, 'Minccino', 45),
                const SizedBox(width: 15.0),
                Text(StatitikLocale.of(context).read('S_B0'), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(width: 15.0),
                drawImagePress(context, 'pika', 45),
              ]),
          onPressed: () {
            _dialogBuilder(context);
            //Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension, addMode: false)));
          },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text("Second appbar"),
            Spacer(),
            TextButton(
              child: Text("Show extensions"),
              onPressed: () {
                setState(() {
                  _dialogBuilder(context);
                });
              },
            ),
          ],
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: max(1, _se.length),
            pageSnapping: true,
            onPageChanged: (position) {
              setState(() {
                var se = position < _se.length ? _se[position] : null;
                if(se != _statsData.selection.expansion) {
                  _statsData.selection.expansion = se;
                  //_waitStats( () { setState(() {}); } );
                }
              });
            },
            itemBuilder: (context, position) {
              return (_statsData.selection.expansion == null)
                ? startPage(context)
                : PageExpansionInfo(_statsData, _pageController);
            }
          )
        )
      ],
    );
  }
}
