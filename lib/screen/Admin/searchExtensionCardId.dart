import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class SearchExtensionsCardId extends StatelessWidget {
  final Type type;
  final CardTitleData? name;
  final String title;
  final int currentId;

  const SearchExtensionsCardId(this.type, this.name, this.title, this.currentId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Refresh admin info
    Environment.instance.collection.adminReverse();

    Set<PokemonCardExtension> cards = {};
    List<Widget> cardImageWidget = [];

    List<Widget> expansionWidget = [];
    Environment.instance.collection.subExtensions.values.forEach((subExtension) {
      // Keep Japanese only
      if(subExtension.extension.language.id == 3 ) {
        List<Widget> cardsWidgets = [];
        int id=0;
        subExtension.seCards.cards.forEach((List<PokemonCardExtension> allCards) {
          var cardData = allCards[0].data;

          if(type == cardData.type // Keep only same type
            && (this.name == null || cardData.title.isEmpty || this.name == cardData.title[0].name) // If name, search similar
            ) {
            int? localId = Environment.instance.collection.rPokemonCards[cardData];
            if(localId == null) {
              printOutput("SearchExtensionsCardId: Impossible to find card: $id into ${subExtension.name}");
            } else {
              // Show card when name filter is enabled (otherwise too many card to show)
              if(!cards.contains(allCards[0]) && cardData.title.isNotEmpty && this.name == cardData.title[0].name) {
                cards.add(allCards[0]);
                cardImageWidget.add(
                    Card(
                      color: Colors.grey[500],
                      child: TextButton(
                        child: Column(
                          children: [
                            CardImage(subExtension, allCards[0], id, height: 40),
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
              cardsWidgets.add(
               Card(
                 color: (localId == currentId) ? Colors.red[500] : Colors.grey[500],
                 child: TextButton(
                   child: Column(
                     children: [
                       Text(subExtension.seCards.numberOfCard(id)),
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
          id += 1;
        });
        // Add card about expansion
        if(cardsWidgets.isNotEmpty) {
          expansionWidget.add(Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
        crossAxisCount: 5,
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
