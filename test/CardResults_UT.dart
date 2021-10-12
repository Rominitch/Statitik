import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

void main() {
  test('CardResults', () {
    // Build card
    Pokemon title = Pokemon(CardTitleData(MultiLanguageString(["TestName", "TestName", "TestName"])));
    PokemonCardData base = PokemonCardData([title], Level.Base, Type.Combat, CardMarkers.from([CardMarker.GX]) );

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
    PokemonCardExtension card = PokemonCardExtension(base, Rarity.Commune);

    // Empty test
    CardResults result = CardResults();
    expect(true, result.isSelected(card));

    // Rarity
    result.rarities = [Rarity.Commune];
    expect(true, result.isSelected(card));
    result.rarities = [Rarity.Gold];
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