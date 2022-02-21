import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Cartes/CardViewer.dart';

import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/models/Rarity.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/pokemonCard.dart';

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

class _StatsExtensionCardsState extends State<StatsExtensionCards> {
  List<StatsPerCard> statsPerCard = [];
  late double ratio;
  late double uniform;
  List showState = [true, true, true];

  @override
  void initState() {
    showState[1] = widget.info.statsData.subExt!.seCards.energyCard.isNotEmpty;
    showState[2] = widget.info.statsData.subExt!.seCards.noNumberedCard.isNotEmpty;
    computeStats().then((value) {
      setState(() {

      });
    });
    super.initState();
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

  Widget createCardWidget(int id, PokemonCardExtension cardData, String cardName, StatsPerCard? statsOfCard, int listId) {
    Widget? extendedType = cardData.imageTypeExtended(generate: false, sizeIcon: 14.0);
    return Card(
      margin: EdgeInsets.all(2.0),
      child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15,
                  child: Row( children: [
                    cardData.imageType(generate: false, sizeIcon: 14.0),
                    if(extendedType != null) extendedType,
                  ] + getImageRarity(cardData.rarity, iconSize: 14.0, fontSize: 12.0, generate: true) + [
                    Expanded(child: Text( cardName, textAlign: TextAlign.right, style: TextStyle(fontSize: cardName.length > 3 ? 9.0: 12.0))),
                  ]
                  )
              ),
              SizedBox(height:5),
              Expanded(child: CardImage(widget.info.statsData.subExt!, cardData, id, height: 150, language: widget.info.statsData.language!,)),
              if(statsOfCard != null)
                textStats(statsOfCard)
            ],
          ),
          onPressed: (){
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CardSEViewer(widget.info.statsData.subExt!, id, listId)),
            );
          }
      ),
    );
  }

  Widget createCardSerieButton(BuildContext context, List showState, int id) {
    return Expanded( child: Card(
        margin: EdgeInsets.all(2.0),
        child: TextButton(child:
          Text(StatitikLocale.of(context).read('S_SERIE_$id'),
            style: TextStyle(fontSize: 12)
          ),
          onPressed: () { setState(() { showState[id] = !showState[id];});}
        ),
        color: showState[id] ? Colors.green : Colors.grey
    ));
  }

  @override
  Widget build(BuildContext context) {
    if(widget.info.se.isEmpty || widget.info.statsData.stats == null) {
      return drawLoading(context);
    } else {
      assert(widget.info.statsData.subExt != null);
      return Column(
        children: [
          if(widget.info.statsData.subExt!.seCards.energyCard.isNotEmpty ||
             widget.info.statsData.subExt!.seCards.noNumberedCard.isNotEmpty)
          Row(
            children: [
              createCardSerieButton(context, showState, 0),
              if(widget.info.statsData.subExt!.seCards.energyCard.isNotEmpty)
                createCardSerieButton(context, showState, 1),
              if(widget.info.statsData.subExt!.seCards.noNumberedCard.isNotEmpty)
                createCardSerieButton(context, showState, 2),
            ],
          ),
          if(showState[0])
            GridView.builder(
            padding: EdgeInsets.all(1.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
              childAspectRatio: 0.7),
            itemCount: widget.info.statsData.subExt!.seCards.cards.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, id) {
              var cardData = widget.info.statsData.subExt!.seCards.cards[id][0];
              var statsOfCard = id < statsPerCard.length ? statsPerCard[id] : null;
              final cardName = widget.info.statsData.subExt!.seCards.numberOfCard(id);

              return createCardWidget(id, cardData, cardName, statsOfCard, 0);
            },
          ),
          if(showState[1])
            GridView.builder(
              padding: EdgeInsets.all(1.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                  childAspectRatio: 0.7),
              itemCount: widget.info.statsData.subExt!.seCards.energyCard.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, id) {
                var cardData = widget.info.statsData.subExt!.seCards.energyCard[id];
                final cardName = cardData.numberOfCard(id);

                return createCardWidget(id, cardData, cardName, null, 1);
              },
            ),
          if(showState[2])
            GridView.builder(
              padding: EdgeInsets.all(1.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                  childAspectRatio: 0.7),
              itemCount: widget.info.statsData.subExt!.seCards.noNumberedCard.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, id) {
                var cardData = widget.info.statsData.subExt!.seCards.noNumberedCard[id];
                final cardName = cardData.numberOfCard(id);

                return createCardWidget(id, cardData, cardName, null, 2);
              },
            ),
        ],
      );
    }
  }
}
