import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/cardSelector/card_selector_product_card_viewer.dart';

import 'package:statitikcard/screen/widgets/pokemon_card.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product.dart';

class ProductViewer extends StatefulWidget {
  final Language language;
  final Product  product;
  const ProductViewer(this.language, this.product, {Key? key}) : super(key: key);

  @override
  State<ProductViewer> createState() => _ProductViewerState();
}

class _ProductViewerState extends State<ProductViewer> with TickerProviderStateMixin {
  List<ProductCard> randomCards = [];
  List<ProductCard> cards       = [];
  late TabController panelController;

  @override
  void initState() {
    for(var card in widget.product.otherCards) {
      if( card.isRandom ) {
        randomCards.add(card);
      } else {
        cards.add(card);
      }
    }

    panelController = TabController(length: widget.product.hasImages() ? 2 : 1,
        animationDuration: Duration.zero,
        initialIndex: 0,
        vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> boosterInfo = [];
    for(var booster in widget.product.boosters) {
      boosterInfo.add(Card(
        color: Colors.grey.shade800,
        child: SizedBox(
          width: 85.0,
          height: 75.0,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                booster.subExtension != null
                    ? booster.subExtension!.image(hSize: 35)
                    : SizedBox(height: 35, child: Text(StatitikLocale.of(context).read('PV_B1'))),
                const SizedBox(height: 5.0),
                Text(booster.nbBoosters.toString()),
              ],
            ),
          ),
        )
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, style: Theme.of(context).textTheme.headline5),
      ),
      body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TabBar(
                controller: panelController,
                indicatorPadding: const EdgeInsets.all(1),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                tabs: [
                  if(widget.product.hasImages()) Text(StatitikLocale.of(context).read('PV_B4'), style: Theme.of(context).textTheme.headline5),
                  Text(StatitikLocale.of(context).read('PV_B5'), style: Theme.of(context).textTheme.headline5),
                ]
            ),
            Expanded(
                child: TabBarView(
                  controller: panelController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Tab 1
                    if(widget.product.hasImages())
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                        child: widget.product.image(height: null, alternativeRendering: const SizedBox(), photoView: true),
                      ),
                    //Tab 2
                    SingleChildScrollView(
                        child: Column(
                            children: [
                              if(boosterInfo.isNotEmpty) Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                        children: [
                                          Expanded(child: Text(StatitikLocale.of(context).read('PV_B0'), style: Theme.of(context).textTheme.headline5)),
                                          Wrap(children: boosterInfo)
                                        ]
                                    ),
                                  )
                              ),
                              if(randomCards.isNotEmpty) Card(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row( children: [
                                        Expanded(child: Text(StatitikLocale.of(context).read('PV_B2'), style: Theme.of(context).textTheme.headline5)),
                                        Text(widget.product.nbRandomPerProduct.toString(), style: const TextStyle(fontSize: 20.0)),
                                      ]),
                                    ),
                                    GridView.builder(
                                      padding: const EdgeInsets.all(1.0),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                                          childAspectRatio: 0.7),
                                      itemCount: randomCards.length,
                                      shrinkWrap: true,
                                      primary: false,
                                      itemBuilder: (context, id) {
                                        var cardSelector = CardSelectorProductCardViewer(randomCards[id]);
                                        return PokemonCard(cardSelector, readOnly: false, singlePress: true, refresh: (){});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if(cards.isNotEmpty) Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(StatitikLocale.of(context).read('PV_B3'), style: Theme.of(context).textTheme.headline5),
                                      const SizedBox(height: 5.0),
                                      GridView.builder(
                                        padding: const EdgeInsets.all(1.0),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                                            childAspectRatio: 0.7),
                                        itemCount: cards.length,
                                        shrinkWrap: true,
                                        primary: false,
                                        itemBuilder: (context, id) {
                                          var cardSelector = CardSelectorProductCardViewer(cards[id]);
                                          return PokemonCard(cardSelector, readOnly: false, singlePress: true, refresh: (){});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if(cards.isNotEmpty) Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(StatitikLocale.of(context).read('PV_B6'), style: Theme.of(context).textTheme.headline5),
                                      const SizedBox(height: 5.0),
                                      GridView.builder(
                                        padding: const EdgeInsets.all(1.0),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                                            childAspectRatio: 0.7),
                                        itemCount: widget.product.sideProducts.length,
                                        shrinkWrap: true,
                                        primary: false,
                                        itemBuilder: (context, id) {
                                          var sideProduct = widget.product.sideProducts.keys.elementAt(id);
                                          var info = widget.product.sideProducts[sideProduct];
                                          if( sideProduct.imageURL.isEmpty ) {
                                            return Card(child: Column(
                                                children: [
                                                  if(sideProduct.category != null) Text(sideProduct.category!.name.name(widget.language)),
                                                  Text(sideProduct.name, style: Theme.of(context).textTheme.headline5),
                                                  Text(info.toString()),
                                                ]
                                              )
                                            );
                                          } else {
                                            return Card(child: Column(
                                                children: [
                                                  sideProduct.image(),
                                                  Text(info.toString()),
                                                ]
                                              )
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                        )
                    )
                  ],
                )
            )


          ]
        ),
      )
      )
    );
  }
}
