import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/screen/widgets/card_image.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';

enum CardVisualization {
  name,
  image,
}

class CardSelectionData {
  SubExtension subExtension;
  List<CardIdentifier> cards = [];

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
  CardVisualization      modeVisu = CardVisualization.name;

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
  
  Widget createCardButton(PokemonCardExtension card, CardIdentifier cardId, CardImageIdentifier imageId) {
    return Card(
      color: selection.cards.contains(cardId) ? Colors.green : Colors.grey.shade700,
      margin: const EdgeInsets.all(1.5),
      child: TextButton(
        child: modeVisu == CardVisualization.name ?
          cardId.listId == 1 ?
          Row(
            children: [
              card.imageType(),
              const SizedBox(width: 4.0),
              widget.subExtension.cardInfo(cardId),
          ])
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              card.imageType(),
              widget.subExtension.cardInfo(cardId),
            ]
          )
        : CardImage(widget.subExtension, card, cardId, imageId),
        onPressed: (){
          setState(() {
            if(selection.cards.contains(cardId)) {
              selection.cards.remove(cardId);
            } else {
              selection.cards.add(cardId);
            }
          });
        },
      )
    );
  }

  Widget createGridCard(listCard, int idList) {
    return GridView.builder(
      padding: const EdgeInsets.all(1.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: modeVisu == CardVisualization.name ? 5 : 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
          childAspectRatio: modeVisu == CardVisualization.name ? 1.25 : 0.7),
      itemCount: listCard.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, id) {
        var cardListId = [idList, id];
        if(idList == 0) {
          cardListId.add(0);
        }
        var cardId = CardIdentifier.from(cardListId);
        return createCardButton(widget.subExtension.cardFromId(cardId), cardId, CardImageIdentifier());
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
            const SizedBox(width: 5),
            widget.subExtension.image(hSize: iconSize),
            const SizedBox(width: 5),
            Text(widget.subExtension.name, softWrap: true, style: TextStyle(fontSize: widget.subExtension.name.length > 8 ? 10 : 12)),
          ]
        ),
        actions: [
          IconButton(onPressed: (){
              setState(() {
                if(modeVisu == CardVisualization.name) {
                  modeVisu = CardVisualization.image;
                } else {
                  modeVisu = CardVisualization.name;
                }
              });
            },
            icon: Icon((modeVisu == CardVisualization.name)
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
                        physics: const NeverScrollableScrollPhysics(),
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

