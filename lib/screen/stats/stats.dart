import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:statitikcard/screen/languagePage.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Language language;
  SubExtension subExt;
  Product      product;
  Stats        stats;

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      this.language = language;
      this.subExt   = subExt;
    });

    //Launch compute stats
    waitStats();
  }

  Future<void> waitStats() async {
    Environment.instance.getStats(subExt, product).then( (stats) {
      this.stats = stats;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Statistiques'),
        ),
        body: SafeArea(
          child:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Card(
                      child: FlatButton(
                        child: language != null ? Row(
                          children: [
                            Text('Extension'),
                            SizedBox(width: 8.0),
                            Image(image: language.create(), height: 30),
                            SizedBox(width: 8.0),
                            subExt.image(),
                        ]) : Text('Extension'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                        },
                      )
                    ),
                    Card(
                      child: FlatButton(
                      child: product == null ? Text('Tous les produits')
                          : Text(product.name),
                      onPressed: () {}
                      ),
                    ),
                  ],
                ),
                stats != null
                ? (stats.nbBoosters > 0 ? buildStatsView()
                : Container( child: Center(child: Text('Aucun résultat'),)))
                : Container( child: Center(child: Text('Sélectionner une extension'),)),
              ],
            ),
          )
        )
    );
  }

  Widget buildStatsView() {
    List<Widget> rarity = [];
    for( var rare in Rarity.values ) {
      double luck = stats.countByRarity[rare.index] / stats.nbBoosters;
      rarity.add( Row(
            children: [
              Container(child: Row( children: getImageRarity(rare),), width: 50,),
              Expanded(child: LinearPercentIndicator(
                lineHeight: 8.0,
                percent: (luck / 10.0).clamp(0.0, 1.0),
                progressColor: Colors.blue,
              )),
                Container(child:Text('${luck.toStringAsFixed(3)}'), width: 40)
            ]
          ));
    }

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [Text('Booster   ', style: Theme.of(context).textTheme.headline5 ),
                Expanded(child: SizedBox()),
                Text('${stats.nbBoosters} dont ${stats.anomaly} avec anomalie')
              ]),
              SizedBox(height: 8.0,),
              Text('Répartition pour 10 cartes'),
              SizedBox(height: 8.0,),
              ListView(
                shrinkWrap: true,
                children: rarity,
              ),
              PieChartGeneric(allStats: stats),
            ]
          ),
        ),
      ),
    );
  }
}
