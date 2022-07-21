import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/card_identifier.dart';

import 'package:statitikcard/screen/widgets/card_selector.dart';
import 'package:statitikcard/services/draw/booster_draw.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';

class CardSelectorBoosterDraw extends GenericCardSelector {
  final BoosterDraw          boosterDraw;
  final PokemonCardExtension card;
  final CodeDraw             counter;
  late CardIdentifier        idCard;

  CardSelectorBoosterDraw(this.boosterDraw, this.card, this.counter): super()
  {
    idCard = boosterDraw.subExtension!.seCards.computeIdCard(card)!;
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
  CardIdentifier cardIdentifier() {
    return idCard;
  }

  @override
  void increase(int idSet, [int idImage=0])
  {
    boosterDraw.increase(counter, idSet);
  }

  @override
  void decrease(int idSet, [int idImage=0])
  {
    boosterDraw.decrease(counter, idSet);
  }

  @override
  void setOnly(int idSet, [int idImage=0])
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
    switch(idCard.listId) {
      case 0: return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            if(card.isValid())
              Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [card.imageType()] + card.imageRarity(subExtension().extension.language)),
            if(card.isValid()) const SizedBox(height: 6.0),
            if( nbCard > 1)
              Text('${boosterDraw.nameCard(idCard.numberId)} ($nbCard)')
            else
              Text(boosterDraw.nameCard(idCard.numberId))
          ]
      );
      case 1 : return getImageType(card.data.typeExtended ?? TypeCard.unknown);
      case 2 :
        var name = card.numberOfCard(idCard.numberId);
        if( nbCard > 1) {
          name += '($nbCard)';
        }

        return Text(name, style: TextStyle(fontSize: name.length > 8 ? 10 : 12));
      default:
        throw StatitikException("No visual for this card");
    }
  }
}