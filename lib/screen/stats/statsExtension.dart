import 'package:flutter/material.dart';

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
  late StatsExtension statsExtension;

  @override
  void initState() {
    statsExtension = StatsExtension(subExt: widget.stats.subExt);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(StatitikLocale.of(context).read('SE_B0'), style: Theme.of(context).textTheme.headline5),
          Text(StatitikLocale.of(context).read('SE_B2')+' '+widget.stats.count.length.toString(), style: Theme.of(context).textTheme.bodyText2),
          PieExtension(stats: statsExtension, visu: Visualize.Type),
          SizedBox(height: 10.0,),
          PieExtension(stats: statsExtension, visu: Visualize.Rarity),
          if (widget.data.cardStats.hasStats() && widget.data.cardStats.stats!.hasData()) StatsCard(widget.data.language!, widget.data.cardStats, showByRarity: false, showBySubEx: false, showTitle: false, showByType: false),
        ]
      ),
    );
  }
}
