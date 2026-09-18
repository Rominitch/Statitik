import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';

import 'package:statitikcard/services/environment.dart';

import 'package:statitikcard/services/tools.dart';

class PageExtensionCards extends StatefulWidget {
  final StatisticData info;

  const PageExtensionCards(this.info, {super.key});

  @override
  State<PageExtensionCards> createState() => _PageExtensionCardsState();
}

class StatsPerCard {
  final double percent;
  final int    count;
  StatsPerCard(this.count, this.percent);
}

class _PageExtensionCardsState extends State<PageExtensionCards> with SingleTickerProviderStateMixin {
  List<StatsPerCard> statsPerCard = [];
  late double ratio;
  late double uniform;
  bool _isClosed = false;

  late TabController tabController;

  @override
  void initState() {
    int count = widget.info.selection.expansion!.cards.countNbLists();
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
    var stats = widget.info.stats;
    if(stats != null) {
      ratio   = 100.0 / stats.totalCards;
      uniform = 100.0 / stats.count.length;
      int id = 0;

      for (var countByCard in stats.count) {
        int idCard=0;
        var cardByPosition = stats.expansion.cards.cards[id];
        for (int loop=0; loop < cardByPosition.length; loop +=1) {
          int count = countByCard[idCard];
          double percent = stats.totalCards > 0 ? count * ratio : 0;
          statsPerCard.add(StatsPerCard(count, percent));
          id += 1;
        }
      }

      assert(statsPerCard.length == stats.expansion.cards.cards.length);
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

  Widget createCardWidget(PokeCardIdentifier id, PokeCardInExpansion cardData, String cardName, StatsPerCard? statsOfCard, int listId) {
    final expansion = widget.info.selection.expansion!;
    final cvId = PokeCardViewerIdentifier(
      specificLanguage: widget.info.selection.language!,
      expansion, id
    );
    Widget? extendedType = cardData.imageTypeExtended(generate: true, sizeIcon: 14.0);

    return Card(
      margin: const EdgeInsets.all(2.0),
      child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15,
                  child: Row( children: [
                    cardData.imageType(generate: true, sizeIcon: 14.0),
                    ?extendedType,
                  ] + Environment.instance.pkRendering().imageRarity(cardData.rarity, iconSize: 14.0, fontSize: 12.0, generate: true) + [
                    Expanded(child: Text( cardName, textAlign: TextAlign.right, style: TextStyle(fontSize: cardName.length > 3 ? 9.0: 12.0))),
                  ]
                  )
              ),
              const SizedBox(height:5),
              Expanded(child: Environment.instance.pkRendering().genericCardWidget(cvId, height: 150, language: widget.info.selection.language!)),
              if(statsOfCard != null)
                textStats(statsOfCard)
            ],
          ),
          onPressed: (){
            /*
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CardViewer.from(cvId)),
            );
            */
          }
      ),
    );
  }

  Widget menuBar(BuildContext context, String text ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.info.stats == null) {
      return drawLoading(context);
    } else {
      assert(widget.info.selection.expansion != null);
      final expansion = widget.info.selection.expansion!;
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
                if(expansion.cards.cards.isNotEmpty)
                  menuBar(context, AppLocalizations.of(context)!.s_serie_0),
                if(expansion.cards.energyCard.isNotEmpty)
                  menuBar(context, AppLocalizations.of(context)!.s_serie_1),
                if(expansion.cards.noNumberedCard.isNotEmpty)
                  menuBar(context, AppLocalizations.of(context)!.s_serie_2),
              ]
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final nbImages = Platform.isWindows ? max(1, (constraints.maxWidth / 160).ceil()) : 3;
                return TabBarView(
                  controller: tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children:[
                    if(expansion.cards.cards.isNotEmpty)
                      GridView.builder(
                        padding: const EdgeInsets.all(1.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: nbImages, crossAxisSpacing: 1, mainAxisSpacing: 1,
                            childAspectRatio: 0.7),
                        itemCount: expansion.cards.cards.length,
                        itemBuilder: (context, id) {
                          var cardData = expansion.cards.cards[id][0];
                          var statsOfCard = id < statsPerCard.length ? statsPerCard[id] : null;
                          final cardName = expansion.cards.numberOfCard(id);
                          return createCardWidget(PokeCardIdentifier.from([0, id, 0]), cardData, cardName, statsOfCard, 0);
                        },
                      ),
                    if(expansion.cards.energyCard.isNotEmpty)
                      GridView.builder(
                          padding: const EdgeInsets.all(1.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: nbImages, crossAxisSpacing: 1, mainAxisSpacing: 1,
                              childAspectRatio: 0.7),
                          itemCount: expansion.cards.energyCard.length,
                          itemBuilder: (context, id) {
                            final cardData = expansion.cards.energyCard[id];
                            final cardName = cardData.numberOfCard(id);

                            return createCardWidget(PokeCardIdentifier.from([1, id, 0]), cardData, cardName, null, 1);
                          }
                      ),
                    if(expansion.cards.noNumberedCard.isNotEmpty)
                      GridView.builder(
                        padding: const EdgeInsets.all(1.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: nbImages, crossAxisSpacing: 1, mainAxisSpacing: 1,
                            childAspectRatio: 0.7),
                        itemCount: expansion.cards.noNumberedCard.length,
                        itemBuilder: (context, id) {
                          final cardData = expansion.cards.noNumberedCard[id];
                          final cardName = cardData.numberOfCard(id);

                          return createCardWidget(PokeCardIdentifier.from([2, id, 0]), cardData, cardName, null, 2);
                        },
                      ),
                  ]
                );
              }
            )
          ),
        ],
      );
    }
  }
}
