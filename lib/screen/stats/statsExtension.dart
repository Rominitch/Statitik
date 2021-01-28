import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/services/models.dart';

class StatsExtensionsPage extends StatefulWidget {
  final Stats stats;
  StatsExtension statsExtension;

  StatsExtensionsPage({this.stats}) {
    statsExtension = StatsExtension(subExt: stats.subExt);
  }

  @override
  _StatsExtensionsPageState createState() => _StatsExtensionsPageState();
}

class _StatsExtensionsPageState extends State<StatsExtensionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Statistiques de l\'extension', style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Fréquence par carte')
                          ]
                      )
                  ),
                  SizedBox(height: 10.0,),
                  Card(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Répartition'),
                      PieExtension(stats: widget.statsExtension, visu: Visualize.Type),
                      PieExtension(stats: widget.statsExtension, visu: Visualize.Rarity),
                    ]
                    )
                  ),
                ]
              ),
            )
        )
    );
  }
}
