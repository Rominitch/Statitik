import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';

import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class CardSelectorPokeSpace extends GenericCardSelector {
  final SubExtension         subExt;
  final PokeSpace            pokeSpace;
  final PokemonCardExtension card;
  final CardIdentifier       idCard;
  final CodeDraw             code;

  static const int limitSet = 255;

  CardSelectorPokeSpace(SubExtension subExt, PokeSpace pokeSpace, CardIdentifier idCard):
    this.subExt = subExt, this.pokeSpace = pokeSpace,
    this.card   = subExt.cardFromId(idCard),
    this.idCard = idCard,
    this.code   = pokeSpace.cardCounter(subExt, idCard),
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
  void increase(int idSet) {
    code.increase(idSet, limitSet);
  }

  @override
  void decrease(int idSet) {
    code.decrease(idSet);
  }

  @override
  void setOnly(int idSet) {
    //code.reset();
    code.increase(idSet, limitSet);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    if(code.count() == 0)
      code.increase(0, limitSet);
    else
      code.reset();
  }

  @override
  Color backgroundColor() {
    return code.count() > 0 ? Colors.grey : Colors.grey.shade800;
  }

  @override
  Widget cardWidget() {
    var cardName = subExt.seCards.numberOfCard(idCard.numberId);

    int count = code.count();
    List<Widget> countBySet = [];
    if(count > 0) {
      var itCount = code.countBySet.iterator;
      card.sets.forEach((set) {
        if(itCount.moveNext() && itCount.current > 0) {
          countBySet.add(
            Expanded(
              child: Card(
                color: set.color,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      set.imageWidget(height: 20.0),
                      SizedBox(width: 5),
                      Text("${itCount.current}")
                    ]
                  ),
                )
              ),
            )
          );
        }
      });
    }

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
        SizedBox(height:3),
        Expanded(child: genericCardWidget(subExt, idCard, CardImageIdentifier(), height: 150, language: subExt.extension.language)),
        if(count > 0)
          SizedBox(height:3),
        if(count > 0)
          Row(
            children: countBySet),
      ],
    );
  }
}