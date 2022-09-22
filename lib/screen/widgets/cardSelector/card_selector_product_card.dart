import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/card_selector.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/product.dart';

class CardSelectorProductCard extends GenericCardSelector {
  static const int  _limitSet = 255;
  final ProductCard card;

  CardSelectorProductCard(this.card): super() {
    fullSetsImages = true;
  }

  @override
  CodeDraw codeDraw(){
    return card.counter;
  }

  @override
  SubExtension subExtension() {
    return card.subExtension;
  }

  @override
  PokemonCardExtension cardExtension() {
    return card.card;
  }

  @override
  CardIdentifier cardIdentifier() {
    return card.idCard;
  }

  @override
  void increase(int idSet, [int idImage=0]) {
    card.counter.increase(idSet, _limitSet, idImage);
  }

  @override
  void decrease(int idSet, [int idImage=0]) {
    card.counter.decrease(idSet, idImage);
  }

  @override
  void setOnly(int idSet, [int idImage=0])
  {
    card.counter.reset();
    card.counter.increase(idSet, _limitSet, idImage);
  }

  @override
  void toggle() {
    if(card.counter.count() == 0) {
      card.counter.increase(0, _limitSet);
    } else {
      card.counter.reset();
    }
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            children:[
              Expanded(
                child: Card(
                    color: card.jumbo ? Colors.green : Colors.grey,
                    child: TextButton(
                      child: Text(StatitikLocale.of(context).read('CS_B0'), style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        card.jumbo = !card.jumbo;
                        refresh();
                      },
                    )
                ),
              ),
              Expanded(
                child: Card(
                    color: card.isRandom ? Colors.green : Colors.grey,
                    child: TextButton(
                      child: Text(StatitikLocale.of(context).read('CS_B1'), style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        card.isRandom = !card.isRandom;
                        refresh();
                      },
                    )
                ),
              )
            ]
        )
      ]
    );
  }

  @override
  Color backgroundColor() {
    return Colors.deepOrange.shade300;
  }

  @override
  Widget cardWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              subExtension().image(hSize: 30),
              card.card.imageType(),
            ]
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(subExtension().seCards.numberOfCard(card.idCard.numberId)),
              card.isRandom ? const Text("R") : Text(card.counter.allCounts().join(" | "))
            ]
        ),
      ],
    );
  }
}