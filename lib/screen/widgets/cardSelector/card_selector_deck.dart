import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/card_identifier.dart';

import 'package:statitikcard/screen/widgets/card_image.dart';
import 'package:statitikcard/screen/widgets/card_selector.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/models/deck.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class CardSelectorDeck extends GenericCardSelector {
  final DeckCardInfo cardInfo;

  static const int limitSet = 255;

  CardSelectorDeck(this.cardInfo):
    super()
  {
    fullSetsImages = true;
  }

  @override
  CodeDraw codeDraw(){
    return cardInfo.count;
  }

  @override
  SubExtension subExtension() {
    return cardInfo.se;
  }

  @override
  PokemonCardExtension cardExtension() {
    return cardInfo.se.cardFromId(cardInfo.idCard);
  }

  @override
  void increase(int idSet, [int idImage=0]) {
    cardInfo.count.increase(idSet, limitSet, idImage);
  }

  @override
  void decrease(int idSet, [int idImage=0]) {
    cardInfo.count.decrease(idSet, idImage);
  }

  @override
  void setOnly(int idSet, [int idImage=0]) {
    //code.reset();
    cardInfo.count.increase(idSet, limitSet, idImage);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    // Noop
  }

  @override
  Color backgroundColor() {
    return cardInfo.count.count() > 0 ? Colors.grey : Colors.grey.shade800;
  }

  @override
  Widget cardWidget() {
    var cardName = cardInfo.se.seCards.numberOfCard(cardInfo.idCard.numberId);
    var cardExt = cardExtension();
    int count = cardInfo.count.count();

    Widget? extendedType = cardExt.imageTypeExtended(generate: true, sizeIcon: 14.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 15,
          child: Row( children: [
              cardExt.imageType(generate: true, sizeIcon: 14.0),
              if(extendedType != null) extendedType,
            ] + getImageRarity(cardExt.rarity, cardInfo.se.extension.language, iconSize: 14.0, fontSize: 12.0, generate: true) + [
              Expanded(child: Text( cardName, textAlign: TextAlign.right, style: TextStyle(fontSize: cardName.length > 3 ? 9.0: 12.0))),
            ]
          )
        ),
        const SizedBox(height:3),
        Expanded(child: genericCardWidget(cardInfo.se, cardInfo.idCard, CardImageIdentifier(), height: 150, language: cardInfo.se.extension.language)),
        const SizedBox(height:3),
        Center(child: Text("$count")),
      ],
    );
  }

  @override
  CardIdentifier cardIdentifier() {
    return cardInfo.idCard;
  }
}