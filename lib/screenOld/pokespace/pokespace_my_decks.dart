import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_my_decks_creator.dart';
import 'package:statitikcard/screenOld/commonPages/language_page.dart';
import 'package:statitikcard/screenOld/widgets/deck_widget.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/deck.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/tools.dart';

class PokeSpaceMyDeck extends StatefulWidget {
  const PokeSpaceMyDeck({super.key});

  @override
  State<PokeSpaceMyDeck> createState() => _PokeSpaceMyCardsState();
}

class _PokeSpaceMyCardsState extends State<PokeSpaceMyDeck> {
  void goToDeckSelector(Deck deck) {

    if(deck.cards.isEmpty) {
      afterSelectLanguage(BuildContext context, Language language) {
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
      }
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
        title: Text(AppLocalizations.of(context)!.dc_b18, style: Theme.of(context).textTheme.displaySmall),
        actions: [
          FloatingActionButton.small(
            backgroundColor: deckMenuColor,
            onPressed: (){
              var deck = Deck(AppLocalizations.of(context)!.psmd_b2);
              mySpace.myDecks.add(deck);
              goToDeckSelector(deck);
            },
            child: const Icon(Icons.add_circle_outline, color: Colors.white),
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
                      const Spacer(),
                      Text(AppLocalizations.of(context)!.psmd_b1, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(width: 5.0),
                      const Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                      const SizedBox(width: 15.0),
                    ]
                  ),
                  const SizedBox(height: 40),
                  drawNothing(context, AppLocalizations.of(context)!.psmd_b0)
                ]
              ),
            ) : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.8),
              itemCount: myDecks.length,
              itemBuilder: (BuildContext context, int id) {
                var deck = myDecks[id];
                return Card(
                  margin: const EdgeInsets.all(2.0),
                  child: TextButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: computeDeckInfo(deck, context),
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
