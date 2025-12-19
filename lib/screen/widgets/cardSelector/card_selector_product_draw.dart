import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/CardSelector/card_selector_product_card.dart';

import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/product_draw.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

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
  void increase(int idSet, [int idImage=0])
  {
    draw.increase(card, idSet);
  }

  @override
  void decrease(int idSet, [int idImage=0])
  {
    draw.decrease(card, idSet);
  }

  @override
  void setOnly(int idSet, [int idImage=0])
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
    var idCard = subExtension().seCards.computeIdCard(cardEx)!;
    int nbCard = codeDraw().count();
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        [
          if(cardEx.isValid())
            Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [subExtension().image(wSize: 30, hSize: 30), cardEx.imageType()] + cardEx.imageRarity(subExtension().extension.language)),
          if(cardEx.isValid()) const SizedBox(height: 6.0),
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