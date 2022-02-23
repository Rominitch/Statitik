import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

void main() {
  test('CardResults', () {
    Map markers = {
      0: CardMarker(MultiLanguageString(["A", "A", "A"]), Colors.black, false),
      1: CardMarker(MultiLanguageString(["B", "B", "B"]), Colors.green, false),
      2: CardMarker(MultiLanguageString(["C", "C", "C"]), Colors.green, false),
    };
    Map raritySets = {
      0: Rarity.fromText(0, "Unknown", Colors.black),
      1: Rarity.fromText(1, "C",       Colors.green),
      2: Rarity.fromText(2, "R",       Colors.green),
    };
    Environment.instance.collection.unknownRarity = raritySets[0];

    // Build card
    Pokemon title = Pokemon(CardTitleData(MultiLanguageString(["TestName", "TestName", "TestName"])));
    PokemonCardData base = PokemonCardData([title], Level.Base, Type.Combat, CardMarkers.from([markers[1]]) );

    var effect = CardEffect();
    effect.power = 100;
    effect.attack = [Type.Combat, Type.Incolore, Type.Incolore];
    effect.description = CardDescription(1);
    effect.description!.effects.add(DescriptionEffect.Burn);
    base.cardEffects.effects.add(effect);
    var effect2 = CardEffect();
    effect2.description = CardDescription(1);
    effect2.description!.effects.add(DescriptionEffect.FlipCoin);
    base.cardEffects.effects.add(effect2);
    PokemonCardExtension card = PokemonCardExtension(base, raritySets[1]);

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
    result.types = [Type.Combat];
    expect(true, result.isSelected(card));
    result.types = [Type.Psy];
    expect(false, result.isSelected(card));
    result.clearTypeRarityFilter();

    // CardEffect
    result.effects = [DescriptionEffect.Burn, DescriptionEffect.FlipCoin];
    expect(true, result.isSelected(card));
    result.effects = [DescriptionEffect.Burn, DescriptionEffect.FlipCoin, DescriptionEffect.Paralyzed];
    expect(false, result.isSelected(card));
  });
}