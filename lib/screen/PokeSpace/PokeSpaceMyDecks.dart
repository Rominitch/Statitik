import 'package:flutter/material.dart';
import 'package:statitikcard/screen/PokeSpace/PokeSpaceMyDecksCreator.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Deck.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

class PokeSpaceMyDeck extends StatefulWidget {
  const PokeSpaceMyDeck() : super();

  @override
  State<PokeSpaceMyDeck> createState() => _PokeSpaceMyCardsState();
}

class _PokeSpaceMyCardsState extends State<PokeSpaceMyDeck> {
  void goToDeckSelector(Deck deck) {

    if(deck.cards.isEmpty) {
      var afterSelectLanguage = (BuildContext context, Language language) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceMyDecksCreator(language, deck))).then(
          (value) {
            setState(() {
              if(value!) {
                var mySpace = Environment.instance.user!.pokeSpace;
                Environment.instance.savePokeSpace(context, mySpace);
              }
            });
          }
        );
      };
      Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSelector(afterSelectLanguage)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceMyDecksCreator(deck.cards.first.se.extension.language, deck))).then(
        (value) {
          setState(() {
            if(value!) {
              var mySpace = Environment.instance.user!.pokeSpace;
              Environment.instance.savePokeSpace(context, mySpace);
            }
          });
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var mySpace = Environment.instance.user!.pokeSpace;
    var myDecks = mySpace.myDecks;

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('DC_B18'), style: Theme.of(context).textTheme.headline3),
        actions: [
          FloatingActionButton.small(
            child: Icon(Icons.add_circle_outline, color: Colors.white),
            backgroundColor: deckMenuColor,
            onPressed: (){
              var deck = Deck(StatitikLocale.of(context).read('PSMD_B2'));
              mySpace.myDecks.add(deck);
              goToDeckSelector(deck);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: myDecks.isEmpty ?
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Spacer(),
                      Text(StatitikLocale.of(context).read('PSMD_B1'), style: Theme.of(context).textTheme.headline6),
                      SizedBox(width: 5.0),
                      Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                      SizedBox(width: 15.0),
                    ]
                  ),
                  SizedBox(height: 40),
                  drawNothing(context, 'PSMD_B0')
                ]
              ),
            ) : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.8),
              itemCount: myDecks.length,
              itemBuilder: (BuildContext context, int id) {
                var deck = myDecks[id];
                List<Widget> energies = [];
                deck.stats.energyTypes.forEach((type) {
                  energies.add(getImageType(type));
                });

                return Card(
                  margin: EdgeInsets.all(2.0),
                  child: TextButton(
                      child: Column(
                        children: [
                          Text(deck.name, style: Theme.of(context).textTheme.headline6),
                          Row(children: [
                            Text("Card: ${deck.cards.length}"),
                            Text("Poke: ${deck.stats.countPokemon.length}"),
                          ]),
                          Row(children: energies),
                        ],
                      ),
                      onPressed: () { goToDeckSelector(deck); }
                  )
                );
              }
            )
        ),
      ),
    );
  }
}
