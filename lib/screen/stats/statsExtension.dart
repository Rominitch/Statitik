import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:statitikcard/screen/Cartes/CardViewer.dart';
import 'package:statitikcard/screen/Cartes/statsCard.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/screen/widgets/screenPrint.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class StatsExtensionsPage extends StatefulWidget {
  final Stats stats;
  final StatsData data;

  StatsExtensionsPage({required this.stats, required this.data});

  @override
  _StatsExtensionsPageState createState() => _StatsExtensionsPageState();
}

class _StatsExtensionsPageState extends State<StatsExtensionsPage> {
  late StatsExtension statsExtension;
  static const bool isCard=false;

  @override
  void initState() {
    statsExtension = StatsExtension(subExt: widget.stats.subExt);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*
    return Scaffold(
        appBar: AppBar(
          title: Text(
            StatitikLocale.of(context).read('SE_T'), style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            if(Environment.instance.user != null && Environment.instance.user!.admin) IconButton(
              icon: Icon(Icons.share_outlined),
              onPressed: () {
                print.shareReport(context, widget.stats.subExt.seCode);
              }
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        body: SafeArea(
            child: SingleChildScrollView(
              child:
     */
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
