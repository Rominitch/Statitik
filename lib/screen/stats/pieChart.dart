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
    if( widget.visu == Visualize.Type) {
      for(var type in Type.values) {
        final isTouched = type.index == touchedIndex;
        //final double fontSize = isTouched ? 20 : 16;
        final double radius = isTouched ? 50 : 30;
        //final double widgetSize = isTouched ? 55 : 0;
        int count = widget.stats.countByType[type.index];
        if (count > 0) {
          sections.add(PieChartSectionData(
            color: typeColors[type.index],
            value: count.toDouble(),
            title: '',
            radius: radius,
            //titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
            badgeWidget: getImageType(type),
            badgePositionPercentageOffset: .98,
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
