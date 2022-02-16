import 'dart:math';

import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/Rarity.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

enum OptionShowState {
  RealCount,
  BoosterLuck,
}

class StatsViewOptions {
  bool delta = false;
  bool print = false;
  OptionShowState showOption = OptionShowState.BoosterLuck;
}

class StatsView extends StatelessWidget {

  final StatsData data;
  final StatsViewOptions options;

  StatsView({required this.data, required this.options});

  @override
  Widget build(BuildContext context) {
    assert(data.stats != null);
    final translator = StatitikLocale.of(context);

    double divider = data.subExt != null ? data.subExt!.cardPerBooster.toDouble() : 11.0;
    List<Widget> rarity = [];
    {
      int sum=0;
      data.stats!.countEnergy.forEach((number) {sum += number; });
      double luck = sum.toDouble() / data.stats!.nbBoosters;
      if(luck > 0) {
        double? userLuck;
        if(data.userStats != null && data.userStats!.nbBoosters > 0) {
          double userSum=0;
          data.userStats!.countEnergy.forEach((number) {userSum += number.toDouble(); });
          userLuck = (userSum / data.userStats!.nbBoosters);
        }
        rarity.add(buildLine([ Icon(Icons.battery_charging_full), ], sum, luck, Colors.yellowAccent, divider, userLuck));
      }
    }

    if( data.subExt!.seCards.isValid ) {
      for(Rarity rare in Environment.instance.collection.rarities.values ) {
        if(rare == unknownRarity)
          continue;
        int sum = data.stats!.countByRarity[rare.id];
        double luck = sum.toDouble() / data.stats!.nbBoosters;
        if(luck > 0)
        {
          double? userLuck = (data.userStats != null && data.userStats!.nbBoosters > 0) ? (data.userStats!.countByRarity[rare.id] / data.userStats!.nbBoosters) : null;
          rarity.add( buildLine(getImageRarity(rare), sum, luck, rare.color, divider, userLuck) );
        }
      }

      for( var mode in [Mode.Reverse, Mode.Halo] ) {
        int sum = data.stats!.countByMode[mode.index];
        double luck = sum.toDouble() / data.stats!.nbBoosters;
        if(luck > 0)
        {
          double? userLuck = (data.userStats != null && data.userStats!.nbBoosters > 0) ? (data.userStats!.countByMode[mode.index] / data.userStats!.nbBoosters) : null;
          rarity.add( buildLine([Image(image: AssetImage('assets/carte/${modeImgs[mode]}.png'), height: 30.0)], sum, luck, modeColors[mode.index], divider, userLuck) );
        }
      }
    } else {
      rarity.add(Text(translator.read('S_B3')));
    }
    final energyData = data.stats!.hasEnergy();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [Text(translator.read('S_B4'), style: Theme.of(context).textTheme.headline5 ),
                Expanded(child: SizedBox()),
                data.stats!.anomaly > 0 ? Text(sprintf(translator.read('S_B5'), [data.stats!.nbBoosters, data.stats!.anomaly]))
                    : Text(sprintf(translator.read('S_B13'), [data.stats!.nbBoosters]))
              ]),
              if(!options.print && options.showOption == OptionShowState.BoosterLuck) Text(sprintf(translator.read('S_B6'), [divider.toInt()])),
              if(!options.print && options.showOption == OptionShowState.BoosterLuck) SizedBox(height: 8.0,),
              ListView(
                shrinkWrap: true,
                primary: false,
                children: rarity,
              ),
              if(!options.print && energyData) Text(translator.read('S_B12'), style: Theme.of(context).textTheme.headline5 ),
              if(!options.print && energyData) PieChartGeneric(allStats: data.stats!),
            ]
        ),
      ),
    );
  }

  Widget buildLine(label, sum, luck, color, divider, [double? userLuck]) {
    List<Widget> userInfo = [];
    if(userLuck != null ) {
      final double deltaUserLuck = userLuck - luck;
      final Color color = deltaUserLuck >= 0 ? Colors.green : Colors.deepOrange;
      final IconData icon = (deltaUserLuck > 0) ? Icons.keyboard_arrow_up : ((deltaUserLuck == 0) ? Icons.remove : Icons.keyboard_arrow_down);
      final String value = (deltaUserLuck > 0 && options.delta ? '+' : '') + (options.delta ? deltaUserLuck.toStringAsFixed(3) : userLuck.toStringAsFixed(3) );
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
          if(options.showOption == OptionShowState.BoosterLuck) Container(child: Text('${luck.toStringAsFixed(3)}'), width: 45),
          if(options.showOption == OptionShowState.RealCount)   Container(child: Text(sum.toString()), width: 45),
        ] + userInfo);
  }
}

class ProductCard extends StatelessWidget {
  final Product prod;
  final bool    showCount;

  ProductCard(this.prod, this.showCount);

  @override
  Widget build(BuildContext context) {
    bool productImage = prod.hasImages() && Environment.instance.showPressProductImages;

    String nameProduct = prod.name;
    if(showCount) {
      nameProduct += ' (${prod.countProduct()})';
    }

    return Card(
        color: prod.color,
        child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(productImage) prod.image(),
            if(productImage) Text(
              nameProduct, textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(fontSize: ((prod.name.length > 15) ? 8 : 13)))
            else
              Text(nameProduct, textAlign: TextAlign.center, softWrap: true,),
          ]
          ),
        )
    );
  }
}

