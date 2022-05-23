

import 'package:flutter/material.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Deck.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

List<Widget> computeDeckInfo(Deck deck, BuildContext context) {
  List<Widget> energies = [];
  deck.stats.energyTypes.forEach((type) {
    energies.add(getImageType(type));
  });

  return [
    Text(deck.name, style: Theme.of(context).textTheme.headline6),
    Spacer(),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Icon(Icons.image_outlined),
    Text("${deck.stats.nbCards}"),
    Spacer(),
    Icon(StatitikFont.font_01_pokecard),
    Text("${deck.stats.nbCardsPokemon}"),
    Spacer(),
    getImageType(TypeCard.Objet),
    Text("${deck.stats.countByType[TypeCard.Objet] ?? 0}"),
    Spacer(),
    getImageType(TypeCard.Supporter),
    Text("${deck.stats.countByType[TypeCard.Supporter] ?? 0}"),

    ]),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    getImageType(TypeCard.Energy),
    Text("${deck.stats.countByType[TypeCard.Energy] ?? 0}"),
    Spacer()
    ] + energies
    )
  ];
}

class DeckStatisticWidget extends StatelessWidget {
  final Deck deck;
  const DeckStatisticWidget(this.deck, {Key? key}) : super(key: key);

  Widget miniBox(Widget top, int? count, [int? other]) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(2.0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              top,
              other != null ? Text("${count ?? 0} ($other)") : Text("${count ?? 0}"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> energies = [];
    deck.stats.energyTypes.forEach((type) {
      energies.add(getImageType(type));
    });
    List<Widget> powerEnergies = [];
    deck.stats.energyTypes.forEach((type) {
      powerEnergies.add(getImageType(type));
    });

    return SingleChildScrollView(
        child: Column(
          children:
          deck.cards.isEmpty ? [ Text(StatitikLocale.of(context).read('PSMDC_B9'), style: Theme.of(context).textTheme.headline4) ] :
          [
            Row(children:[
              miniBox(Icon(Icons.image_outlined),          deck.stats.nbCards),
              Text("="),
              miniBox(Icon(StatitikFont.font_01_pokecard), deck.stats.nbCardsPokemon, deck.stats.countPokemon.length),
              miniBox(getImageType(TypeCard.Objet),        deck.stats.countByType[TypeCard.Objet]),
              miniBox(getImageType(TypeCard.Supporter),    deck.stats.countByType[TypeCard.Supporter]),
              miniBox(getImageType(TypeCard.Stade),        deck.stats.countByType[TypeCard.Stade]),
              miniBox(getImageType(TypeCard.Energy),       deck.stats.countByType[TypeCard.Energy]),
            ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: energies ),
            ),
            PieDeckType(deck.stats),
            Text(StatitikLocale.of(context).read('PSMDC_B10'), style: Theme.of(context).textTheme.headline4),
            Card( child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(StatitikLocale.of(context).read('PSMDC_B11'), style: Theme.of(context).textTheme.headline4),
                      Text(StatitikLocale.of(context).read('PSMDC_B13'), style: Theme.of(context).textTheme.headline4),
                      Text(StatitikLocale.of(context).read('PSMDC_B14'), style: Theme.of(context).textTheme.headline4),
                      Text(StatitikLocale.of(context).read('PSMDC_B15'), style: Theme.of(context).textTheme.headline4)
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[ Text(StatitikLocale.of(context).read('PSMDC_B11'), style: Theme.of(context).textTheme.headline4) ] +
                      powerEnergies
                  ),
                )
              ]
            )),
          ]
        )
    );
  }
}
