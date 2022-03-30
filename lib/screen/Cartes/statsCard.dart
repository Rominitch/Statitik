import 'dart:async';

import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/Cartes/CardStatistic.dart';

import 'package:statitikcard/screen/Cartes/CardViewer.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

enum StatsVisualization
{
  Title,
  ByRarity,
  ByType,
  ByMarker,
  ByRegion,
}

class StatsCard extends StatefulWidget {
  final Language             l;
  final CardResults          stats;
  final CardStatisticOptions options;

  StatsCard(this.l, this.stats, this.options);

  @override
  _StatsCardState createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    generateTabController();

    super.initState();
  }

  void generateTabController() {
    int count = widget.stats.isSpecific() || widget.stats.isFiltered() ?
                2 : 1;
    tabController = TabController(length: count,
      animationDuration: Duration.zero,
      vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    generateTabController();

    List<Widget> tabHeaders = [];
    List<Widget> tabPages   = [];

    if (widget.options.showBySubEx && (widget.stats.isSpecific() || widget.stats.isFiltered())) {
      tabHeaders.add(Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(StatitikLocale.of(context).read('CA_B11')),
      ));
      tabPages.add(CardSubExtensionReport(widget.stats, widget.options));
    }
    tabHeaders.add(Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(StatitikLocale.of(context).read('CA_B40')),
    ));
    tabPages.add( SingleChildScrollView(child: CardStatisticReport(widget.l, widget.stats, widget.options)));

    return Column(
      children: [
        if(widget.options.showTitle) Center(child: Text(sprintf(StatitikLocale.of(context).read('CA_B6'), [widget.stats.stats!.nbCards()]), style: Theme.of(context).textTheme.headline5)),
        TabBar(
          controller: tabController,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          tabs: tabHeaders
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: tabPages
          )
        )
      ]
    );
  }
}

class CardSubExtensionReport extends StatefulWidget {
  final CardResults          stats;
  final CardStatisticOptions options;
  final StreamController?    onFilterChanged;

  const CardSubExtensionReport(this.stats, this.options, {this.onFilterChanged, Key? key}) : super(key: key);

  @override
  State<CardSubExtensionReport> createState() => _CardSubExtensionReportState();
}

class _CardSubExtensionReportState extends State<CardSubExtensionReport> with TickerProviderStateMixin {
  late TabController tabController;

  void generateTabController() {
    tabController = TabController(length: widget.stats.stats!.countSubExtension.length,
      vsync: this,
      animationDuration: Duration.zero);
  }

  @override
  void initState() {
    generateTabController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    generateTabController();

    List<Widget> tabHeaders = [];
    List<Widget> tabPages   = [];

    if(widget.stats.isSpecific() || widget.stats.isFiltered()) {
      var subExtOrdered = List.from(Environment.instance.collection.subExtensions.values)
        ..sort((a, b) => b.out.compareTo(a.out) );

      var s = widget.stats.stats!;
      // parse sub extension by order
      subExtOrdered.forEach((subExtension) {
        var listCards = s.countSubExtension[subExtension];
        if(listCards != null) {
          tabHeaders.add(
              subExtension.image(hSize: 30.0)
          );
          if( widget.options.showImage ) {
            tabPages.add(
              GridView.builder(
                  padding: EdgeInsets.all(2),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 0.8),
                  itemCount: listCards.length,
                  itemBuilder: (context, index){
                    var idCard = listCards[index];
                    return Card(color: Colors.grey[800],
                        margin: EdgeInsets.zero,
                        child: TextButton(child: genericCardWidget(subExtension, idCard, CardImageIdentifier()),
                          onPressed: (){
                            var card = subExtension.seCards.cardFromId(idCard);
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => CardViewer(subExtension, idCard, card)),
                            );
                          },
                        )
                    );
                  }
              ),
          );
          } else {
            tabPages.add(
              GridView.builder(
                padding: EdgeInsets.all(2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, crossAxisSpacing: 2, mainAxisSpacing: 2),
                itemCount: listCards.length,
                itemBuilder: (context, index){
                  var idCard = listCards[index];
                  var name = subExtension.seCards.numberOfCard(idCard.numberId);
                  return Card(color: Colors.grey[800],
                      margin: EdgeInsets.zero,
                      child: TextButton(child: Text(name, style: TextStyle(fontSize: name.length > 2 ? (name.length > 3 ? 9 : 12) : 14)),
                        onPressed: (){
                          var card = subExtension.seCards.cards[idCard][0];
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CardViewer(subExtension, idCard, card)),
                          );
                        },
                      )
                  );
                }
              ),
            );
          }
        }
      });
    }

    return Column(
      children: [
        SizedBox(height: 5.0),
        TabBar(
          controller: tabController,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          isScrollable: true,
          tabs: tabHeaders
        ),
        SizedBox(height: 5.0),
        Expanded(
          child: TabBarView(
            //physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: tabPages
          )
        )
      ]
    );
  }
}

