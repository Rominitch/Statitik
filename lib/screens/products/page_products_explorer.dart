import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';

import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product.dart';
import 'package:statitikcard/screens/products/page_products_list_explorer.dart';
import 'package:statitikcard/screens/products/page_products_viewer.dart';
import 'package:statitikcard/services/environment.dart';

class PageProductsExplorer extends StatefulWidget {
  final PokeCollection _collection;
  final PokeRendering  _rendering;
  final Function(PokeNavLanguage nav, PokeProduct product, Function() onReturn) _afterSelectedProduct;

  const PageProductsExplorer(this._collection, this._rendering, this._afterSelectedProduct, {super.key});

  static Widget view(PokeCollection collection, PokeRendering rendering) {
    return PageProductsExplorer(collection, rendering,
      (PokeNavLanguage nav, PokeProduct product, Function() onReturn) {
        return PageProductsViewer(nav, product, onReturn);
    });
  }

  @override
  State<PageProductsExplorer> createState() => _PageProductsExplorerState();
}

class _PageProductsExplorerState extends State<PageProductsExplorer> with TickerProviderStateMixin, WidgetsBindingObserver{
  late TabController langueController;
  List<Widget> productTab      = [];
  List<Widget> languageWidgets = [];
  late PokeNavProductSelection selection;

  @override
  void initState() {
    selection = PokeNavProductSelection(onSelect);

    for (PokeLanguage language in widget._collection.languages()) {
      languageWidgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: language.barIcon(Environment.heightTabHeader - 16.0),
      ));
      productTab.add(PageProductsListExplorer(PokeNavLanguage(widget._collection, widget._rendering, language),
          selection));
    }

    langueController = TabController(length: widget._collection.languages().length,
        animationDuration: Duration.zero,
        initialIndex: 0,
        vsync: this);

    super.initState();
  }

  void onSelect(PokeLanguage language, PokeProduct product) {
    setState(() {
      selection.selectedLanguage = language;
      selection.selectedProduct  = product;
    });
  }

  void onReturn() {
    setState(() {
      selection.selectedProduct  = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show product view
    if(selection.selectedProduct != null) {
      assert(selection.selectedLanguage != null);
      //return PageProductsViewer(, selection.selectedProduct!, onReturn);
      final nav = PokeNavLanguage(widget._collection, widget._rendering, selection.selectedLanguage!);
      return widget._afterSelectedProduct(nav, selection.selectedProduct!, onReturn);
    }
    // Show products selection
    return Column(
      children: [
        AppBar(
          title: Center(child: Text(AppLocalizations.of(context)!.pe_t0, style: Theme.of(context).textTheme.displaySmall)),
        ),
        TabBar(
          controller: langueController,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          tabs: languageWidgets
        ),
        Expanded(
          child: TabBarView(
            controller: langueController,
            physics: const NeverScrollableScrollPhysics(),
            children: productTab,
          )
        )
      ]
    );
  }
}
