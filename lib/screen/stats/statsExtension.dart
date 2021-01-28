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
    List<Widget> cards = [];
    int id=0;
    final double ratio = 100.0 / widget.stats.totalCards;

    for(int count in widget.stats.count) {
      cards.add(Card(
        color: Colors.grey[700],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
          Text('${id+1}'),
          Text((count * ratio).toStringAsPrecision(2)+'%'),
        ]),
      ));
      id += 1;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Statistiques de l\'extension', style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Répartition des cartes', style: Theme.of(context).textTheme.headline5),
                              PieExtension(stats: widget.statsExtension, visu: Visualize.Type),
                              SizedBox(height: 10.0,),
                              PieExtension(stats: widget.statsExtension, visu: Visualize.Rarity),
                            ]
                        ),
                      )
                  ),
                  SizedBox(height: 10.0,),
                  Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Fréquence par carte', style: Theme.of(context).textTheme.headline5),
                              GridView.count(
                                crossAxisCount: 5,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                primary: false,
                                children: cards,
                              ),
                            ]
                        ),
                      )
                  ),
                ]
              ),
            )
        )
    );
  }
}
