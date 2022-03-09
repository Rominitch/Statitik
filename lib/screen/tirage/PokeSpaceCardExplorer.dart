import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Cartes/CardViewer.dart';

import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/screen/widgets/CardSelector/CardSelectorPokeSpace.dart';
import 'package:statitikcard/screen/widgets/PokemonCard.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/Rarity.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class PokeSpaceCardExplorer extends StatefulWidget {
  final SubExtension subExtensions;
  final PokeSpace    pokeSpace;

  const PokeSpaceCardExplorer(this.subExtensions, this.pokeSpace);

  @override
  _PokeSpaceCardExplorerState createState() => _PokeSpaceCardExplorerState();
}

class StatsPerCard {
  final double percent;
  final int    count;
  StatsPerCard(this.count, this.percent);
}

class _PokeSpaceCardExplorerState extends State<PokeSpaceCardExplorer> {
  List showState = [true, true, true];

  @override
  void initState() {
    showState[1] = widget.subExtensions.seCards.energyCard.isNotEmpty;
    showState[2] = widget.subExtensions.seCards.noNumberedCard.isNotEmpty;

    super.initState();
  }

  Widget createCardWidget(int id, PokemonCardExtension cardData, String cardName, StatsPerCard? statsOfCard, int listId) {
    Widget? extendedType = cardData.imageTypeExtended(generate: true, sizeIcon: 14.0);
    return Card(
      margin: EdgeInsets.all(2.0),
      child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15,
                  child: Row( children: [
                    cardData.imageType(generate: true, sizeIcon: 14.0),
                    if(extendedType != null) extendedType,
                  ] + getImageRarity(cardData.rarity, widget.subExtensions.extension.language, iconSize: 14.0, fontSize: 12.0, generate: true) + [
                    Expanded(child: Text( cardName, textAlign: TextAlign.right, style: TextStyle(fontSize: cardName.length > 3 ? 9.0: 12.0))),
                  ]
                  )
              ),
              SizedBox(height:5),
              Expanded(child: CardImage(widget.subExtensions, cardData, id, height: 150, language: widget.subExtensions.extension.language)),
            ],
          ),
          onPressed: (){
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CardSEViewer(widget.subExtensions, id, listId)),
            );
          }
      ),
    );
  }

  void refresh() {
    setState(() {

    });
  }

  Widget createCardSerieButton(BuildContext context, List showState, int id) {
    return Expanded( child: Card(
        margin: EdgeInsets.all(2.0),
        child: TextButton(child:
        Text(StatitikLocale.of(context).read('S_SERIE_$id'),
            style: TextStyle(fontSize: 12)
        ),
            onPressed: () { setState(() { showState[id] = !showState[id];});}
        ),
        color: showState[id] ? Colors.green : Colors.grey
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              widget.subExtensions.extension.language.barIcon(),
              SizedBox(width: 5),
              widget.subExtensions.image(wSize: 40, hSize: 40),
              SizedBox(width: 5),
              Text(widget.subExtensions.name, style: Theme.of(context).textTheme.headline5),
            ]
          )
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(widget.subExtensions.seCards.energyCard.isNotEmpty ||
                    widget.subExtensions.seCards.noNumberedCard.isNotEmpty)
                Row(
                  children: [
                    createCardSerieButton(context, showState, 0),
                    if(widget.subExtensions.seCards.energyCard.isNotEmpty)
                      createCardSerieButton(context, showState, 1),
                    if(widget.subExtensions.seCards.noNumberedCard.isNotEmpty)
                      createCardSerieButton(context, showState, 2),
                  ],
                ),
              if(showState[0])
                GridView.builder(
                  padding: EdgeInsets.all(1.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                      childAspectRatio: 0.7),
                  itemCount: widget.subExtensions.seCards.cards.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, id) {
                    var cardData = widget.subExtensions.seCards.cards[id][0];
                    var cardSelector = CardSelectorPokeSpace( widget.subExtensions, widget.pokeSpace, cardData);
                    return PokemonCard(cardSelector, refresh: refresh, readOnly: false, singlePress: true);
                  },
                ),
              if(showState[1])
                GridView.builder(
                  padding: EdgeInsets.all(1.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                      childAspectRatio: 0.7),
                  itemCount: widget.subExtensions.seCards.energyCard.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, id) {
                    var cardData = widget.subExtensions.seCards.energyCard[id];

                    var cardSelector = CardSelectorPokeSpace( widget.subExtensions, widget.pokeSpace, cardData);
                    return PokemonCard(cardSelector, refresh: refresh, readOnly: false, singlePress: true);
                  },
                ),
              if(showState[2])
                GridView.builder(
                  padding: EdgeInsets.all(1.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                      childAspectRatio: 0.7),
                  itemCount: widget.subExtensions.seCards.noNumberedCard.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, id) {
                    var cardData = widget.subExtensions.seCards.noNumberedCard[id];

                    var cardSelector = CardSelectorPokeSpace( widget.subExtensions, widget.pokeSpace, cardData);
                    return PokemonCard(cardSelector, refresh: refresh, readOnly: false, singlePress: true);
                  },
                ),
            ],
        ),
          ),
      )
    );
  }
}