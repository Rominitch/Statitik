import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/CardSelector/CardSelectorProductCard.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/ProductDraw.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class CardSelectorProductDraw extends CardSelectorProductCard {
  final ProductDraw draw;

  CardSelectorProductDraw(this.draw, card, {showAdvanced=false}): super(card);

  @override
  CodeDraw codeDraw(){
    return draw.randomProductCard[card]!;
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
  void increase(int idSet)
  {
    draw.increase(card, idSet);
  }

  @override
  void decrease(int idSet)
  {
    draw.decrease(card, idSet);
  }

  @override
  void setOnly(int idSet)
  {
    draw.setOnly(card, idSet);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    draw.toggle(card, 0);
  }

  @override
  Color backgroundColor() {
    return codeDraw().count() > 0 ? card.counter.color(card.card) : Colors.grey;
  }

  @override
  Widget cardWidget() {
    var cardEx = cardExtension();
    List<int> idCard = subExtension().seCards.computeIdCard(cardEx);
    int nbCard = codeDraw().count();
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        [
          if(cardEx.isValid())
            Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [subExtension().image(wSize: 30, hSize: 30), cardEx.imageType()] + cardEx.imageRarity(subExtension().extension.language)),
          if(cardEx.isValid()) SizedBox(height: 6.0),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                subExtension().cardInfo(idCard),
                if( nbCard > 1)
                  Text(' ($nbCard)')
              ])
        ]
    );
  }
}