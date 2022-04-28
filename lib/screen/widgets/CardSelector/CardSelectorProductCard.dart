import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';

import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/product.dart';

class CardSelectorProductCard extends GenericCardSelector {
  final ProductCard card;
  late CardIdentifier idCard;

  static const int _limitSet = 255;

  CardSelectorProductCard(this.card): super() {
    idCard = subExtension().seCards.computeIdCard(card.card)!;
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
  void increase(int idSet) {
    card.counter.increase(idSet, _limitSet);
  }

  @override
  void decrease(int idSet) {
    card.counter.decrease(idSet);
  }

  @override
  void setOnly(int idSet)
  {
    card.counter.reset();
    card.counter.increase(idSet, _limitSet);
  }

  @override
  void toggle() {
    if(card.counter.count() == 0)
      card.counter.increase(0, _limitSet);
    else
      card.counter.reset();
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
              Text(subExtension().seCards.numberOfCard(idCard.numberId)),
              card.isRandom ? Text("R") : Text(card.counter.allCounts().join(" | "))
            ]
        ),
      ],
    );
  }
}