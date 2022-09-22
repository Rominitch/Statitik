import 'package:flutter/material.dart';
import 'package:statitikcard/screen/cartes/card_viewer.dart';
import 'package:statitikcard/screen/widgets/card_image.dart';

import 'package:statitikcard/screen/widgets/card_selector.dart';

import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/product.dart';

class CardSelectorProductCardViewer extends GenericCardSelector {
  final ProductCard card;

  CardSelectorProductCardViewer(this.card): super() {
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
    assert(false);
  }

  @override
  void decrease(int idSet, [int idImage=0]) {
    assert(false);
  }

  @override
  void setOnly(int idSet, [int idImage=0])
  {
    assert(false);
  }

  @override
  void toggle() {
    assert(false);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  Function(BuildContext)? specialButtonAction() {
    return (BuildContext context) {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          CardSEViewer(subExtension(), cardIdentifier())));
    };
  }

  @override
  Color backgroundColor() {
    return Colors.grey.shade800;
  }
  //

  @override
  Widget cardWidget() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Expanded(child: genericCardWidget(card.subExtension, card.idCard, CardImageIdentifier(), language: card.subExtension.extension.language)),
          const SizedBox(height: 5.0),
          if(card.counter.count() != 1)
            card.jumbo ? Text("Jumbo - ${card.counter.count()}", style: const TextStyle(fontSize: 16.0))
                       : Text(card.counter.count().toString(), style: const TextStyle(fontSize: 18.0))
          else
            if(card.jumbo) const Text("Jumbo", style: TextStyle(fontSize: 16.0))
        ],
      ),
    );
  }
}