import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';

class PieChartEnergies extends StatefulWidget {
  final StatsBooster allStats;

  PieChartEnergies({required this.allStats});

  @override
  State<StatefulWidget> createState() => PieChartEnergiesState();
}

class PieChartEnergiesState extends State<PieChartEnergies> {
  int touchedIndex = -1;
  List<PieChartSectionData> sections = [];

  @override
  void initState() {
    sections.clear();

    var countEnergy = widget.allStats.countEnergy.iterator;
    widget.allStats.subExt.seCards.energyCard.forEach((energy) {
      if(countEnergy.moveNext()) {
        final TypeCard energyType = energy.data.typeExtended ?? TypeCard.Unknown;
        final isTouched           = energyType.index == touchedIndex;
        final double radius       = isTouched ? 50 : 30;
        final int count           = countEnergy.current;

        if(count > 0) {
          sections.add( PieChartSectionData(
            color: typeColors[energyType.index],
            value: count.toDouble(),
            title: '',
            radius: radius,
            badgeWidget: getImageType(energyType),
            badgePositionPercentageOffset: .98,
          )
          );
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

  @override
  void initState() {
    createPie();
    super.initState();
  }

  void createPie() {
    sections.clear();

    bool odd=false;
    final double ratio = 100.0 / widget.stats.subExt.seCards.cards.length;
    if( widget.visu == Visualize.Type) {
      for(var type in TypeCard.values) {
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
            badgeWidget: Row( mainAxisSize: MainAxisSize.min,  children: getImageRarity(rarity, widget.stats.subExt.extension.language), ),
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
    //createPie();
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
