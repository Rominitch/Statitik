import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector_in_product.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product.dart';
import 'package:statitikcard/models/products/poke_product_card.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/widgets/product/widget_product_booster.dart';
import 'package:statitikcard/widgets/product/widget_side_product.dart';
import 'package:statitikcard/widgets/widget/widget_selector_card_viewer.dart';

class PageProductsViewer extends StatefulWidget {
  final PokeNavLanguage _nav;
  final PokeProduct     _product;
  final Function()      _onReturn;
  const PageProductsViewer(this._nav, this._product, this._onReturn, {super.key});

  @override
  State<PageProductsViewer> createState() => _PageProductsViewerState();
}

class _PageProductsViewerState extends State<PageProductsViewer> with TickerProviderStateMixin {
  List<PokeProductCard> randomCards = [];
  List<PokeProductCard> cards       = [];
  late TabController panelController;

  @override
  void initState() {
    for(var card in widget._product.otherCards) {
      if( card.isRandom ) {
        randomCards.add(card);
      } else {
        cards.add(card);
      }
    }

    panelController = TabController(length: 2,
        animationDuration: Duration.zero,
        initialIndex: 0,
        vsync: this);

    super.initState();
  }

  Widget imagePanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: widget._product.image(height: null, alternativeRendering: const SizedBox(), photoView: true),
    );
  }

  Widget boostersPanel() {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, id) {
        final entry = widget._product.boosters().entries.elementAt(id);
        return WidgetProductBoosterBooster(widget._nav, entry.key, entry.value);
      },
      itemCount: widget._product.boosters().length,

    );
  }

  Widget cardLists(List<PokeProductCard> cardList) {
    return LayoutBuilder(builder: (context, BoxConstraints box) {
      final nbItem = (box.maxWidth / PokeRendering.bestCardWidth).ceil();
      return GridView.builder(
        padding: const EdgeInsets.all(1.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: nbItem, crossAxisSpacing: PokeRendering.spacing, mainAxisSpacing: PokeRendering.spacing,
          childAspectRatio: PokeRendering.bestCardRatio),
        itemCount: cardList.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, id) {
          final cardViewer = PokeCardSelectorInProduct(widget._nav.language, cardList[id]);
          return WidgetSelectorCardViewer(
              widget._nav, cardViewer, readOnly: false,
              singlePress: true,
              refresh: () {});

          //var cardSelector = CardSelectorProductCardViewer(randomCards[id]);
          //return PokemonCard(cardSelector, readOnly: false, singlePress: true, refresh: (){});
        },
      );
    });
  }

  Widget randomCardPanel() {
    return Card(
      color: PokeRendering.colorLightCard,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: PokeRendering.spacing,
          children: [
            Row( children: [
              Expanded(child: Text(AppLocalizations.of(context)!.pv_b2, style: Theme.of(context).textTheme.headlineSmall)),
              Text(widget._product.nbRandomPerProduct.toString(), style: const TextStyle(fontSize: 20.0)),
            ]),
            cardLists(randomCards)
          ],
        ),
      ),
    );
  }

  Widget cardsPanel() {
    return Card(
      color: PokeRendering.colorLightCard,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: PokeRendering.spacing,
          children: [
            Text(AppLocalizations.of(context)!.pv_b3, style: Theme.of(context).textTheme.headlineSmall),
            cardLists(cards)
          ],
        ),
      ),
    );
  }

  Widget sideProductPanel() {
   return Card(
      color: PokeRendering.colorLightCard,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: PokeRendering.spacing,
          children: [
            Text(AppLocalizations.of(context)!.pv_b6, style: Theme.of(context).textTheme.headlineSmall),
            LayoutBuilder(builder: (context, BoxConstraints box) {
              final nbItem = (box.maxWidth / PokeRendering.bestSideProductWidth).ceil();
              return GridView.builder(
                padding: const EdgeInsets.all(1.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: nbItem, crossAxisSpacing: 1, mainAxisSpacing: 1,
                    childAspectRatio: PokeRendering.bestSideProductRatio),
                itemCount: widget._product.sideProducts.length,
                shrinkWrap: true,
                primary: false,
                itemBuilder: (context, id) {
                  final info = widget._product.sideProducts.entries.elementAt(id);
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: WidgetSideProduct(widget._nav, info.key, info.value),
                  );
                },
              );
            })
          ],
        ),
      ),
    );
  }

  Widget informationPanel() {
    return SingleChildScrollView(
      child: Column(
        spacing: PokeRendering.spacing,
          children: [
            boostersPanel(),
            if(randomCards.isNotEmpty) randomCardPanel(),
            if(cards.isNotEmpty) cardsPanel(),
            if(widget._product.sideProducts.isNotEmpty) sideProductPanel()
          ]
      )
    );
  }

  Widget mobilePanel() {
    return Column(
      children: [
        TabBar(
          controller: panelController,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          tabs: [
            ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Environment.heightTabHeader),
                child: Text(AppLocalizations.of(context)!.pv_b4, style: Theme.of(context).textTheme.headlineSmall)
            ),
            ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Environment.heightTabHeader),
                child: Text(AppLocalizations.of(context)!.pv_b5, style: Theme.of(context).textTheme.headlineSmall)
            ),
          ]
        ),
        Expanded(
          child: TabBarView(
            controller: panelController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Tab 1
              imagePanel(),
              // Tab 2
              informationPanel()
            ],
          )
        )
      ]
    );
  }

  Widget desktopPanel() {
    return Row(
      children: [
        Expanded( flex: 1, child: imagePanel()),
        Expanded( flex: 2, child: informationPanel())
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    /*
    final List<Widget> boosterInfo = [];
    for(final info in widget._product.boosters().entries) {
      boosterInfo.add(Card(
          color: Colors.grey.shade800,
          child: SizedBox(
            width: 85.0,
            height: 75.0,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  info.key.subExtension != null
                      ? info.key.subExtension!.image(hSize: 35)
                      : SizedBox(height: 35, child: Text(AppLocalizations.of(context)!.pv_b1)),
                  const SizedBox(height: 5.0),
                  Text(info.key.nbBoosters.toString()),
                ],
              ),
            ),
          )
      ));
    }
    */

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._product.name(widget._nav.language), style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(onPressed: widget._onReturn,
          icon: Icon(Icons.arrow_back)
        )
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return (constraints.maxWidth < 600) ? mobilePanel() : desktopPanel();
            }
          )
        )
      )
    );
  }
}
