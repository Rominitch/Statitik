import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:statitikcard/services/models.dart';

class PieChartGeneric extends StatefulWidget {
  final Stats allStats;

  PieChartGeneric({this.allStats});

  @override
  State<StatefulWidget> createState() => PieChartGenericState();
}

class PieChartGenericState extends State<PieChartGeneric> {
  int touchedIndex;
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

  PieExtension({this.stats, this.visu});

  @override
  _PieExtensionState createState() => _PieExtensionState();
}

class _PieExtensionState extends State<PieExtension> {
  int touchedIndex;
  List<PieChartSectionData> sections = [];

  void createPie() {
    sections.clear();

    final double ratio = 100.0 / widget.stats.subExt.cards.cards.length;
    if( widget.visu == Visualize.Type) {
      for(var type in Type.values) {
        final isTouched = type.index == touchedIndex;
        final double radius = isTouched ? 130 : 100;
        int count = widget.stats.countByType[type.index];
        if (count > 0) {
          sections.add(PieChartSectionData(
            color: typeColors[type.index],
            value: count.toDouble(),
            title: ( count * ratio ).toStringAsFixed(2) + ' %',
            radius: radius,
            titlePositionPercentageOffset: 0.8,
            titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
            badgeWidget: getImageType(type),
            badgePositionPercentageOffset: 1.15,
          )
          );
        }
      }
    } else {
      for(var rarity in Rarity.values) {
        final isTouched = rarity.index == touchedIndex;
        final double radius = isTouched ? 130 : 100;
        int count = widget.stats.countByRarity[rarity.index];
        if (count > 0) {
          sections.add(PieChartSectionData(
            color: rarityColors[rarity.index],
            value: count.toDouble(),
            title: ( count * ratio ).toStringAsFixed(2) + ' %',
            radius: radius,
            titlePositionPercentageOffset: 0.8,
            titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
            badgeWidget: Row( mainAxisSize: MainAxisSize.min,  children: getImageRarity(rarity), ),
            badgePositionPercentageOffset: 1.15,
          )
          );
        }
      }
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
              centerSpaceRadius: 60,
              sections: sections),
        ),
      ),
    );
  }
}
