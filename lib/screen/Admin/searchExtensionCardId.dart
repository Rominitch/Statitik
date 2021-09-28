import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class SearchExtensionsCardId extends StatelessWidget {
  const SearchExtensionsCardId(Type type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    Environment.instance.collection.subExtensions.values.forEach((subExtension) {
      // Keep Japanese only
      if(subExtension.extension.language.id == 2 ) {
        List<Widget> cards = [];
        int id=0;
        subExtension.seCards.cards.forEach((List<PokemonCardExtension> card) {
          int localId = Environment.instance.collection.rPokemonCards[card[0].data];
          cards.add(
           Card(
             child: TextButton(
               child: Text(subExtension.seCards.numberOfCard(id)),
               onPressed: () {
                 Navigator.pop(context, localId);
               },
             ),
           )
          );
          id += 1;
        });
        cards.add(Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                subExtension.image(wSize: 50.0),
                GridView.count(crossAxisCount: 6,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  primary: false,
                  children: cards
                )
              ]
            ),
          ),
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('CA_B31')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: cards,
          )
        )
      )
    );
  }
}
