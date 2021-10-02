import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/Cartes/CardViewer.dart';

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
  final Language    l;
  final CardResults stats;
  final bool showTitle;
  final bool showByRarity;
  final bool showByType;
  final bool showByMarker;
  final bool showByRegion;
  final bool showBySubEx;

  StatsCard(this.l, this.stats, { this.showTitle=true,
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

  void updateContent(subEx, rarityWidget, typeWidget, markers, regions) {
    var s = widget.stats.stats!;

    if(widget.stats.isSpecific() || widget.stats.isFiltered()) {
      s.countSubExtension.entries.forEach( (item)
      {
        List<Widget> cardWidgets = [];
        item.value.forEach((idCard) {
          var name = item.key.seCards.numberOfCard(idCard);
          cardWidgets.add(
            Card(color: Colors.grey[800],
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextButton(child: Text(name, style: TextStyle(fontSize: name.length > 2 ? (name.length > 3 ? 9 : 12) : 14)),
                  onPressed: (){
                    var card = item.key.seCards.cards[idCard][0];
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CardViewer(item.key, idCard, card)),
                    );
                  },
                )
            )
          );
        });

        subEx.add( Row(
            children: [Container(child: item.key.image(hSize: 30.0), alignment: Alignment.centerLeft, width: _spaceBefore),
              Expanded( child:
                  Card(
                    color: Colors.grey,
                    child: GridView.builder(
                      padding: EdgeInsets.all(2),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7, crossAxisSpacing: 2, mainAxisSpacing: 2),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: cardWidgets.length,
                      itemBuilder: (context, index){
                        return cardWidgets[index];
                      }
                      ),
                  )
              )
            ]
          )
        );
      });
    }

    double count = s.nbCards().toDouble();
    orderedRarity.forEach((rarity) {
      var value = s.countRarity[rarity];
      if(value != null) {
        var r = value.toDouble();
        rarityWidget.add( Row(
          children: [ Container(
            child: Row( children: getImageRarity(rarity)), alignment: Alignment.centerLeft, width: _spaceBefore,),
            Expanded(child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: ( r / count).clamp(0.0, 1.0),
              progressColor: rarityColors[rarity.index],
            )),
            createCountWidget(value)
          ]));
      }
    });

    orderedType.forEach((type) {
      var value = s.countType[type];
      if(value != null) {
        var r = value.toDouble();
        typeWidget.add( Row(
          children: [ Container(child: getImageType(type), alignment: Alignment.centerLeft, width: _spaceBefore, height: 25.0,),
            Expanded(child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: ( r / count).clamp(0.0, 1.0),
              progressColor: typeColors[type.index],
            )),
            createCountWidget(value)
          ]));
      }
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

    const List<Color> regionColors = [
      Colors.blue, Colors.red, Colors.green, Colors.brown,
      Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
    ];

    int idColor = 0;
    s.countRegion.forEach((region, stat) {
        regions.add(Row(
            children: [ Container(child: Text(region.name(widget.l), style: TextStyle(fontSize: 10.0)), width: _spaceBefore),
              Expanded(child: LinearPercentIndicator(
                lineHeight: 8.0,
                percent: (stat / count).clamp(0.0, 1.0),
                progressColor: regionColors[idColor],
              )),
              createCountWidget(stat),
            ])
        );
        // Next color
        idColor = (idColor+1 < regionColors.length) ? idColor + 1 : 0;
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