import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class StatsCard extends StatefulWidget {
  final CardResults stats;
  StatsCard(this.stats);

  @override
  _StatsCardState createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {

  double _spaceBefore = 50.0;
  double _spaceAfter  = 30.0;

  Widget createCountWidget(int value) {
    return Container(child: Text(value.toString(), style: TextStyle(fontSize: ((value >= 1000) ? 10.0 : 14.0))),
      width: _spaceAfter,
    );
  }

  void updateContent(subEx, rarity, type, markers, regions) {
    var s = widget.stats.stats!;

    if(widget.stats.isSpecific()) {
      s.countSubExtension.entries.forEach( (item)
      {
        subEx.add( Row(
            children: [Container(child: item.key.image(hSize: 30.0), alignment: Alignment.centerLeft, width: _spaceBefore),
              Expanded(
                child: Card(color: Colors.grey,
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.value.map((i) => i.toString()).join(", "), maxLines: 5, softWrap: true),
                  ),
                ),
              ),
            ]
        )
        );
      });
    }

    double count = s.nbCards().toDouble();
    s.countRarity.entries.forEach((item) {
      var r = item.value.toDouble();
      rarity.add( Row(
          children: [ Container(
            child: Row( children: getImageRarity(item.key)), alignment: Alignment.centerLeft, width: _spaceBefore,),
            Expanded(child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: ( r / count).clamp(0.0, 1.0),
              progressColor: rarityColors[item.key.index],
            )),
            createCountWidget(item.value)
          ]));
    });

    s.countType.entries.forEach((item) {
      var r = item.value.toDouble();
      type.add( Row(
          children: [ Container(child: getImageType(item.key), alignment: Alignment.centerLeft, width: _spaceBefore, height: 25.0,),
            Expanded(child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: ( r / count).clamp(0.0, 1.0),
              progressColor: typeColors[item.key.index],
            )),
            createCountWidget(item.value)
          ]));
    });

    s.countMarker.entries.forEach((item) {
      var r = item.value.toDouble();
      markers.add( Row(
          children: [ Container(child: pokeMarker(item.key, height: 15.0), alignment: Alignment.centerLeft, width: _spaceBefore),
            Expanded(child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: ( r / count).clamp(0.0, 1.0),
              progressColor: markerColors[item.key.index],
            )),
            createCountWidget(item.value)
          ]));
    });

    PokeRegion.values.forEach((item) {
      var r = s.countRegion[item.index];
      if(r > 0) {
        if(item != PokeRegion.Nothing)
          regions.add(Row(
              children: [ Container(child: Text(regionName(context, item), style: TextStyle(fontSize: 10.0)), width: _spaceBefore),
                Expanded(child: LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: (r / count).clamp(0.0, 1.0),
                  progressColor: regionColors[item.index],
                )),
                createCountWidget(r),
              ])
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> subEx  = [];
    List<Widget> rarity = [];
    List<Widget> type   = [];
    List<Widget> markers = [];
    List<Widget> regions = [];

    // Brutal
    updateContent(subEx, rarity, type, markers, regions);

    return Card(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Text(sprintf(StatitikLocale.of(context).read('CA_B6'), [widget.stats.stats!.nbCards()]), style: Theme.of(context).textTheme.headline5)),
          ListView(
            primary: false,
            shrinkWrap: true,
            children: subEx,
          ),
          ListView(
            primary: false,
            shrinkWrap: true,
            children: rarity,
          ),
          SizedBox(height: 10.0),
          ListView(
            primary: false,
            shrinkWrap: true,
            children: type,
          ),
          SizedBox(height: 10.0),
          ListView(
            primary: false,
            shrinkWrap: true,
            children: markers,
          ),
          SizedBox(height: 10.0),
          ListView(
            primary: false,
            shrinkWrap: true,
            children: regions,
          ),
        ]
      ),
    )
    );
  }
}
/*
Container(child: Row( children: label), width: 50,),
          Expanded(child: LinearPercentIndicator(
            lineHeight: 8.0,
            percent: (luck / divider).clamp(0.0, 1.0),
            progressColor: color,
          )),
 */