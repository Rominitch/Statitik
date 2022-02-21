import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';

class PieChartGeneric extends StatefulWidget {
  final StatsBooster allStats;

  PieChartGeneric({required this.allStats});

  @override
  State<StatefulWidget> createState() => PieChartGenericState();
}

class PieChartGenericState extends State<PieChartGeneric> {
  int touchedIndex = -1;
  List<PieChartSectionData> sections = [];

  void createPie() {
    sections.clear();
    for(var energy in energies) {
      final isTouched = energy.index == touchedIndex;
      //final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 50 : 30;
      //final double widgetSize = isTouched ? 55 : 0;
      int count = widget.allStats.countEnergy[energy.index];
      if(count > 0) {
        sections.add( PieChartSectionData(
          color: energiesColors[energy.index],
          value: count.toDouble(),
          title: '',
          radius: radius,
          //titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          badgeWidget: energyImage(energy),
          badgePositionPercentageOffset: .98,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    createPie();

    return Container(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: PieChart(
          PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 70,
              sections: sections),
        ),
      ),
    );
  }
}

enum Visualize {
  Type,
  Rarity
}

class PieExtension extends StatefulWidget {
  final StatsExtension stats;
  final Visualize visu;

  PieExtension({required this.stats, required this.visu});

  @override
  _PieExtensionState createState() => _PieExtensionState();
}

class _PieExtensionState extends State<PieExtension> {
  int touchedIndex=-1;
  List<PieChartSectionData> sections = [];

  void createPie() {
    sections.clear();

    bool odd=false;
    final double ratio = 100.0 / widget.stats.subExt.seCards.cards.length;
    if( widget.visu == Visualize.Type) {
      for(var type in Type.values) {
        final isTouched = type.index == touchedIndex;
        final double radius = isTouched ? 130 : 100;
        int count = widget.stats.countByType[type.index];
        if (count > 0) {
          var percent = count * ratio;
          sections.add(PieChartSectionData(
            color: typeColors[type.index],
            value: count.toDouble(),
            title: "$count (${percent.toStringAsPrecision(2)}%)",
            radius: radius,
            titlePositionPercentageOffset: odd ? 0.7 : 0.4,
            titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
            badgeWidget: getImageType(type),
            badgePositionPercentageOffset: 1.15,
          )
          );
          odd = !odd;
        }
      }
    } else {
      final smallValue = 3.5;
      bool oldSmall = false;
      widget.stats.rarities.forEach( (rarity) {
        var isSmall = false;
        final isTouched = rarity.id == touchedIndex;
        final double radius = isTouched ? 110 : 90;
        int count = widget.stats.countByRarity[rarity] ?? 0;
        if (count > 0) {
          var percent = count * ratio;
          isSmall = percent < smallValue;

          sections.add(PieChartSectionData(
            color: rarity.color,
            value: count.toDouble(),
            title: "$count (${percent.toStringAsPrecision(2)}%)",
            radius: radius,
            titlePositionPercentageOffset: odd ? 0.75 : 0.5,
            titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
            badgeWidget: Row( mainAxisSize: MainAxisSize.min,  children: getImageRarity(rarity), ),
            badgePositionPercentageOffset: isSmall ? (oldSmall ? 1.35 : 1.15) : 1.2,
          )
          );
          odd = !odd;
          oldSmall = !oldSmall && isSmall;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    createPie();

    return Container(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: PieChart(
          PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: sections),
        ),
      ),
    );
  }
}
