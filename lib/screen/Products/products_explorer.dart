import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Products/products_list_explorer.dart';

import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';

class ProductsExplorer extends StatefulWidget {
  const ProductsExplorer({Key? key}) : super(key: key);

  @override
  State<ProductsExplorer> createState() => _ProductsExplorerState();
}

class _ProductsExplorerState extends State<ProductsExplorer> with TickerProviderStateMixin, WidgetsBindingObserver{
  late TabController langueController;
  List<Widget> productTab      = [];
  List<Widget> languageWidgets = [];

  @override
  void initState() {
    var collection = Environment.instance.collection;
    for (Language language in collection.languages.values) {
      languageWidgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: language.barIcon(),
      ));
      productTab.add(ProductsListExplorer(language));
    }

    langueController = TabController(length: collection.languages.length,
        animationDuration: Duration.zero,
        initialIndex: 0,
        vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(StatitikLocale.of(context).read('PE_T0'), style: Theme.of(context).textTheme.headline3),
        ),
        body: SafeArea(
          child: productTab.isEmpty
            ? SingleChildScrollView(
            child:Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                      children: [
                        const Spacer(),
                        Text(StatitikLocale.of(context).read('PSMP_B0'), style: Theme.of(context).textTheme.headline6),
                        const SizedBox(width: 5.0),
                        const Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                        const SizedBox(width: 15.0),
                      ]
                  ),
                  const SizedBox(height: 40),
                  drawNothing(context, 'PSMP_B1')
                ]
              ),
            )
          )
            : Column(
            children: [
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
        ),
      ),
    );
  }
}
