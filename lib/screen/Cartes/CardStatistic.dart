import 'dart:async';

import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Cartes/CardFilterSelector.dart';
import 'package:statitikcard/screen/Cartes/CardNameSelector.dart';
import 'package:statitikcard/screen/Cartes/statsCard.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class CardStatisticPage extends StatefulWidget {
  const CardStatisticPage({Key? key}) : super(key: key);

  @override
  _CardStatisticPageState createState() => _CardStatisticPageState();
}

class _CardStatisticPageState extends State<CardStatisticPage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      length: Environment.instance.collection.languages.length,
      vsync: this
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabHeaders = [];
    List<Widget> tabPages   = [];
    Environment.instance.collection.languages.forEach((key, language) {
      tabHeaders.add(Padding(
        padding: EdgeInsets.all(8.0),
        child: language.barIcon(),
      ));

      tabPages.add(CardFilteredReport(language));
    });

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text( StatitikLocale.of(context).read('CA_T0'), style: Theme.of(context).textTheme.headline3),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: tabPages
              )
            )
          ],
        )
      )
    );
  }
}

class CardFilteredReport extends StatefulWidget {
  final Language    language;

  const CardFilteredReport(this.language, {Key? key}) : super(key: key);

  @override
  State<CardFilteredReport> createState() => _CardFilteredReportState();
}

class _CardFilteredReportState extends State<CardFilteredReport> {
  CardResults  _filterData = CardResults();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CardStats>(
      future: computeStats(),
      builder: (BuildContext context, AsyncSnapshot<CardStats> snapshot){
        if(snapshot.hasData) {
          _filterData.stats = snapshot.data;
          if( _filterData.hasStats() ) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: TextButton(
                            onPressed: () {
                              _filterData.specificCard = null;
                              _filterData.stats        = null;
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CardNameSelector(widget.language)),
                                ).then((value) {
                                  setState(() {
                                    _filterData.specificCard = value;
                                  });
                                });
                              });
                            },
                            child: Text( _filterData.specificCard != null ? _filterData.specificCard!.name(widget.language) : StatitikLocale.of(context).read('CA_B3')),
                          ),
                        ),
                      ),
                      Card(
                        color: _filterData.isFiltered() ? Colors.green : Colors.grey[700],
                        child: TextButton(
                          onPressed: () {
                            _filterData.stats = null;
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CardFilterSelector(widget.language, _filterData)),
                              ).then((value) {
                                setState(() {});
                              });
                            });
                          },
                          child: Text(StatitikLocale.of(context).read('CA_B4')),
                        ),
                      ),
                    ],
                  ),
                  (_filterData.stats!.hasData()) ?
                    Card(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StatsCard(widget.language, _filterData))
                    )
                  : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: drawNothing(context, 'S_B1'),
                  )
                ]
              ),
            );
          }
          else
            return drawLoading(context);
        }
        else 
          return drawLoading(context);
      }
    );
  }

  Future<CardStats> computeStats() async {
    return Future(() {
      var stats = CardStats();
      Environment.instance.collection.subExtensions.values.forEach((subExt) {
        if( subExt.extension.language == widget.language && subExt.seCards.isValid ) {
          int id=0;
          subExt.seCards.cards.forEach((List<PokemonCardExtension> cards) {
            cards.forEach((singleCard) {
              if( _filterData.isSelected(singleCard) ) {
                stats.add(subExt, singleCard, id);
              }
            });
            id += 1;
          });
        }
      });
      return stats;
    });
  }
}
