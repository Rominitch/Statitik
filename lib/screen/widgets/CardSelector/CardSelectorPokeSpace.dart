import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';

import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class CardSelectorPokeSpace extends GenericCardSelector {
  final SubExtension         subExt;
  final PokeSpace            pokeSpace;
  final PokemonCardExtension card;
  final CodeDraw             code;

  CardSelectorPokeSpace(subExt, pokeSpace, card):
        this.subExt = subExt, this.pokeSpace = pokeSpace, this.card = card,
        this.code = pokeSpace.cardCounter(subExt, card),
        super();

  @override
  CodeDraw codeDraw(){
    return code;
  }

  @override
  SubExtension subExtension() {
    return subExt;
  }

  @override
  PokemonCardExtension cardExtension() {
    return card;
  }

  @override
  void increase(int idSet)
  {
    code.increase(idSet);
  }

  @override
  void decrease(int idSet)
  {
    code.decrease(idSet);
  }

  @override
  void setOnly(int idSet)
  {
    code.reset();
    code.increase(idSet);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    if(code.count() == 0)
      code.increase(0);
    else
      code.reset();
  }

  @override
  Color backgroundColor() {
    return code.count() > 0 ? code.color(card) : Colors.grey;
  }

  @override
  Widget cardWidget() {
    var idCard   = subExt.seCards.computeIdCard(card);
    var cardName = subExt.seCards.numberOfCard(idCard[1]);

    Widget? extendedType = card.imageTypeExtended(generate: true, sizeIcon: 14.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 15,
            child: Row( children: [
              card.imageType(generate: true, sizeIcon: 14.0),
              if(extendedType != null) extendedType,
            ] + getImageRarity(card.rarity, subExt.extension.language, iconSize: 14.0, fontSize: 12.0, generate: true) + [
              Expanded(child: Text( cardName, textAlign: TextAlign.right, style: TextStyle(fontSize: cardName.length > 3 ? 9.0: 12.0))),
            ]
            )
        ),
        SizedBox(height:5),
        Expanded(child: CardImage(subExt, card, idCard[1], height: 150, language: subExt.extension.language)),
      ],
    );
  }
}