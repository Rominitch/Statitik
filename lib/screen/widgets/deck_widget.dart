

import 'package:flutter/material.dart';
import 'package:statitikcard/screen/stats/pie_chart.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/deck.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

List<Widget> computeDeckInfo(Deck deck, BuildContext context) {
  List<Widget> energies = [];
  for (var type in deck.stats.energyTypes) {
    energies.add(getImageType(type));
  }

  return [
    Text(deck.name, style: Theme.of(context).textTheme.titleLarge),
    const Spacer(),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    const Icon(Icons.image_outlined),
    Text("${deck.stats.nbCards}"),
    const Spacer(),
    const Icon(StatitikFont.font01Pokecard),
    Text("${deck.stats.nbCardsPokemon}"),
    const Spacer(),
    getImageType(TypeCard.objet),
    Text("${deck.stats.countByType[TypeCard.objet] ?? 0}"),
    const Spacer(),
    getImageType(TypeCard.supporter),
    Text("${deck.stats.countByType[TypeCard.supporter] ?? 0}"),

    ]),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    getImageType(TypeCard.energy),
    Text("${deck.stats.countByType[TypeCard.energy] ?? 0}"),
    const Spacer()
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
  Widget createEnergyInfo(TypeCard type, int count) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            getImageType(type),
            const SizedBox(width: 4.0),
            Text("$count")
          ]
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(deck.cards.isEmpty) {
    return SingleChildScrollView(
        child: Text(StatitikLocale.of(context).read('PSMDC_B9'), style: Theme.of(context).textTheme.headlineMedium)
      );
    } else {
      var firstColWidth = 200.0;
      List<Widget> energies = [];
      for (var type in deck.stats.energyTypes) {
        energies.add(getImageType(type));
      }
      List<Widget> powerEnergies = [];
      for (var type in deck.stats.powerEnergies) {
        powerEnergies.add(getImageType(type));
      }
      List<Widget> weaknessType = [];
      deck.stats.countWeakness.forEach((type, count) {
        weaknessType.add(createEnergyInfo(type, count));
      });
      List<Widget> resistanceType = [];
      deck.stats.countResistance.forEach((type, count) {
        resistanceType.add(createEnergyInfo(type, count));
      });

      return SingleChildScrollView(
        child: Column(
          children:
          [
            Row(children:[
              miniBox(const Icon(Icons.image_outlined),    deck.stats.nbCards),
              const Text("="),
              miniBox(const Icon(StatitikFont.font01Pokecard), deck.stats.nbCardsPokemon, deck.stats.countPokemon.length),
              miniBox(getImageType(TypeCard.objet),        deck.stats.countByType[TypeCard.objet]),
              miniBox(getImageType(TypeCard.supporter),    deck.stats.countByType[TypeCard.supporter]),
              miniBox(getImageType(TypeCard.stade),        deck.stats.countByType[TypeCard.stade]),
              miniBox(getImageType(TypeCard.energy),       deck.stats.countByType[TypeCard.energy]),
            ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: energies ),
            ),
            PieDeckType(deck.stats),
            Card( child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(StatitikLocale.of(context).read('PSMDC_B10'), style: Theme.of(context).textTheme.titleLarge),
                  Table(
                    children: [
                      TableRow(
                        children: [
                          Container(
                            width: firstColWidth,
                          ),
                          Text(StatitikLocale.of(context).read('PSMDC_B13'), style: Theme.of(context).textTheme.titleLarge),
                          Text(StatitikLocale.of(context).read('PSMDC_B14'), style: Theme.of(context).textTheme.titleLarge),
                          Text(StatitikLocale.of(context).read('PSMDC_B15'), style: Theme.of(context).textTheme.titleLarge)
                        ]
                      ),
                      if(deck.stats.hpStats != null)
                        TableRow(
                          children: [
                            SizedBox(
                              width: firstColWidth,
                              child:Text(StatitikLocale.of(context).read('PSMDC_B11'), style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Text("${deck.stats.hpStats!.minV}"),
                            Text("${(deck.stats.hpStats!.sum/deck.stats.hpStats!.count).round()}"),
                            Text("${deck.stats.hpStats!.maxV}"),
                          ]
                        ),
                      if(deck.stats.retreatStats != null)
                        TableRow(
                          children: [
                            SizedBox(
                              width: firstColWidth,
                              child: Text(StatitikLocale.of(context).read('PSMDC_B16'), style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Text("${deck.stats.retreatStats!.minV}"),
                            Text("${(deck.stats.retreatStats!.sum/deck.stats.retreatStats!.count).round()}"),
                            Text("${deck.stats.retreatStats!.maxV}"),
                          ]
                        ),
                    ]
                  ),
                  Table(
                    children: [
                      TableRow(
                        children: [
                          SizedBox(
                            width: firstColWidth,
                              child: Text(StatitikLocale.of(context).read('PSMDC_B12'), style: Theme.of(context).textTheme.titleLarge),
                          ),
                          powerEnergies.isEmpty ? Text(StatitikLocale.of(context).read('PSMDC_B19')) : Row(children: powerEnergies)
                        ]
                      ),
                      TableRow(
                          children: [
                            SizedBox(
                              width: firstColWidth,
                              child: Text(StatitikLocale.of(context).read('PSMDC_B17'), style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Row(children: weaknessType)
                          ]
                      ),
                      TableRow(
                          children: [
                            SizedBox(
                              width: firstColWidth,
                              child: Text(StatitikLocale.of(context).read('PSMDC_B18'), style: Theme.of(context).textTheme.titleLarge),
                            ),
                            Row(children: resistanceType)
                          ]
                      ),
                    ]
                  ),
                ]
              ),
            )),
          ]
        )
      );
    }
  }
}
