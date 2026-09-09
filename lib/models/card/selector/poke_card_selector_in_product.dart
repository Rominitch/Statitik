import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector.dart';
import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';

import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/models/products/poke_product_card.dart';

class PokeCardSelectorInProduct extends PokeCardSelector {
  static const int  _limitSet = 255;

  final PokeLanguage    _language;
  PokeProductCard _card;

  PokeCardSelectorInProduct(this._language, this._card): super() {
    fullSetsImages = true;
  }

  @override
  PokeLanguage language() {
    return _language;
  }

  @override
  PokeCardDraw codeDraw(){
    return _card.counter;
  }

  @override
  PokeExpansion expansion() {
    return _card.expansion;
  }

  @override
  PokeCardIdentifier cardIdentifier() {
    return _card.idCard;
  }

  @override
  void increase(PokeSet set, [int idImage=0]) {
    _card.counter.increase(set, _limitSet, idImage);
  }

  @override
  void decrease(PokeSet set, [int idImage=0]) {
    _card.counter.decrease(set, idImage);
  }

  @override
  void setOnly(PokeSet set, [int idImage=0])
  {
    _card.counter.reset();
    _card.counter.increase(set, _limitSet, idImage);
  }

  @override
  void toggle() {
    if(_card.counter.count() == 0) {
      _card.counter.increase(_card.card().orderedSets().first, _limitSet);
    } else {
      _card.counter.reset();
    }
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children:[
            Expanded(
              child: Card(
                color: _card.jumbo ? Colors.green : Colors.grey,
                child: TextButton(
                  child: Text(AppLocalizations.of(context)!.cs_b0, style: Theme.of(context).textTheme.headlineSmall),
                  onPressed: () {
                    _card.jumbo = !_card.jumbo;
                    refresh();
                  },
                )
              ),
            ),
            Expanded(
              child: Card(
                color: _card.isRandom ? Colors.green : Colors.grey,
                child: TextButton(
                  child: Text(AppLocalizations.of(context)!.cs_b1, style: Theme.of(context).textTheme.headlineSmall),
                  onPressed: () {
                    _card.isRandom = !_card.isRandom;
                    refresh();
                  },
                )
              ),
            )
          ]
        )
      ]
    );
  }

  @override
  Color backgroundColor() {
    return Colors.deepOrange.shade300;
  }

  @override
  Widget cardWidget(PokeNavLanguage nav) {
    final cardViewId = PokeCardViewerIdentifier(_card.expansion, _card.idCard, specificLanguage: nav.language );
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Expanded(child: nav.rendering.genericCardWidget(cardViewId, language: nav.language)),
          const SizedBox(height: 5.0),
          if(_card.counter.count() != 1)
            _card.jumbo ? Text("Jumbo - ${_card.counter.count()}", style: const TextStyle(fontSize: 16.0))
                : Text(_card.counter.count().toString(), style: const TextStyle(fontSize: 18.0))
          else
            if(_card.jumbo) const Text("Jumbo", style: TextStyle(fontSize: 16.0))
        ],
      ),
    );
  }
}