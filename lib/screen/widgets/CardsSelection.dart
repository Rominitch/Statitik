import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

enum CardVisualization {
  Name,
  Image,
}

class CardSelectionData {
  SubExtension subExtension;
  List<PokemonCardExtension> cards = [];

  CardSelectionData(this.subExtension);
}

class CardsSelection extends StatefulWidget {
  final Language     language;
  final SubExtension subExtension;

  const CardsSelection(this.language, this.subExtension, {Key? key}) : super(key: key);

  @override
  State<CardsSelection> createState() => _CardsSelectionState();
}

class _CardsSelectionState extends State<CardsSelection> with TickerProviderStateMixin {
  late CardSelectionData selection;
  late TabController     tabController;
  CardVisualization      modeVisu = CardVisualization.Name;

  @override
  void initState() {
    selection = CardSelectionData(widget.subExtension);
    int count = widget.subExtension.seCards.countNbLists();
    tabController = TabController(
        length: count,
        vsync: this,
        animationDuration: Duration.zero);

    super.initState();
  }
  
  Widget createCardButton(PokemonCardExtension card, CardIdentifier cardId) {
    return Card(
      color: selection.cards.contains(card) ? Colors.green : Colors.grey.shade700,
      margin: EdgeInsets.all(3.0),
      child: TextButton(
        child: modeVisu == CardVisualization.Name ? Column(
          children: [
            card.imageType(),
            SizedBox(height: 5),
            widget.subExtension.cardInfo(cardId),
          ],
        ) : CardImage(widget.subExtension, card, cardId),
        onPressed: (){
          setState(() {
            if(selection.cards.contains(card))
              selection.cards.remove(card);
            else
              selection.cards.add(card);
          });
        },
      )
    );
  }

  Widget createGridCard(listCard, int idList) {
    return GridView.builder(
      padding: EdgeInsets.all(1.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: modeVisu == CardVisualization.Name ? 5 : 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
          childAspectRatio: modeVisu == CardVisualization.Name ? 1.1 : 0.7),
      itemCount: listCard.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, id) {
        var cardListId = [idList, id];
        if(idList == 0)
          cardListId.add(0);
        var cardId = CardIdentifier.from(cardListId);
        return createCardButton(widget.subExtension.cardFromId(cardId), cardId);
      },
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.subExtension.extension.language.barIcon(),
            SizedBox(width: 5),
            widget.subExtension.image(hSize: iconSize),
            SizedBox(width: 5),
            Text(widget.subExtension.name, softWrap: true, style: TextStyle(fontSize: widget.subExtension.name.length > 8 ? 10 : 12)),
          ]
        ),
        actions: [
          IconButton(onPressed: (){
              setState(() {
                if(modeVisu == CardVisualization.Name)
                  modeVisu = CardVisualization.Image;
                else
                  modeVisu = CardVisualization.Name;
              });
            },
            icon: Icon((modeVisu == CardVisualization.Name)
              ? Icons.text_snippet_outlined : Icons.image_outlined)
          ),
          if( selection.cards.isNotEmpty )
            Card(
              color: Colors.green,
              child: TextButton(onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(selection);
                }, child: Text(StatitikLocale.of(context).read('send')))
            )
        ],
      ),
      body:SafeArea(
          child: Column(
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
                      if(widget.subExtension.seCards.cards.isNotEmpty)
                        menuBar(context, 'S_SERIE_0'),
                      if(widget.subExtension.seCards.energyCard.isNotEmpty)
                        menuBar(context, 'S_SERIE_1'),
                      if(widget.subExtension.seCards.noNumberedCard.isNotEmpty)
                        menuBar(context, 'S_SERIE_2'),
                    ]
                ),
                Expanded(
                    child: TabBarView(
                        controller: tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children:[
                          if(widget.subExtension.seCards.cards.isNotEmpty)
                            createGridCard(widget.subExtension.seCards.cards, 0),
                          if(widget.subExtension.seCards.energyCard.isNotEmpty)
                            createGridCard(widget.subExtension.seCards.energyCard, 1),
                          if(widget.subExtension.seCards.noNumberedCard.isNotEmpty)
                            createGridCard(widget.subExtension.seCards.noNumberedCard, 2),
                        ]
                    )
                )
              ]
          )
      )
    );
  }
}

