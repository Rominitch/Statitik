import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

enum StatsVisualization
{
  Title,
  ByRarity,
  ByType,
  ByMarker,
  ByRegion,
}

class StatsCard extends StatefulWidget {
  final CardResults stats;
  final bool showTitle;
  final bool showByRarity;
  final bool showByType;
  final bool showByMarker;
  final bool showByRegion;
  final bool showBySubEx;

  StatsCard(this.stats, { this.showTitle=true,
  this.showByRarity=true,
  this.showByType=true,
  this.showByMarker=true,
  this.showByRegion=true,
  this.showBySubEx=true});

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
          children: [ Container(child: pokeMarker(context, item.key, height: 15.0), alignment: Alignment.centerLeft, width: _spaceBefore),
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

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if(widget.showTitle) Center(child: Text(sprintf(StatitikLocale.of(context).read('CA_B6'), [widget.stats.stats!.nbCards()]), style: Theme.of(context).textTheme.headline5)),
          if(widget.showBySubEx && subEx.isNotEmpty) Text(StatitikLocale.of(context).read('CA_B11'), style: Theme.of(context).textTheme.headline5),
          if(widget.showBySubEx && subEx.isNotEmpty) ListView(
            primary: false,
            shrinkWrap: true,
            children: subEx,
          ),
          if(widget.showByRarity) Text(StatitikLocale.of(context).read('CA_B10'), style: Theme.of(context).textTheme.headline5),
          if(widget.showByRarity) ListView(
            primary: false,
            shrinkWrap: true,
            children: rarity,
          ),
          if(widget.showByType) SizedBox(height: 10.0),
          if(widget.showByType) Text(StatitikLocale.of(context).read('CA_B9'), style: Theme.of(context).textTheme.headline5),
          if(widget.showByType) ListView(
            primary: false,
            shrinkWrap: true,
            children: type,
          ),
          if(widget.showByMarker && markers.isNotEmpty) SizedBox(height: 10.0),
          if(widget.showByMarker && markers.isNotEmpty) Text(StatitikLocale.of(context).read('CA_B7'), style: Theme.of(context).textTheme.headline5),
          if(widget.showByMarker && markers.isNotEmpty) ListView(
            primary: false,
            shrinkWrap: true,
            children: markers,
          ),
          if(widget.showByRegion && regions.isNotEmpty) SizedBox(height: 10.0),
          if(widget.showByRegion && regions.isNotEmpty) Text(StatitikLocale.of(context).read('CA_B8'), style: Theme.of(context).textTheme.headline5),
          if(widget.showByRegion && regions.isNotEmpty) ListView(
            primary: false,
            shrinkWrap: true,
            children: regions,
          ),
        ]
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