class CardStatisticReport extends StatefulWidget {
  final Language    language;
  final CardResults stats;
  final CardStatisticOptions options;

  const CardStatisticReport(this.language, this.stats, this.options);

  @override
  State<CardStatisticReport> createState() => _CardStatisticReportState();
}

class _CardStatisticReportState extends State<CardStatisticReport> {
  double _spaceBefore = 50.0;
  double _spaceAfter  = 30.0;

  Widget createCountWidget(int value) {
    return Container(child: Text(value.toString(), style: TextStyle(fontSize: ((value >= 1000) ? 10.0 : 14.0))),
      width: _spaceAfter,
    );
  }

  @override
  Widget build(BuildContext context) {
    var s = widget.stats.stats!;
    double count = s.nbCards().toDouble();

    const List<Color> regionColors = const [
      Colors.blue, Colors.red, Colors.green, Colors.brown,
      Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
    ];

    var filteredRarities = [];
    Environment.instance.collection.orderedRarity.forEach((rarity){
      if(s.countRarity[rarity] != null)
        filteredRarities.add(rarity);
    });
    var filteredType = [];
    orderedType.forEach((type) {
      if(s.countType[type] != null)
        filteredType.add(type);
    });

    return Column(
      children: [
        if(widget.options.showByRarity) Text(StatitikLocale.of(context).read('CA_B10'), style: Theme.of(context).textTheme.headline5),
        if(widget.options.showByRarity) ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: filteredRarities.length,
          itemBuilder: (BuildContext context, int index) {
            var rarity = filteredRarities[index];
            var value  = s.countRarity[rarity]!;
            var r = value.toDouble();
            return Row(
              children: [
                Container(
                  child: Row( children: getImageRarity(rarity, widget.language)),
                  alignment: Alignment.centerLeft,
                  width: _spaceBefore
                ),
                Expanded(child:
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: ( r / count).clamp(0.0, 1.0),
                    progressColor: rarity.color,
                  )
                ),
                createCountWidget(value)
              ]
            );
          }
        ),
        if(widget.options.showByType) SizedBox(height: 10.0),
        if(widget.options.showByType) Text(StatitikLocale.of(context).read('CA_B9'), style: Theme.of(context).textTheme.headline5),
        if(widget.options.showByType) ListView.builder(
          primary:    false,
          shrinkWrap: true,
          itemCount: filteredType.length,
          itemBuilder: (BuildContext context, int index) {
            var type  = filteredType[index];
            var value = s.countType[type]!;
            var r = value.toDouble();
            return Row(
              children: [
                Container(child: getImageType(type), alignment: Alignment.centerLeft, width: _spaceBefore, height: 25.0),
                Expanded(child: LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: ( r / count).clamp(0.0, 1.0),
                  progressColor: typeColors[type.index],
                )),
                createCountWidget(value)
              ]
            );
          }
        ),

        if(widget.options.showByMarker && s.countMarker.isNotEmpty) SizedBox(height: 10.0),
        if(widget.options.showByMarker && s.countMarker.isNotEmpty) Text(StatitikLocale.of(context).read('CA_B7'), style: Theme.of(context).textTheme.headline5),
        if(widget.options.showByMarker && s.countMarker.isNotEmpty) ListView.builder(
            primary:    false,
            shrinkWrap: true,
            itemCount: s.countMarker.entries.length,
            itemBuilder: (BuildContext context, int index) {
              var item = s.countMarker.entries.elementAt(index);
              var r = item.value.toDouble();
              return Row(
                children: [ Container(child: pokeMarker(widget.language, item.key, height: 15.0), alignment: Alignment.centerLeft, width: _spaceBefore),
                  Expanded(child: LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: ( r / count).clamp(0.0, 1.0),
                    progressColor: item.key.color,
                  )),
                  createCountWidget(item.value)
                ]
              );
            }
          ),
        if(widget.options.showByRegion && s.countRegion.isNotEmpty) SizedBox(height: 10.0),
        if(widget.options.showByRegion && s.countRegion.isNotEmpty) Text(StatitikLocale.of(context).read('CA_B8'), style: Theme.of(context).textTheme.headline5),
        if(widget.options.showByRegion && s.countRegion.isNotEmpty) ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: s.countRegion.length,
          itemBuilder: (BuildContext context, int index) {
            var info = s.countRegion.entries.elementAt(index);
            var region = info.key;
            var stat   = info.value;
            return Row(
              children: [ Container(child: Text(region.name(widget.language), style: TextStyle(fontSize: 10.0)), width: _spaceBefore),
                Expanded(child: LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: (stat / count).clamp(0.0, 1.0),
                  progressColor: regionColors[index],
                )),
                createCountWidget(stat),
              ]
            );
          }
        )
      ]
    );
  }
}

