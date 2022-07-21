import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/card_image.dart';
import 'package:statitikcard/screen/widgets/card_selector.dart';

import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/pokespace.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class CardSelectorPokeSpace extends GenericCardSelector {
  final SubExtension         subExt;
  final PokeSpace            pokeSpace;
  final PokemonCardExtension card;
  final CardIdentifier       idCard;
  final CodeDraw             code;

  static const int limitSet = 255;

  CardSelectorPokeSpace(SubExtension currentSubExt, PokeSpace currentPokeSpace, CardIdentifier currentIdCard):
    subExt = currentSubExt, pokeSpace = currentPokeSpace,
    card   = currentSubExt.cardFromId(currentIdCard),
    idCard = currentIdCard,
    code   = currentPokeSpace.cardCounter(currentSubExt, currentIdCard),
    super()
  {
    fullSetsImages = true;
  }

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
  void increase(int idSet, [int idImage=0]) {
    code.increase(idSet, limitSet, idImage);
  }

  @override
  void decrease(int idSet, [int idImage=0]) {
    code.decrease(idSet, idImage);
  }

  @override
  void setOnly(int idSet, [int idImage=0]) {
    //code.reset();
    code.increase(idSet, limitSet, idImage);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    if(code.count() == 0) {
      code.increase(0, limitSet);
    } else {
      code.reset();
    }
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
      var idSet=0;
      for (var set in card.sets) {
        var countValue = code.countBySet(idSet);
        if(countValue > 0) {
          countBySet.add(
            Expanded(
              child: Card(
                color: set.color,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      set.imageWidget(height: 20.0),
                      const SizedBox(width: 5),
                      Text("$countValue")
                    ]
                  ),
                )
              ),
            )
          );
        }
        idSet +=1;
      }
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
        const SizedBox(height:3),
        Expanded(child: genericCardWidget(subExt, idCard, CardImageIdentifier(), height: 150, language: subExt.extension.language)),
        if(count > 0)
          const SizedBox(height:3),
        if(count > 0)
          Row(children: countBySet),
      ],
    );
  }

  @override
  CardIdentifier cardIdentifier() {
    return idCard;
  }
}