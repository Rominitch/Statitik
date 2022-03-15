import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Cartes/CardViewer.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/models/Rarity.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class StatsExtensionCards extends StatefulWidget {
  final StatsConfiguration info;

  const StatsExtensionCards(this.info);

  @override
  _StatsExtensionCardsState createState() => _StatsExtensionCardsState();
}

class StatsPerCard {
  final double percent;
  final int    count;
  StatsPerCard(this.count, this.percent);
}

class _StatsExtensionCardsState extends State<StatsExtensionCards> with SingleTickerProviderStateMixin {
  List<StatsPerCard> statsPerCard = [];
  late double ratio;
  late double uniform;
  bool _isClosed = false;

  late TabController tabController;

  @override
  void initState() {
    int count = widget.info.statsData.subExt!.seCards.countNbLists();
    tabController = TabController(
      length: count,
      vsync: this,
      animationDuration: Duration.zero);

    computeStats().then((value) {
      if(!_isClosed) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _isClosed = true;
    super.dispose();
  }

  Future<void> computeStats() async {
    var stats = widget.info.statsData.stats;
    if(stats != null) {
      ratio   = 100.0 / stats.totalCards;
      uniform = 100.0 / stats.count.length;
      int id = 0;

      stats.count.forEach((countByCard) {
        int idCard=0;
        var cardByPosition = stats.subExt.seCards.cards[id];
        cardByPosition.forEach((PokemonCardExtension pc) {
          int count = countByCard[idCard];
          double percent = stats.totalCards > 0 ? count * ratio : 0;
          statsPerCard.add(StatsPerCard(count, percent));
          id += 1;
        });
      });

      assert(statsPerCard.length == stats.subExt.seCards.cards.length);
    }
  }

  Widget textStats(StatsPerCard statsOfCard) {
    Color col = statsOfCard.percent == 0.0
        ? Colors.red
        : statsOfCard.percent < uniform * 0.01
        ? Colors.yellow
        : statsOfCard.percent < uniform * 0.1
        ? Colors.purple
        : statsOfCard.percent < uniform
        ? Colors.blue
        : Colors.green;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Center(child:
        Text( (statsOfCard.percent == 0.0) ? '-' : "${statsOfCard.count} (${statsOfCard.percent.toStringAsPrecision(2)}%)",
          style: TextStyle(color: col, fontSize: 10.0, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget createCardWidget(List<int> id, PokemonCardExtension cardData, String cardName, StatsPerCard? statsOfCard, int listId) {
    Widget? extendedType = cardData.imageTypeExtended(generate: true, sizeIcon: 14.0);
    return Card(
      margin: EdgeInsets.all(2.0),
      child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15,
                  child: Row( children: [
                    cardData.imageType(generate: true, sizeIcon: 14.0),
                    if(extendedType != null) extendedType,
                  ] + getImageRarity(cardData.rarity, widget.info.statsData.subExt!.extension.language, iconSize: 14.0, fontSize: 12.0, generate: true) + [
                    Expanded(child: Text( cardName, textAlign: TextAlign.right, style: TextStyle(fontSize: cardName.length > 3 ? 9.0: 12.0))),
                  ]
                  )
              ),
              SizedBox(height:5),
              Expanded(child: genericCardWidget(widget.info.statsData.subExt!, id, height: 150, language: widget.info.statsData.language!,)),
              if(statsOfCard != null)
                textStats(statsOfCard)
            ],
          ),
          onPressed: (){
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CardSEViewer(widget.info.statsData.subExt!, id)),
            );
          }
      ),
    );
  }

  Widget menuBar(BuildContext context, String idText ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(StatitikLocale.of(context).read(idText)),
    );
  }

  @override
  Widget build(BuildContext context) {


    if(widget.info.se.isEmpty || widget.info.statsData.stats == null) {
      return drawLoading(context);
    } else {
      assert(widget.info.statsData.subExt != null);
      return Column(
        children: [
          TabBar(
            controller: tabController,
            isScrollable: false,
            indicatorPadding: const EdgeInsets.all(1),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueAccent,
            ),
            tabs: [
              if(widget.info.statsData.subExt!.seCards.cards.isNotEmpty)
                menuBar(context, 'S_SERIE_0'),
              if(widget.info.statsData.subExt!.seCards.energyCard.isNotEmpty)
                menuBar(context, 'S_SERIE_1'),
              if(widget.info.statsData.subExt!.seCards.noNumberedCard.isNotEmpty)
                menuBar(context, 'S_SERIE_2'),
            ]
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children:[
                if(widget.info.statsData.subExt!.seCards.cards.isNotEmpty)
                  GridView.builder(
                    padding: EdgeInsets.all(1.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                      childAspectRatio: 0.7),
                    itemCount: widget.info.statsData.subExt!.seCards.cards.length,
                    itemBuilder: (context, id) {
                      var cardData = widget.info.statsData.subExt!.seCards.cards[id][0];
                      var statsOfCard = id < statsPerCard.length ? statsPerCard[id] : null;
                      final cardName = widget.info.statsData.subExt!.seCards.numberOfCard(id);
                      return createCardWidget([0, id, 0], cardData, cardName, statsOfCard, 0);
                    },
                  ),
                if(widget.info.statsData.subExt!.seCards.energyCard.isNotEmpty)
                  GridView.builder(
                    padding: EdgeInsets.all(1.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                      childAspectRatio: 0.7),
                    itemCount: widget.info.statsData.subExt!.seCards.energyCard.length,
                    itemBuilder: (context, id) {
                      var cardData = widget.info.statsData.subExt!.seCards.energyCard[id];
                      final cardName = cardData.numberOfCard(id);

                      return createCardWidget([1, id], cardData, cardName, null, 1);
                    }
                  ),
                if(widget.info.statsData.subExt!.seCards.noNumberedCard.isNotEmpty)
                  GridView.builder(
                    padding: EdgeInsets.all(1.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                        childAspectRatio: 0.7),
                    itemCount: widget.info.statsData.subExt!.seCards.noNumberedCard.length,
                    itemBuilder: (context, id) {
                      var cardData = widget.info.statsData.subExt!.seCards.noNumberedCard[id];
                      final cardName = cardData.numberOfCard(id);

                      return createCardWidget([2, id], cardData, cardName, null, 2);
                    },
                  ),
              ]
            )
          ),
        ],
      );
    }
  }
}
