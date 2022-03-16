import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';

class PokeSpaceProductsExplorer extends StatefulWidget {
  final Language? language;
  final Function  onChangeMyProduct;

  const PokeSpaceProductsExplorer(this.language, this.onChangeMyProduct);

  @override
  State<PokeSpaceProductsExplorer> createState() => _PokeSpaceProductsExplorerState();
}

class _PokeSpaceProductsExplorerState extends State<PokeSpaceProductsExplorer> with SingleTickerProviderStateMixin {
  late TabController yearController;
  Map   myProducts = {};
  List  years = []; // Ordered List anti-Chrono

  void computeYearTab(int index) {
    var mySpace = Environment.instance.user!.pokeSpace;

    // Get all product with language
    myProducts  = mySpace.getProductsBy(widget.language);

    // Extract year
    myProducts.forEach((product, value) {
      DateTime date = product.releaseDate;
      if(!years.contains(date.year)) {
        years.add(date.year);
      }
    });

    years.sort((a,b) => b.compareTo(a));

    // Build controller
    yearController = TabController(length: years.length,
        initialIndex: index,
        vsync: this);
  }

  Widget buildCounter(UserProductCounter counter) {
    var buildCard = (int count, icon, color) {
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
                Text(count.toString(), style: TextStyle(fontSize: 12)),
              ],
            ),
          )
        )
      );
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if(counter.opened > 0)
          buildCard(counter.opened, Icons.lock_open, Colors.green),
        if(counter.seal > 0)
          buildCard(counter.opened, Icons.lock_outline, Colors.deepOrange),
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
    years.forEach((year) {
      yearsTab.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(year.toString()),
      ));

      Map filteredProduct = Map.from(myProducts)..removeWhere((product, value) => product.releaseDate.year != year);

      Widget page = GridView.builder(
        padding: EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: filteredProduct.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, id) {
          var product = filteredProduct.keys.elementAt(id);
          var info    = filteredProduct[product];
          return Card(
            child: TextButton(
              child: Column(
                children: [
                  Expanded(child: product.image()),
                  buildCounter(info),
                ]
              ),
              onPressed: (){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        titlePadding: EdgeInsets.zero,
                        contentPadding: EdgeInsets.zero,
                        insetPadding: EdgeInsets.zero,
                        title: Center(child: Text(StatitikLocale.of(context).read('PSPE_B0'))),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Card(
                                    color: Colors.green,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Icon(Icons.lock_open, size: 60),
                                          Text(StatitikLocale.of(context).read('PSPE_B1')),
                                        ]
                                      ),
                                    )
                                  ),
                                  SpinBox(
                                    value: info.opened.toDouble(),
                                    min: 0,
                                    max: 255,
                                    textStyle: TextStyle(fontSize: 13),
                                    onChanged: (value) {
                                      info.opened = value.toInt();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Card(
                                      color: Colors.deepOrange,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            children: [
                                              Icon(Icons.lock_outline, size: 60),
                                              Text(StatitikLocale.of(context).read('PSPE_B2')),
                                            ]
                                        ),
                                      )
                                  ),
                                  SpinBox(
                                    value: info.seal.toDouble(),
                                    min: 0,
                                    max: 255,
                                    textStyle: TextStyle(fontSize: 13),
                                    onChanged: (value) {
                                      info.seal = value.toInt();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }
                ).then((value) {
                  setState(() {});
                });
              },
            ),
          );
        },
      );

      productsTab.add(page);
    });

    return Column(
      children: [
        TabBar(
            controller: yearController,
            indicatorPadding: const EdgeInsets.all(1),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
            tabs: yearsTab
        ),
        Expanded(
          child: TabBarView(
            controller: yearController,
            physics: NeverScrollableScrollPhysics(),
            children: productsTab,
          )
        )
      ]
    );
  }
}
