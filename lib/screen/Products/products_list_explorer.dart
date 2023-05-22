import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Products/product_viewer.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product.dart';

class ProductsListExplorer extends StatefulWidget {
  final Language language;

  const ProductsListExplorer(this.language, {Key? key}) : super(key: key);

  @override
  State<ProductsListExplorer> createState() => _ProductsListExplorerState();
}

class _ProductsListExplorerState extends State<ProductsListExplorer> with SingleTickerProviderStateMixin {
  late TabController yearController;
  List products = [];
  List years    = []; // Ordered List anti-Chrono

  void computeYearTab(int index) {
    years.clear();

    // Get all product with language
    products = Environment.instance.collection.products.values.toList()..removeWhere((product) => product.language! != widget.language);
    products.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    assert(products.isNotEmpty);

    // Extract year
    for(var product in products) {
      DateTime date = product.releaseDate;
      if(!years.contains(date.year)) {
        years.add(date.year);
      }
    }
    years.sort((a,b) => b.compareTo(a));

    // Build controller
    yearController = TabController(length: years.length,
        initialIndex: index,
        vsync: this);
  }


  @override
  void initState() {
    computeYearTab(0);
    super.initState();
  }

  Widget buildProduct(Product product) {
      return Card(
        child: TextButton(
          child: Column(
            children: [
              Expanded(child: product.image(height: null,
                alternativeRendering: Column(
                  children: [
                    Text(product.category!.name.name(widget.language)),
                    const Spacer(),
                    Text(product.name, style: product.name.length < 25.0 ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                  ],
                )
              )),
            ]
          ),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder:
            (context) => ProductViewer(widget.language, product)));
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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

      Widget page = GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: filteredProduct.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, id) {
          return buildProduct(filteredProduct.elementAt(id));
        },
      );

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
