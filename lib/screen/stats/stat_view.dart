import 'dart:math';

import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/stats/pie_chart.dart';
import 'package:statitikcard/services/models/card_set.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';

enum OptionShowState {
  realCount,
  boosterLuck,
}

class StatsViewOptions {
  int tabViewMode = 0;
  bool delta = false;
  bool print = false;
  OptionShowState showOption = OptionShowState.boosterLuck;
}

class StatsView extends StatelessWidget {
  final StatsData data;
  final StatsViewOptions options;

  const StatsView({required this.data, required this.options, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(data.stats != null);
    final translator = StatitikLocale.of(context);

    double divider = data.subExt != null ? data.subExt!.cardPerBooster.toDouble() : 11.0;
    List<Widget> types  = [];
    List<Widget> rarity = [];
    List<Widget> sets   = [];
    if( data.subExt!.seCards.isValid ) {
      data.stats!.countByRarity.forEach((rare, sum) {
        if(rare != Environment.instance.collection.unknownRarity) {
          double luck = sum.toDouble() / data.stats!.nbBoosters;
          if(luck > 0)
          {
            double? userLuck;
            if(data.userStats != null && data.userStats!.nbBoosters > 0) {
              int userCount = data.userStats!.countByRarity[rare] ?? 0;
              userLuck = userCount.toDouble() / data.userStats!.nbBoosters;
            }
            rarity.add( buildLine(getImageRarity(rare, data.language!), sum, luck, rare.color, divider, userLuck) );
          }
        }
      });

      int typeId=0;
      data.stats!.countByType.forEach( (sum) {
        double luck = sum.toDouble() / data.stats!.nbBoosters;
        if(luck > 0)
        {
          double? userLuck;
          if(data.userStats != null && data.userStats!.nbBoosters > 0) {
            int userCount = data.userStats!.countByType[typeId];
            userLuck = userCount.toDouble() / data.userStats!.nbBoosters;
          }
          types.add( buildLine([getImageType(TypeCard.values[typeId])], sum, luck, typeColors[typeId], divider, userLuck) );
        }
        typeId += 1;
      });

      data.stats!.countBySet.forEach((set, sum) {
        double luck = sum.toDouble() / data.stats!.nbBoosters;
        if(luck > 0)
        {
          double? userLuck;
          if(data.userStats != null && data.userStats!.nbBoosters > 0) {
            int userCount = data.userStats!.countBySet[set] ?? 0;
            userLuck = userCount.toDouble() / data.userStats!.nbBoosters;
          }
          sets.add( buildLine([set.imageWidget(height: 30.0)], sum, luck, set.color, divider, userLuck) );
        }
      });

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
                const Spacer(),
                data.stats!.anomaly > 0 ? Text(sprintf(translator.read('S_B5'), [data.stats!.nbBoosters, data.stats!.anomaly]))
                    : Text(sprintf(translator.read('S_B13'), [data.stats!.nbBoosters]))
              ]),
              if(!options.print && options.showOption == OptionShowState.boosterLuck) Text(sprintf(translator.read('S_B6'), [divider.toInt()])),
              if(!options.print && options.showOption == OptionShowState.boosterLuck) const SizedBox(height: 8.0,),
              Text(translator.read('S_B21'), style: Theme.of(context).textTheme.headline6 ),
              ListView(
                shrinkWrap: true,
                primary: false,
                children: rarity,
              ),
              Text(translator.read('S_B20'), style: Theme.of(context).textTheme.headline6 ),
              ListView(
                shrinkWrap: true,
                primary: false,
                children: sets,
              ),
              Text(translator.read('S_B22'), style: Theme.of(context).textTheme.headline6 ),
              ListView(
                shrinkWrap: true,
                primary: false,
                children: types,
              ),
              if(!options.print && energyData) Text(translator.read('S_B12'), style: Theme.of(context).textTheme.headline5 ),
              if(!options.print && energyData) PieChartEnergies(allStats: data.stats!),
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
        SizedBox(width: 30, child:Text(value, style: TextStyle(fontSize: 9, color: color))),
      ];
    }

    return Row(
        children: [
          SizedBox(width: 50,child: Row( children: label)),
          Expanded(child: LinearPercentIndicator(
            lineHeight: 8.0,
            percent: (luck / divider).clamp(0.0, 1.0),
            progressColor: color,
          )),
          if(options.showOption == OptionShowState.boosterLuck) SizedBox(width: 45, child: Text('${luck.toStringAsFixed(3)}')),
          if(options.showOption == OptionShowState.realCount)   SizedBox(width: 45, child: Text(sum.toString())),
        ] + userInfo);
  }
}

