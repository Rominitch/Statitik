import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';

class WizardSelectSimilarCard extends StatelessWidget {
  final PokeNavAdmin        _nav;
  final PokeCardInExpansion _card;

  const WizardSelectSimilarCard(this._nav, this._card, {super.key});

  bool isInsideList(List<PokeCardViewerIdentifier> cards, PokeCard cardData) {
    for(final cvid in cards) {
      if( cvid.cardInExp().card == cardData) {
        return true;
      }
    }
    return false;
  }

  void createWidgetCard(BuildContext context, PokeCardViewerIdentifier cvid,
    List<PokeCardViewerIdentifier> cards, List<Widget> cardsWidgets) {
    final refCard  = _card.card;
    final cardData = cvid.cardInExp().card;
    if(refCard.type == cardData.type // Keep only same type
        && cardData.title.title.isNotEmpty
        && (refCard.title.title.first.name == cardData.title.title.first.name) // If same card subject, search similar
    ) {
      if( cardData.pid().id() != 0 ) {
        // Show card when name filter is enabled (otherwise too many card to show)
        if(!isInsideList(cards, cardData)) {
          cards.add(cvid);
        }
        cardsWidgets.add(
            Card(
              color: (cardData == _card.card) ? Colors.red[500] : Colors.grey[500],
              child: TextButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cvid.expansion.cards.numberOfCard(cvid.idCard.numberId)),
                    Text(cardData.pid().id().toString(), style: const TextStyle(fontSize: 8)),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context, cardData);
                },
              ),
            )
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    List<PokeCardViewerIdentifier> cards = [];

    List<Widget> expansionWidget = [];
    for (final expansion in _nav.collection.expansions()) {
      // Keep Japanese only
      if( expansion.location() == CardLocation.Asie ) {
        List<Widget> cardsWidgets = [];
        // Search all basic cards ...
        int id=0;
        for (final _ in expansion.cards.cards) {
          createWidgetCard(context, PokeCardViewerIdentifier(expansion, PokeCardIdentifier.from([0, id, 0]), specificLanguage: _nav.showLanguage), cards, cardsWidgets);
          id += 1;
        }
        // ... and energy
        id=0;
        for (final _ in expansion.cards.energyCard) {
          createWidgetCard(context, PokeCardViewerIdentifier(expansion, PokeCardIdentifier.from([1, id, 0]), specificLanguage: _nav.showLanguage), cards, cardsWidgets);
          id += 1;
        }
        // ... and no number
        id=0;
        for (final _ in expansion.cards.noNumberedCard) {
          createWidgetCard(context, PokeCardViewerIdentifier(expansion, PokeCardIdentifier.from([2, id, 0]), specificLanguage: _nav.showLanguage), cards, cardsWidgets);
          id += 1;
        }

        // Add card about expansion
        if(cardsWidgets.isNotEmpty) {
          expansionWidget.add(Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Row(
                children: [
                  expansion.image(_nav.showLanguage, wSize: 50.0),
                  Expanded(
                    child: GridView.count(crossAxisCount: 15,
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
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.ca_b31} ${_card.card.titleOfCard(_nav.showLanguage)} - ${_card.card.pid().id()}"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints box) {
              final count = (box.maxWidth / 200).ceil();
              final delegate = SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count, crossAxisSpacing: 0, mainAxisSpacing: 0,
                  childAspectRatio: 0.7);

              return Column(
                children:
                <Widget>[
                  GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    gridDelegate: delegate,
                    itemCount: cards.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cvid = cards.elementAt(index);
                      final cardData = cards.elementAt(index).cardInExp().card;

                      return Card(
                        color: (cardData == _card.card) ? Colors.red[500] : Colors.grey[500],
                        child: TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.all(2), alignment: Alignment.center),
                          child: Row(
                            children: [
                              RotatedBox(quarterTurns:3, child: Text(cardData.pid().id().toString(), style: const TextStyle(fontSize: 10))),
                              Expanded(child: _nav.rendering.genericCardWidget(cvid, language: _nav.showLanguage)),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pop(context, cardData);
                          },
                        ),
                      );
                    }
                  )
                ] + expansionWidget,
              );
            }
          )
        )
      )
    );
  }
}