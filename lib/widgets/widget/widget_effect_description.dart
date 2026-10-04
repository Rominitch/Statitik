import 'package:flutter/material.dart';
import 'package:statitikcard/models/card/poke_card_effect.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_region.dart';

class WidgetEffectDescription extends StatelessWidget {
  final PokeNavAdmin nav;
  final PokeEffectDescription description;
  const WidgetEffectDescription(this.nav, this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    final current = nav.collection.decrypted(description, nav.showLanguage);

    List<InlineSpan> children = [];
    var itString = current.iterator;

    while(itString.moveNext()) {
      var finalText = description.fillWithParameters(itString.current);
      if(finalText.isNotEmpty) {
        if(itString.current.startsWith("E:")) {
          String energyCode = finalText.substring(2);
          children.add(WidgetSpan(child: getImageType(PokeCardType.values[int.parse(energyCode)])));
        } else if(itString.current.startsWith("P:")) {
          String pokeCode = finalText.substring(2);
          final PokemonName poke = nav.collection.pokemon(PokeIdentifier(int.parse(pokeCode)));
          children.add(TextSpan(text: poke.name(nav.showLanguage)));
        } else if(itString.current.startsWith("A:")) {
          String effectCode = finalText.substring(2);
          final PokeEffectName effect = nav.collection.effectName(PokeIdentifier(int.parse(effectCode)))!;
          children.add(TextSpan(text: nav.showLanguage.label(effect)));
        } else if(itString.current.startsWith("R:")) {
          final info = finalText.substring(2).split("|");
          assert(info.length == 2);
          final PokemonName pokemonId = nav.collection.pokemon(PokeIdentifier(int.parse(info[0])));
          final PokeRegion  region    = nav.collection.region(PokeIdentifier(int.parse(info[1])))!;
          final pokemonName = PokeFullCardPokemon(pokemonId, region: region);
          children.add(TextSpan(text: pokemonName.titleOfCard(nav.showLanguage)));
        } else {
          children.add(TextSpan(text: finalText));
        }
      }
    }
    // Create final text
    return RichText(text: TextSpan(children: children) );

  }
}
