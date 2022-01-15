import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
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
      for( var rare in Rarity.values ) {
        if(rare == Rarity.Unknown)
          continue;
        int sum = data.stats!.countByRarity[rare.index];
        double luck = sum.toDouble() / data.stats!.nbBoosters;
        if(luck > 0)
        {
          double? userLuck = (data.userStats != null && data.userStats!.nbBoosters > 0) ? (data.userStats!.countByRarity[rare.index] / data.userStats!.nbBoosters) : null;
          rarity.add( buildLine(getImageRarity(rare), sum, luck, rarityColors[rare.index], divider, userLuck) );
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



