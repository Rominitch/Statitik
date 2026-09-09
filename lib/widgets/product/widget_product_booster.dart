import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product_booster.dart';
import 'package:statitikcard/widgets/image/image_with_cache.dart';

class WidgetProductBoosterBooster extends StatelessWidget {
  final PokeNavLanguage    _nav;
  final PokeProductBooster? _booster;
  final int                 _count;

  const WidgetProductBoosterBooster(this._nav, this._booster, this._count, {super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final nbBoosters = _booster != null ? _booster.nbDesigns() : 0;
    final info = _booster != null ? _booster.expansion().image(_nav.language):Text(loc.produit_boosters_random);

    return Card(
      color: PokeRendering.colorLightCard,
      child: SizedBox(
        height: PokeRendering.bestBoosterHeight,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child:Column(
                  spacing: 4.0,
                  children: [
                    Text(loc.produit_nb_boosters, style: Theme.of(context).textTheme.headlineSmall),
                    Text(_count.toString()),
                    Expanded(child: Center(child:info))
                  ],
                )
              ),
              Expanded(
                flex: 2,
                child: ListView.separated(
                  itemCount: nbBoosters,
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => const SizedBox(width: PokeRendering.spacing),
                  itemBuilder: (context, id) {
                    return _booster!.widget(context, id, _nav.language);
                    //final image = _booster!.boosterDesignImage(id);
                    //return ImageWithCache.generator('PKBoosters/${_nav.language.code()}', [image],
                    //    alternativeRendering: Placeholder());
                    //return drawCachedImage('PKBoosters/${_nav.language.code()}', image, alternativeRendering: Placeholder(), photoView: false);
                  }
                )
              )
            ],
          )
        ),
      )
    );
  }
}
