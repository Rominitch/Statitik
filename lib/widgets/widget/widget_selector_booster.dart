import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/products/poke_product_booster.dart';

class WidgetSelectorBooster extends StatelessWidget {
  final PokeNavLanguage  _nav;
  final Function(PokeProductBooster) onBoosterSelected;
  const WidgetSelectorBooster(this._nav, this.onBoosterSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    final boosters = _nav.collection.boosters();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1),
      itemCount: boosters.length,
      itemBuilder: (context, index) {
        final booster = boosters[index];
        return Card(
          child: TextButton(onPressed: () {
              onBoosterSelected(booster);
            },
            child: booster.widget(context, 0, _nav.language)
          )
        );
      },
    );
  }
}
