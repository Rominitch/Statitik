import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardSelectionData {
  SubExtension subExtension;
  PokemonCardExtension card;

  CardSelectionData(this.subExtension, this.card);
}

class CardsSelection extends StatefulWidget {
  final Language     language;
  final SubExtension subExtension;

  const CardsSelection(this.language, this.subExtension, {Key? key}) : super(key: key);

  @override
  State<CardsSelection> createState() => _CardsSelectionState();
}

class _CardsSelectionState extends State<CardsSelection> {
  late List<Widget> widgets;
  late List<Widget> widgetEnergies;

  @override
  void initState() {
    super.initState();

    createCards();
  }
  
  Widget createCardButton(PokemonCardExtension card, List<int> cardId) {
    return Card(
      margin: EdgeInsets.all(3.0),
      child: TextButton(
        child: Column(
          children: [
            card.imageType(),
            SizedBox(height: 5),
            widget.subExtension.cardInfo(cardId),
          ],
        ),
        onPressed: (){
          Navigator.of(context).pop();
          Navigator.of(context).pop(CardSelectionData(widget.subExtension, card));
        },
      )
    );
  }

  void createCards() {
    // Build one time all widgets
    widgets = [];
    int idInBooster=0;
    for(var cards in widget.subExtension.seCards.cards) {
      widgets.add( createCardButton(cards[0], [0, idInBooster, 0]) );
      idInBooster += 1;
    }

    widgetEnergies = [];
    idInBooster=0;
    widget.subExtension.seCards.energyCard.forEach((card) {
      widgetEnergies.add( createCardButton(card, [1, idInBooster]) );
      idInBooster += 1;
    });
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
            Text(widget.subExtension.name, softWrap: true),
          ]
        )
      ),
      body:
      ListView(
        children: [
          if(widgetEnergies.isNotEmpty)
            GridView.count(
              crossAxisCount: 5,
              children: widgetEnergies,
              primary: false,
              shrinkWrap: true,
            ),
          if(widgets.isNotEmpty)
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              primary: false,
              childAspectRatio: 1.15,
              children: widgets,
            ),
        ],
      ),
    );
  }
}

