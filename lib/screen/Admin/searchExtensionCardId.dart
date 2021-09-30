import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class SearchExtensionsCardId extends StatelessWidget {
  final Type type;
  final CardTitleData? name;

  const SearchExtensionsCardId(this.type, this.name, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Refresh admin info
    Environment.instance.collection.adminReverse();

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
              cardsWidgets.add(
               Card(
                 color: Colors.grey[500],
                 child: TextButton(
                   child: Text(subExtension.seCards.numberOfCard(id)),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('CA_B31')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: expansionWidget,
          )
        )
      )
    );
  }
}
