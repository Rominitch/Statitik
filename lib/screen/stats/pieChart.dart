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

  @override
  void initState() {

    super.initState();
  }

  void createPie() {
    for(var energy in energies) {
      final isTouched = energy.index == touchedIndex;
      final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 110 : 100;
      final double widgetSize = isTouched ? 55 : 40;
      int count = widget.allStats.countEnergy[energy.index];

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

  @override
  Widget build(BuildContext context) {
    createPie();

    return Container(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: PieChart(
          PieChartData(
              pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                setState(() {
                  if (pieTouchResponse.touchInput is FlLongPressEnd ||
                      pieTouchResponse.touchInput is FlPanEnd) {
                    touchedIndex = -1;
                  } else {
                    touchedIndex = pieTouchResponse.touchedSectionIndex;
                  }
                });
              }),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: sections),
        ),
      ),
    );
  }
}