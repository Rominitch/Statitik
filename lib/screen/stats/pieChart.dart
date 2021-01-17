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
              /*
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
              */
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