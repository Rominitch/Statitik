import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:statitikcard/screen/languagePage.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class StatsPage extends StatefulWidget {
  Language     language;
  SubExtension subExt;
  Product      product;
  Stats        stats;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      widget.language = language;
      widget.subExt   = subExt;
    });

    //Launch compute stats
    waitStats();
  }

  Future<void> waitStats() async {
    Environment.instance.getStats(widget.subExt, widget.product).then( (stats) {
      widget.stats = stats;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Statistiques', style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Card(
                      child: FlatButton(
                        child: widget.language != null ? Row(
                          children: [
                            Text('Extension'),
                            SizedBox(width: 8.0),
                            Image(image: widget.language.create(), height: 30),
                            SizedBox(width: 8.0),
                            widget.subExt.image(hSize: 30),
                        ]) : Text('Extension'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                        },
                      )
                    ),
                  ],
                ),
                widget.stats != null
                ? (widget.stats.nbBoosters > 0 ? buildStatsView()
                : Container( child: Center(child: Text('Aucun résultat'),)))
                : Container( child: Center(child: Text('Sélectionner une extension'),)),
              ],
            ),
          )
        )
    );
  }

  Widget buildLine(label, luck, color) {
    return Row(
      children: [
        Container(child: Row( children: label), width: 50,),
        Expanded(child: LinearPercentIndicator(
        lineHeight: 8.0,
        percent: (luck / 10.0).clamp(0.0, 1.0),
        progressColor: color,
        )),
        Container(child:Text('${luck.toStringAsFixed(3)}'), width: 50)
    ]);
  }

  Widget buildStatsView() {
    List<Widget> rarity = [];
    {
      double sum=0;
      widget.stats.countEnergy.forEach((number) {sum += number.toDouble(); });
      double luck = sum / widget.stats.nbBoosters;
      if(luck > 0)
        rarity.add( buildLine([Icon(Icons.battery_charging_full),],
                    luck, Colors.yellowAccent));
    }

    if( widget.subExt.validCard ) {
      for( var rare in Rarity.values ) {
        if(rare == Rarity.Unknown)
          continue;
        double luck = widget.stats.countByRarity[rare.index] / widget.stats.nbBoosters;
        if(luck > 0)
          rarity.add( buildLine(getImageRarity(rare), luck, rarityColors[rare.index]) );
      }

      for( var mode in [Mode.Reverse, Mode.Halo] ) {
        double luck = widget.stats.countByMode[mode.index] / widget.stats.nbBoosters;
        if(luck > 0)
          rarity.add( buildLine([Image(image: AssetImage('assets/carte/${modeImgs[mode]}.png'), height: 30.0)], luck, modeColors[mode.index]) );
      }
    } else {
      rarity.add(Text('Les données de l\'extension ne sont pas encore présentes: les statistiques sont limitées.'));
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
                Text('${widget.stats.nbBoosters} dont ${widget.stats.anomaly} avec anomalie')
              ]),
              SizedBox(height: 8.0,),
              Text('Répartition pour 10 cartes'),
              SizedBox(height: 8.0,),
              ListView(
                shrinkWrap: true,
                primary: false,
                children: rarity,
              ),
              PieChartGeneric(allStats: widget.stats),
              Card(
                  color: Colors.grey[800],
                  child: FlatButton(
                      child: Text('Détails de l\'extension'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StatsExtensionsPage(stats: widget.stats)));
                  }
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
