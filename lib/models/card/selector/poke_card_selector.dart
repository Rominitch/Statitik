
import 'package:flutter/material.dart';
import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_set.dart';

/// Allow to map any data to show a card into Card viewer
abstract class PokeCardSelector {
  bool fullSetsImages=false;

  PokeCardSelector();

  PokeLanguage         language();
  PokeExpansion        expansion();
  PokeCardIdentifier   cardIdentifier();
  PokeCardDraw         codeDraw();

  PokeCardInExpansion  card() { return expansion().cards.cardFromId(cardIdentifier()); }

  void increase(PokeSet set, [int idImage=0]);
  void decrease(PokeSet set, [int idImage=0]);
  void setOnly(PokeSet set, [int idImage=0]);

  Widget? advancedWidget(BuildContext context, Function refresh);

  Function(BuildContext)? specialButtonAction() {
    return null;
  }

  Color backgroundColor();
  Widget cardWidget(PokeNavLanguage nav);

  void toggle();
}