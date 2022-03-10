import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

class CardSelectorBoosterDraw extends GenericCardSelector {
  final BoosterDraw          boosterDraw;
  final PokemonCardExtension card;
  final CodeDraw             counter;
  late List<int>             idCard;

  CardSelectorBoosterDraw(this.boosterDraw, this.card, this.counter): super()
  {
    idCard = boosterDraw.subExtension!.seCards.computeIdCard(card);
  }

  @override
  CodeDraw codeDraw(){
    return counter;
  }

  @override
  SubExtension subExtension() {
    return boosterDraw.subExtension!;
  }

  @override
  PokemonCardExtension cardExtension() {
    return card;
  }

  @override
  void increase(int idSet)
  {
    boosterDraw.increase(counter, idSet);
  }

  @override
  void decrease(int idSet)
  {
    boosterDraw.decrease(counter, idSet);
  }

  @override
  void setOnly(int idSet)
  {
    boosterDraw.setOtherRendering(counter, idSet);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    boosterDraw.toggle(counter, 0);
  }

  @override
  Color backgroundColor() {
    return counter.color(card);
  }

  @override
  Widget cardWidget() {
    int nbCard = codeDraw().count();
    switch(idCard[0]) {
      case 0: return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            if(card.isValid())
              Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [card.imageType()] + card.imageRarity(subExtension().extension.language)),
            if(card.isValid()) SizedBox(height: 6.0),
            if( nbCard > 1)
              Text('${boosterDraw.nameCard(idCard[1])} ($nbCard)')
            else
              Text('${boosterDraw.nameCard(idCard[1])}')
          ]
      );
      case 1 : return getImageType(card.data.typeExtended ?? TypeCard.Unknown);
      default:
        throw StatitikException("No visual for this card");
    }
  }
}