import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/languagePage.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
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
    List<Widget> finalWidget = [];
    if (widget.stats != null) {
     if (widget.stats.nbBoosters > 0) {
       finalWidget.add(buildStatsView());
     } else {
       finalWidget = [
         SizedBox(height: 20.0),
         Container( child: Center(child: Text(StatitikLocale.of(context).read('S_B1'), style: Theme.of(context).textTheme.headline1),)),
         Center(child: Text(StatitikLocale.of(context).read('S_B8'))),
         SizedBox(height: 20.0),
         Padding(
           padding: const EdgeInsets.all(16.0),
           child: drawImagePress(context, "PikaNoResult.png", 250.0),
         )
        ];
     }
    } else {
      finalWidget = [
        Container( child: Row( children: [
            SizedBox(width: 40.0),
            Image(image: AssetImage('assets/arrow.png'), height: 30.0,),
            SizedBox(width: 25.0),
            Flexible(child: Text(StatitikLocale.of(context).read('S_B2'), style: Theme.of(context).textTheme.headline5,)),
            ],)
        ),
        SizedBox(height: 20.0),
        drawImagePress(context, 'Arrozard.png', 350.0),
      ];
    }

    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              StatitikLocale.of(context).read('H_T1'), style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Card(
                      child: FlatButton(
                        child: widget.language != null ? Row(
                          children: [
                            Text(StatitikLocale.of(context).read('S_B0')),
                            SizedBox(width: 8.0),
                            Image(image: widget.language.create(), height: 30),
                            SizedBox(width: 8.0),
                            widget.subExt.image(hSize: 30),
                        ]) : Text(StatitikLocale.of(context).read('S_B0')),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                        },
                      )
                    ),
                  ],
                ),
              ] + finalWidget
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
      rarity.add(Text(StatitikLocale.of(context).read('S_B3')));
    }

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [Text(StatitikLocale.of(context).read('S_B4'), style: Theme.of(context).textTheme.headline5 ),
                Expanded(child: SizedBox()),
                Text(sprintf(StatitikLocale.of(context).read('S_B5'), [widget.stats.nbBoosters, widget.stats.anomaly]))
              ]),
              SizedBox(height: 8.0,),
              Text(StatitikLocale.of(context).read('S_B6')),
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
                      child: Text(StatitikLocale.of(context).read('S_B7')),
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