class StatsCompletionBooster extends StatefulWidget {
  final StatsData data;

  StatsCompletionBooster(this.data);

  @override
  State<StatsCompletionBooster> createState() => _StatsCompletionBoosterState();
}

class ProbaResult {
  int minimum;
  int mean;

  ProbaResult(this.minimum, this.mean);
}

class _StatsCompletionBoosterState extends State<StatsCompletionBooster> {
  //Map<CardSet, ProbaResult> setProba = {};
  ProbaResult full = ProbaResult(0,0);
  bool approximated = false;

  @override
  void initState() {
    var statsExtension = StatsExtension(subExt: widget.data.subExt!);

    Map<Rarity, double> info = computeProbabilities(statsExtension, statsExtension.rarities);
/*
    statsExtension.allSets.forEach((set) {
      setProba[set] = computeCompletion(statsExtension, statsExtension.rarities, info);
    });

 */

    full = computeCompletion(statsExtension, statsExtension.rarities, info);

    super.initState();
  }

  Map<Rarity, double> computeProbabilities(StatsExtension statsExtension, List raritiesSelected) {
    Map<Rarity, double> info = {};
    int     countZero = 0;
    int?    minRarity;
    Rarity  idMinRarity = unknownRarity!;
    List<Rarity> findEmpty = [];
    int countEmpty = 0;

    // Compute basic info and search invalid data
    for(Rarity r in raritiesSelected) {
      int validRarity = widget.data.stats!.countByRarity[r.id];
      if(validRarity == 0) {
        countZero += 1;
        findEmpty.add(r);
        countEmpty += statsExtension.countByRarity[r.id];
      } else {
        if( minRarity != null) {
          if(validRarity < minRarity) {
            minRarity   = min(minRarity, validRarity);
            idMinRarity = r;
          }
        } else {
          minRarity   = validRarity;
          idMinRarity = r;
        }
      }
      info[r] = validRarity.toDouble();
    }

    if(countZero > 0 && minRarity != null) {
      approximated = true;

      // Remove one card for probability (or cut in two if only one)
      double unityProbability = 1.0;
      if(statsExtension.countByRarity[idMinRarity.id] == 1){
        unityProbability = 0.5;
        info[idMinRarity] = statsExtension.countByRarity[idMinRarity.id] / 2;
      } else {
        info[idMinRarity] = statsExtension.countByRarity[idMinRarity.id]-1;
      }
      unityProbability = unityProbability / countEmpty.toDouble();

      // Fill invalid data
      findEmpty.forEach((r) {
          info[r] = unityProbability * statsExtension.countByRarity[r.id];
      });
    }
/*
    // Control
    double count = 0.0;
    info.forEach((key, value) {
      count += value;
    });

    assert(widget.data.stats!.totalCards.round() == count.round(), "${widget.data.stats!.totalCards.round()} == ${count.round()}");
*/
    return info;
  }

  ProbaResult computeCompletion(StatsExtension statsExtension, List raritiesSelected, Map<Rarity, double> info) {
    int minimum = 0;
    int mean    = 0;

    for(Rarity r in raritiesSelected) {
      int nbRarity = statsExtension.countByRarity[r.id];
      // Filter can be more than real data
      if( nbRarity > 0) {
        double coutPerBooster = info[r]!
            / widget.data.stats!.nbBoosters.toDouble();
        minimum = max(minimum, (nbRarity.toDouble() / coutPerBooster).ceil());

        double suite = 0.0;
        for (int i = 1; i <= nbRarity; i += 1) {
          suite += 1.0 / i.toDouble();
        }
        //double probability = coutPerBooster / widget.data.subExt!.cardPerBooster.toDouble();
        double probability = coutPerBooster;
        mean = max(mean, ((nbRarity.toDouble() / probability) * suite).ceil());
      }
    }

    return ProbaResult(minimum, mean);
  }

  Widget lineResult(String s0, String d0, String s1, String s2){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(child: Column(
            children: [
              Text(s0),
              Text(d0, style: TextStyle(fontSize: 8)),
            ],
          )),
          Container(width: 100, child: Center(child:Text(s1))),
          Container(width: 100, child: Center(child:Text(s2)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text(StatitikLocale.of(context).read('SCB_T0'), style: Theme.of(context).textTheme.headline5)),
            SizedBox(height: 8),
            Text(StatitikLocale.of(context).read('SCB_B0'), style: TextStyle(fontSize: 12)),
            if(approximated)
              Row(children: [
                Icon(Icons.warning_amber_rounded),
                Text(StatitikLocale.of(context).read('SCB_B8'), style: TextStyle(fontSize: 9)),
              ]),
            SizedBox(height: 8),
            lineResult("", "", StatitikLocale.of(context).read('SCB_B1'),StatitikLocale.of(context).read('SCB_B2')),
            //lineResult(StatitikLocale.of(context).read('SCB_B3'), StatitikLocale.of(context).read('SCB_B7'), base.minimum.toString(), base.mean.toString()),
            //if(parallel != null)
            //  lineResult(StatitikLocale.of(context).read('SCB_B4'), "", parallel!.minimum.toString(), parallel!.mean.toString()),
            lineResult(StatitikLocale.of(context).read('SCB_B5'), StatitikLocale.of(context).read('SCB_B6'), full.minimum.toString(), full.mean.toString()),
          ],
        ),
      )
    );
  }
}