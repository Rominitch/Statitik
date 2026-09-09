import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product_side.dart';

class WidgetSideProduct extends StatelessWidget {
  final PokeNavLanguage _nav;
  final PokeProductSide _side;
  final int             _count;
  const WidgetSideProduct(this._nav, this._side, this._count, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: PokeRendering.spacing,
      children: [
        Expanded(child: _side.image(alternativeRendering: Column(
          spacing: PokeRendering.spacing,
          children: [
            Text(_side.category.name(_nav.language)),
            Text(_side.name(_nav.language), style: Theme.of(context).textTheme.headlineSmall),
          ],
        )),
        ),
        Text(_count.toString()),
      ]
    );
  }
}
