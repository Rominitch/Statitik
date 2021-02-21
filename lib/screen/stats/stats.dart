import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class StatsData {
  Language     language;
  SubExtension subExt;
  Product      product;
  int          category = -1;
  Stats        stats;
  Stats        userStats;
}

class StatsPage extends StatefulWidget {
  final StatsData d = StatsData();

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool delta=false;

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      // Set old filter
      widget.d.category = -1;
      widget.d.product  = null;
      // Change selection
      widget.d.language = language;
      widget.d.subExt   = subExt;
    });

    //Launch compute stats
    waitStats();
  }

  Future<void> waitStats() async {
    // Clean old result
    widget.d.userStats = null;
    widget.d.stats     = null;

    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(widget.d.subExt, widget.d.product, widget.d.category).then( (stats) {
      widget.d.stats = stats;
      // Get user info after
      if(env.user != null) {
        env.getStats(widget.d.subExt, widget.d.product, widget.d.category, env.user.idDB).then( (ustats) {
          widget.d.userStats = ustats;
          setState(() {});
        });
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> finalWidget = [];
    final String productButton = widget.d.product == null
        ? (widget.d.category == -1) ? StatitikLocale.of(context).read('S_B9') : Environment.instance.collection.category[widget.d.category]
        : widget.d.product.name;

    if(widget.d.stats != null) {
     if(widget.d.stats.nbBoosters > 0) {
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
     if(widget.d.subExt.validCard)
       finalWidget.add(
         Card(
           color: Colors.grey[800],
           child: FlatButton(
               child: Text(StatitikLocale.of(context).read('S_B7')),
               onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => StatsExtensionsPage(stats: widget.d.stats)));
               }
           ),
         ));
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
          actions: [
            if(widget.d.userStats != null)
              FlatButton(
                  child: Icon(Icons.settings),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context)
                      {
                        return StatefulBuilder(
                          builder: (context, setState) { return AlertDialog(
                            title: Text(StatitikLocale.of(context).read('H_T2')),
                            content: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CheckboxListTile(
                                    title: Text(StatitikLocale.of(context).read('S_B10')),
                                    value: delta,
                                    onChanged: (newValue) {
                                      setState(() {
                                        delta = newValue;
                                      });
                                    },
                                  ),
                                ]
                              ),
                            ),
                          );
                          }
                      );
                     }).then( (result) { setState((){}); } );
                  }
             )
          ],
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
                        child: widget.d.language != null ? Row(
                          children: [
                            Text(StatitikLocale.of(context).read('S_B0')),
                            SizedBox(width: 8.0),
                            Image(image: widget.d.language.create(), height: 30),
                            SizedBox(width: 8.0),
                            widget.d.subExt.image(hSize: 30),
                        ]) : Text(StatitikLocale.of(context).read('S_B0')),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                        },
                      )
                    ),
                    if( widget.d.language != null && widget.d.subExt != null )
                      Expanded(
                        child: Card( child: FlatButton(
                            child: Text(productButton, softWrap: true, style: TextStyle(fontSize: (productButton.length > 20) ? 10 : 14),),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.MultiSelection, language: widget.d.language, subExt: widget.d.subExt, afterSelected: afterSelectProduct) ));
                            },
                          )
                    ),
                      ),
                  ],
                ),
              ] + finalWidget
            ),
          )
        )
    );
  }

  void afterSelectProduct(BuildContext context, Language language, Product product, int category) {
    Navigator.pop(context);
    setState(() {
      if(product != null) {
        widget.d.product  = product;
        widget.d.category = -1;
      } else if( category != -1 ) {
        widget.d.product  = null;
        widget.d.category = category;
      } else { // All products
        widget.d.product  = null;
        widget.d.category = -1;
      }
      waitStats();
    });
  }

  Widget buildLine(label, luck, color, divider, [double userLuck]) {
    List<Widget> userInfo = [];
    if(userLuck != null ) {
      final double deltaUserLuck = userLuck - luck;
      final Color color = deltaUserLuck >= 0 ? Colors.green : Colors.deepOrange;
      final IconData icon = (deltaUserLuck > 0) ? Icons.keyboard_arrow_up : ((deltaUserLuck == 0) ? Icons.remove : Icons.keyboard_arrow_down);
      final String value = (deltaUserLuck > 0 && delta ? '+' : '') + (delta ? deltaUserLuck.toStringAsFixed(3) : userLuck.toStringAsFixed(3) );
      userInfo = [
        Icon(icon, color: color),
        Container(child:Text(value, style: TextStyle(fontSize: 9, color: color)), width: 30),
      ];
    }

    return Row(
      children: [
        Container(child: Row( children: label), width: 50,),
        Expanded(child: LinearPercentIndicator(
        lineHeight: 8.0,
        percent: (luck / divider).clamp(0.0, 1.0),
        progressColor: color,
        )),
        Container(child:Text('${luck.toStringAsFixed(3)}'), width: 45),
    ] + userInfo);
  }

  Widget buildStatsView() {
    double divider = 11.0;
    List<Widget> rarity = [];
    {
      double sum=0;
      widget.d.stats.countEnergy.forEach((number) {sum += number.toDouble(); });
      double luck = sum / widget.d.stats.nbBoosters;
      if(luck > 0) {
        double userLuck;
        if(widget.d.userStats != null && widget.d.userStats.nbBoosters > 0) {
          double userSum=0;
          widget.d.userStats.countEnergy.forEach((number) {userSum += number.toDouble(); });
          userLuck = (userSum / widget.d.userStats.nbBoosters);
        }
        rarity.add(buildLine([ Icon(Icons.battery_charging_full), ], luck, Colors.yellowAccent, divider, userLuck));
      }
    }

    if( widget.d.subExt.validCard ) {
      for( var rare in Rarity.values ) {
        if(rare == Rarity.Unknown)
          continue;
        double luck = widget.d.stats.countByRarity[rare.index] / widget.d.stats.nbBoosters;
        if(luck > 0)
        {
          double userLuck = (widget.d.userStats != null && widget.d.userStats.nbBoosters > 0) ? (widget.d.userStats.countByRarity[rare.index] / widget.d.userStats.nbBoosters) : null;
          rarity.add( buildLine(getImageRarity(rare), luck, rarityColors[rare.index], divider, userLuck) );
        }
      }

      for( var mode in [Mode.Reverse, Mode.Halo] ) {
        double luck = widget.d.stats.countByMode[mode.index] / widget.d.stats.nbBoosters;
        if(luck > 0)
        {
          double userLuck = (widget.d.userStats != null && widget.d.userStats.nbBoosters > 0) ? (widget.d.userStats.countByMode[mode.index] / widget.d.userStats.nbBoosters) : null;
          rarity.add( buildLine([Image(image: AssetImage('assets/carte/${modeImgs[mode]}.png'), height: 30.0)], luck, modeColors[mode.index], divider, userLuck) );
        }
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
                Text(sprintf(StatitikLocale.of(context).read('S_B5'), [widget.d.stats.nbBoosters, widget.d.stats.anomaly]))
              ]),
              SizedBox(height: 8.0,),
              Text(sprintf(StatitikLocale.of(context).read('S_B6'), [divider.toInt()])),
              SizedBox(height: 8.0,),
              ListView(
                shrinkWrap: true,
                primary: false,
                children: rarity,
              ),
              PieChartGeneric(allStats: widget.d.stats),

            ]
          ),
        ),
      ),
    );
  }
}
