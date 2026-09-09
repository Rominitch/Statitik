import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product.dart';

import 'package:statitikcard/services/environment.dart';

class PageProductsListExplorer extends StatefulWidget {
  final PokeNavLanguage _nav;
  final PokeNavProductSelection _selection;

  const PageProductsListExplorer(this._nav, this._selection, {super.key});

  @override
  State<PageProductsListExplorer> createState() => _PageProductsListExplorerState();
}

class _PageProductsListExplorerState extends State<PageProductsListExplorer> with SingleTickerProviderStateMixin {
  late TabController yearController;
  List products = [];
  List years    = []; // Ordered List anti-Chrono

  @override
  void initState() {
    years.clear();

    // Get all product with language
    products = widget._nav.collection.products().where( (product) => !product.isFiltered(widget._nav.language)).toList(growable: false);
    products.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

    // Extract year
    for(final product in products) {
      DateTime date = product.releaseDate;
      if(!years.contains(date.year)) {
        years.add(date.year);
      }
    }
    years.sort((a,b) => b.compareTo(a));

    final firstIndex = max(0, years.indexOf(widget._selection.selectedYear ?? 0));
    assert( firstIndex < years.length);
    // Build controller
    yearController = TabController(length: products.isEmpty ? 1 : years.length,
        initialIndex: firstIndex,
        vsync: this);

    super.initState();
  }

  Widget buildProduct(PokeProduct product) {
    final name = product.name(widget._nav.language);
    return Card(
      child: TextButton(
        child: Column(
          children: [
            Expanded(child: product.image(height: null,
              alternativeRendering: Center(
                child: Text(name, style: name.length < 25.0 ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.titleLarge),
              )
            )),
          ]
        ),
        onPressed: (){
          widget._selection.onSelection(widget._nav.language, product);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if( years.isEmpty ) {
      return Center(child:Text(AppLocalizations.of(context)!.produit_nothing, style: Theme.of(context).textTheme.titleLarge));
    }
    List<Widget> yearsTab = [];
    List<Widget> productsTab = [];
    for(var year in years){
      yearsTab.add(ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Environment.heightTabHeader),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(year.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )));

      var filteredProduct = List.from(products)..removeWhere((product) => product.releaseDate.year != year);
      products.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

      Widget page = LayoutBuilder(builder: (context, BoxConstraints box) {
        final nbItem = (box.maxWidth / PokeRendering.bestProductWidth).ceil();
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: nbItem, crossAxisSpacing: 2, mainAxisSpacing: 2,
            childAspectRatio: PokeRendering.bestProductRatio,
          ),
          itemCount: filteredProduct.length,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (context, id) {
            return buildProduct(filteredProduct.elementAt(id));
          },
        );
      });
      productsTab.add(page);
    }

    return Column(
        children: [
          TabBar(
              controller: yearController,
              indicatorPadding: const EdgeInsets.all(1),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
              ),
              isScrollable: true,
              onTap: (int index){
                // Save year
                widget._selection.selectedYear = years[index];
              },
              tabs: yearsTab
          ),
          Expanded(
              child: TabBarView(
                controller: yearController,
                physics: const NeverScrollableScrollPhysics(),
                children: productsTab,
              )
          )
        ]
    );
  }
}
