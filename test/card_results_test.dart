import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/marker.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

void main() {
  test('CardResults', () {
    Map markers = {
      0: CardMarker(MultiLanguageString(["A", "A", "A"]), Colors.black, false),
      1: CardMarker(MultiLanguageString(["B", "B", "B"]), Colors.green, false),
      2: CardMarker(MultiLanguageString(["C", "C", "C"]), Colors.green, false),
    };
    Map raritySets = {
      0: Rarity.fromText(0, MultiLanguageString(["Unknown","Unknown","Unknown"]), Colors.black),
      1: Rarity.fromText(1, MultiLanguageString(["C","C","C"]),       Colors.green),
      2: Rarity.fromText(2, MultiLanguageString(["R","R","R"]),       Colors.green),
    };
    Environment.instance.collection.unknownRarity = raritySets[0];

    // Build card
    Pokemon title = Pokemon(CardTitleData(MultiLanguageString(["TestName", "TestName", "TestName"])));
    PokemonCardData base = PokemonCardData([title], Level.base, TypeCard.combat, CardMarkers.from([markers[1]]) );

    var effect = CardEffect();
    effect.power = 100;
    effect.attack = [TypeCard.combat, TypeCard.incolore, TypeCard.incolore];
    effect.description = CardDescription(1);
    effect.description!.effects.add(DescriptionEffect.burn);
    base.cardEffects.effects.add(effect);
    var effect2 = CardEffect();
    effect2.description = CardDescription(1);
    effect2.description!.effects.add(DescriptionEffect.flipCoin);
    base.cardEffects.effects.add(effect2);
    PokemonCardExtension card = PokemonCardExtension.empty(base, raritySets[1]);

    // Empty test
    CardResults result = CardResults();
    expect(true, result.isSelected(card));

    // Rarity
    result.rarities = [raritySets[1]];
    expect(true, result.isSelected(card));
    result.rarities = [raritySets[2]];
    expect(false, result.isSelected(card));
    result.clearTypeRarityFilter();

    // Type
    result.types = [TypeCard.combat];
    expect(true, result.isSelected(card));
    result.types = [TypeCard.psy];
    expect(false, result.isSelected(card));
    result.clearTypeRarityFilter();

    // CardEffect
    result.effects = [DescriptionEffect.burn, DescriptionEffect.flipCoin];
    expect(true, result.isSelected(card));
    result.effects = [DescriptionEffect.burn, DescriptionEffect.flipCoin, DescriptionEffect.paralyzed];
    expect(false, result.isSelected(card));
  });
}