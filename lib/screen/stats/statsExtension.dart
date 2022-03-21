import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Cartes/CardStatistic.dart';

import 'package:statitikcard/screen/Cartes/statsCard.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';

class StatsExtensionsPage extends StatefulWidget {
  final StatsBooster stats;
  final StatsData data;

  StatsExtensionsPage({required this.stats, required this.data});

  @override
  _StatsExtensionsPageState createState() => _StatsExtensionsPageState();
}

class _StatsExtensionsPageState extends State<StatsExtensionsPage> {
  Widget cardInfo(BuildContext context, String label, int count)
  {
    return Card(child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(count.toString()),
          Text(StatitikLocale.of(context).read(label), style: Theme.of(context).textTheme.headline6, softWrap: true)
        ]
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var statsExtension = widget.stats.subExt.stats;
    List<Widget> infoCount = [];

    List info = [
     ['SE_B3', widget.stats.count.length-statsExtension.countSecret],
     ['SE_B4', statsExtension.countSecret],
     ['SE_B5', statsExtension.countAllCards()],
    ];
    info.forEach((element) {
      infoCount.add(cardInfo(context, element[0], element[1]));
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(StatitikLocale.of(context).read('SE_B0'), style: Theme.of(context).textTheme.headline5),
          GridView.count(
            crossAxisCount: 3,
            children: infoCount,
            primary: false,
            shrinkWrap: true,
            childAspectRatio: 1.8,
          ),
          PieExtension(widget.stats.subExt, Visualize.Type),
          SizedBox(height: 10.0,),
          PieExtension(widget.stats.subExt, Visualize.Rarity),
          if (widget.data.cardStats.hasStats() && widget.data.cardStats.stats!.hasData())
            StatsCard(widget.data.language!, widget.data.cardStats, CardStatisticOptions(), showByRarity: false, showBySubEx: false, showTitle: false, showByType: false),
        ]
      ),
    );
  }
}
