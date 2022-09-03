import 'package:flutter/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/pokespace.dart';

class ProductsListExplorer extends StatefulWidget {
  final Language? language;

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

  Widget buildCounter(UserProductCounter counter) {
    buildCard(int count, icon, color) {
      return Expanded(
        child: Card(
          margin: const EdgeInsets.all(2.0),
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12),
                Text(count.toString(), style: const TextStyle(fontSize: 12)),
              ],
            ),
          )
        )
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if(counter.opened > 0)
          buildCard(counter.opened, Icons.lock_open, Colors.green),
        if(counter.seal > 0)
          buildCard(counter.seal, Icons.lock_outline, Colors.deepOrange),
      ],
    );
  }

  @override
  void initState() {
    computeYearTab(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> yearsTab = [];
    List<Widget> productsTab = [];
    for(var year in years){
      yearsTab.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(year.toString()),
      ));

      var filteredProduct = List.from(products)..removeWhere((product) => product.releaseDate.year != year);

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
          var product = filteredProduct.elementAt(id);

          return Card(
            child: TextButton(
              child: Column(
                children: [
                  Expanded(child: product.image()),
                ]
              ),
              onPressed: (){

              },
            ),
          );
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