class ProductWidget extends StatelessWidget {
  final ProductRequested  pr;
  final bool              showCount;

  const ProductWidget(this.pr, this.showCount, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool productImage = pr.product.hasImages() && Environment.instance.showPressProductImages;

    String nameProduct = pr.product.name;
    if(showCount) {
      nameProduct += ' (${pr.count})';
    }

    return Card(
        color: pr.color,
        child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(productImage) pr.product.image(),
            if(productImage) Text(
              nameProduct, textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(fontSize: ((pr.product.name.length > 15) ? 8 : 13)))
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

  const StatsCompletionBooster(this.data, {Key? key}) : super(key: key);

  @override
  State<StatsCompletionBooster> createState() => _StatsCompletionBoosterState();
}

class ProbaResult {
  int minimum;
  int mean;

  ProbaResult(this.minimum, this.mean);
}

class ResultProbability {
  Map<Rarity, double> info = {};
  bool                valid = false;

  bool isValid() {
    return valid && info.isNotEmpty;
  }
}

class _StatsCompletionBoosterState extends State<StatsCompletionBooster> {
  ProbaResult full = ProbaResult(0,0);
  Map<CardSet, ProbaResult> bySets = {};
  bool approximated = false;

  @override
  void initState() {
    var statsExtension = widget.data.subExt!.stats;

    // Remove energy / other sets (now draw CAN'T be equal to 1)
    statsExtension.allSets.remove(Environment.instance.collection.sets[6]);
    statsExtension.allSets.remove(Environment.instance.collection.sets[7]);
    statsExtension.allSets.remove(Environment.instance.collection.sets[8]);

    // Compute full expansion
    ResultProbability result = computeProbabilities(statsExtension, statsExtension.allSets);
    if( result.isValid() ) {
      adminControlData(result.info);
      full = computeCompletion(statsExtension, result.info);
    }

    // Compute by important set of expansion
    statsExtension.allSets.forEach((set) {
      ResultProbability resultSet = computeProbabilities(statsExtension, [set]);
      if( resultSet.isValid() ) {
        bySets[set] = computeCompletion(statsExtension, resultSet.info);
      }
    });

    super.initState();
  }

  ResultProbability computeProbabilities(StatsExtension statsExtension, List<CardSet> setSelected) {
    assert(widget.data.stats != null);
    var result = ResultProbability();
    int     countZero = 0;
    int?    minRarity;
    Rarity  idMinRarity = Environment.instance.collection.unknownRarity!;
    List<Rarity> findEmpty = [];
    int countEmpty = 0;

    // Compute basic info and search invalid data
    for(CardSet s in setSelected) {
      if(widget.data.stats!.countBySetByRarity[s] != null) {
        var mapRarityStat = widget.data.stats!.countBySetByRarity[s]!;
        var mapRarityExt = statsExtension.countBySetByRarity[s]!;
        var raritiesSelected = statsExtension.allRarityPerSets[s]!;
        for (Rarity r in raritiesSelected) {
          int validRarity = mapRarityStat[r] ?? 0;
          if (validRarity == 0) {
            countZero += 1;
            findEmpty.add(r);
            countEmpty += mapRarityExt[r]!;
          } else {
            if (minRarity != null) {
              if (validRarity < minRarity) {
                minRarity = min(minRarity, validRarity);
                idMinRarity = r;
              }
            } else {
              minRarity = validRarity;
              idMinRarity = r;
            }
          }
          if (result.info.containsKey(r)) {
            result.info[r] = result.info[r]! + validRarity.toDouble();
          } else {
            result.info[r] = validRarity.toDouble();
          }
        }
      }
    }

    if(countZero > 0 && minRarity != null) {
      approximated = true;

      // Remove one card for probability (or cut in two if only one)
      double unityProbability = 1.0;
      if(statsExtension.countByRarity[idMinRarity]! <= 1){
        unityProbability = 0.5;
        result.info[idMinRarity] = statsExtension.countByRarity[idMinRarity]! / 2;
      } else {
        result.info[idMinRarity] = statsExtension.countByRarity[idMinRarity]!-1;
      }
      assert(result.info[idMinRarity]! > 0.0);
      unityProbability = unityProbability / countEmpty.toDouble();

      // Fill invalid data
      findEmpty.forEach((r) {
        var proba = unityProbability * statsExtension.countByRarity[r]!;
        result.info[r] = proba;
        assert(proba > 0.0);
      });
    }
    result.valid = minRarity != null;
    return result;
  }

  void adminControlData(info) {
    if(Environment.instance.isAdministrator()) {
      // Control
      double count = 0.0;
      info.forEach((key, value) {
        count += value;

        printOutput("${key.id.toString().padRight(15)}: $value");

        if(value == 0) {
          throw StatitikException("Control error");
        }
      });

      printOutput("Compare count: ${widget.data.stats!.totalCards.round()} == ${count.round()}");
      //assert(widget.data.stats!.totalCards.round() == count.round(),
      //       "${widget.data.stats!.totalCards.round()} == ${count.round()}");
    }
  }

  ProbaResult computeCompletion(StatsExtension statsExtension, Map<Rarity, double> info) {
    int minimum = 0;
    int mean    = 0;

    for(Rarity r in info.keys) {
      int nbRarity = statsExtension.countByRarity[r] ?? 0;
      // Filter can be more than real data
      if( nbRarity > 0) {
        assert(info[r]! > 0.0, "Nb card exist but 0 ?");
        double coutPerBooster = info[r]! / widget.data.stats!.nbBoosters.toDouble();
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

  Widget lineResult(Widget s0, String d0, String s1, String s2){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(child: Column(
            children: [
              s0,
              if(d0.isNotEmpty)
                Text(d0, style: const TextStyle(fontSize: 8)),
            ],
          )),
          SizedBox(width: 100, child: Center(child:Text(s1))),
          SizedBox(width: 100, child: Center(child:Text(s2)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> setsInfo = [];
    bySets.forEach((set, value) {
      var name = set.names.name(widget.data.language!);
      setsInfo.add(lineResult(Row(children: [
          set.imageWidget(width: 20),
          const SizedBox(width: 5),
          Text(name, style: TextStyle(fontSize: name.length > 13 ? 11 : 14))
        ]), "",
        value.minimum.toString(), value.mean.toString()));
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text(StatitikLocale.of(context).read('SCB_T0'), style: Theme.of(context).textTheme.headline5)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.warning_amber_rounded), Text(StatitikLocale.of(context).read('devBeta'), style: const TextStyle(color: Colors.orange))]),
            const SizedBox(height: 8),
            Text(StatitikLocale.of(context).read('SCB_B0'), style: const TextStyle(fontSize: 12)),
            if(approximated)
              Row(children: [
                const Icon(Icons.warning_amber_rounded),
                Text(StatitikLocale.of(context).read('SCB_B8'), style: const TextStyle(fontSize: 9)),
              ]),
            const SizedBox(height: 8),
            lineResult(const Text(""), "", StatitikLocale.of(context).read('SCB_B1'),StatitikLocale.of(context).read('SCB_B2')),
            lineResult(Text(StatitikLocale.of(context).read('SCB_B5')), StatitikLocale.of(context).read('SCB_B6'), full.minimum.toString(), full.mean.toString()),
          ]+setsInfo,
        ),
      )
    );
  }
}