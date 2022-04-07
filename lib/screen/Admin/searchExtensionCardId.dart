import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/CardTitleData.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class SearchExtensionsCardId extends StatelessWidget {
  final TypeCard type;
  final CardTitleData? name;
  final String title;
  final int currentId;

  const SearchExtensionsCardId(this.type, this.name, this.title, this.currentId, {Key? key}) : super(key: key);

  void createWidgetCard(BuildContext context, PokemonCardExtension cardEx, SubExtension subExtension, CardIdentifier id,
                        Set<PokemonCardData> cards, List<Widget> cardImageWidget, List<Widget> cardsWidgets) {
    var cardData = cardEx.data;
    if(type == cardData.type // Keep only same type
        && (this.name == null || cardData.title.isEmpty || this.name == cardData.title[0].name) // If name, search similar
    ) {
      int? localId = Environment.instance.collection.rPokemonCards[cardData];
      if(localId == null) {
        printOutput("SearchExtensionsCardId: Impossible to find card: $id into ${subExtension.name}");
      } else {
        // Show card when name filter is enabled (otherwise too many card to show)
        if(!cards.contains(cardData) && cardData.title.isNotEmpty && this.name == cardData.title[0].name) {
          cards.add(cardData);
          cardImageWidget.add(
              Card(
                color: (localId == currentId) ? Colors.red[500] : Colors.grey[500],
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.all(2), alignment: Alignment.center),
                  child: Row(
                    children: [
                      RotatedBox(quarterTurns:3, child: Text(localId.toString(), style: TextStyle(fontSize: 10))),
                      Expanded(child: genericCardWidget(subExtension, id, CardImageIdentifier())),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context, localId);
                  },
                ),
              )
          );
        }
        cardsWidgets.add(
            Card(
              color: (localId == currentId) ? Colors.red[500] : Colors.grey[500],
              child: TextButton(
                child: Column(
                  children: [
                    Expanded(child: Text(subExtension.seCards.numberOfCard(id.numberId))),
                    Text(localId.toString(), style: TextStyle(fontSize: 8)),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, localId);
                },
              ),
            )
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    // Refresh admin info
    Environment.instance.collection.adminReverse();

    Set<PokemonCardData> cards = {};
    List<Widget> cardImageWidget = [];

    List<Widget> expansionWidget = [];
    Environment.instance.collection.subExtensions.values.forEach((subExtension) {
      // Keep Japanese only
      if(subExtension.extension.language.id == 3 ) {
        List<Widget> cardsWidgets = [];
        // Search all basic cards ...
        int id=0;
        subExtension.seCards.cards.forEach((List<PokemonCardExtension> allCards) {
          createWidgetCard(context, allCards[0], subExtension, CardIdentifier.from([0, id, 0]), cards, cardImageWidget, cardsWidgets);
          id += 1;
        });
        // ... and energy
        id=0;
        subExtension.seCards.energyCard.forEach((PokemonCardExtension allCards) {
          createWidgetCard(context, allCards, subExtension, CardIdentifier.from([1, id]), cards, cardImageWidget, cardsWidgets);
          id += 1;
        });
        // ... and no number
        id=0;
        subExtension.seCards.noNumberedCard.forEach((PokemonCardExtension allCards) {
          createWidgetCard(context, allCards, subExtension, CardIdentifier.from([2, id]), cards, cardImageWidget, cardsWidgets);
          id += 1;
        });

        // Add card about expansion
        if(cardsWidgets.isNotEmpty) {
          expansionWidget.add(Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Row(
                children: [
                  subExtension.image(wSize: 50.0),
                  Expanded(
                    child: GridView.count(crossAxisCount: 6,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      primary: false,
                      children: cardsWidgets
                    ),
                  )
                ]
              ),
            ),
          ));
        }
      }
    });

    List<Widget> cardImages = cardImageWidget.isNotEmpty ?
    [
      GridView.count(
        crossAxisCount: 3,
        children: cardImageWidget,
        shrinkWrap: true,
        primary: false,
      ),
    ] : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(sprintf("%s %s - %d", [StatitikLocale.of(context).read('CA_B31'), this.title, currentId])),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: cardImages+expansionWidget,
          )
        )
      )
    );
  }
}
