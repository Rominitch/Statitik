import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/product.dart';

class ProductSelection {
  bool withSubProducts = true;
  Map<Product,     UserProductCounter> products     = {};
  Map<ProductSide, UserProductCounter> sideProducts = {};

  bool computeProductWithOtherStuff() {
    var hasSideProduct = false;
    products.forEach((product, counter) {
      hasSideProduct |= (product.sideProducts.isNotEmpty || product.otherCards.isNotEmpty) && counter.opened > 0;
    });
    return hasSideProduct;
  }
}

class ProductSelector extends StatefulWidget {
  final Language language;
  const ProductSelector(this.language, {Key? key}) : super(key: key);

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> with SingleTickerProviderStateMixin {
  late TabController tabController;

  ProductSelection selection = ProductSelection();
  List products = [];

  @override
  void initState() {
    tabController = TabController(length: 2,
      animationDuration: Duration.zero,
      initialIndex: 0,
      vsync: this);

    products = Environment.instance.collection.products.values.toList()..removeWhere((product) => product.language! != widget.language);
    products.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    assert(products.isNotEmpty);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('PS_T0')),
        actions: [
          Card(
            color: Colors.green,
            child: TextButton(
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 5),
                  Text(StatitikLocale.of(context).read('PS_B2')),
                ]
              ),
              onPressed: () async {
                var code;

                if(selection.computeProductWithOtherStuff())
                  code = await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Center(child: Text(StatitikLocale.of(context).read('warning'), style: Theme.of(context).textTheme.headline5)),
                      content: Text(StatitikLocale.of(context).read('PS_B4')),

                      actions: <Widget>[
                        Card(
                          color: Colors.green,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(StatitikLocale.of(context).read('yes')),
                          ),
                        ),
                        Card(
                          color: Colors.deepOrange,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(StatitikLocale.of(context).read('no')),
                          ),
                        ),
                        Card(
                          color: Colors.grey.shade900,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(StatitikLocale.of(context).read('cancel')),
                          ),
                        ),
                      ],
                    ),
                  );
                else
                  code = false;

                if(code != null) {
                  selection.withSubProducts = code;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(selection);
                }
              },
            )
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
                controller: tabController,
                //isScrollable: false,
                indicatorPadding: const EdgeInsets.all(1),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                tabs: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text(StatitikLocale.of(context).read('PS_B0'))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(StatitikLocale.of(context).read('PS_B1')),
                        Text(StatitikLocale.of(context).read('PS_B3'), style: TextStyle(fontSize: 10)),
                      ],
                    )),
                  ),
                ]
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ProductPerYearSelector(selection.products,     products),
                  ProductPerYearSelector(selection.sideProducts, Environment.instance.collection.productSides.values.toList(growable: false)),
                ]
              )
            )
          ]
        ),
      ),
    );
  }
}

class ProductPerYearSelector extends StatefulWidget {
  final Map       selection;
  final List      productList;
  const ProductPerYearSelector(this.selection, this.productList, {Key? key}) : super(key: key);

  @override
  State<ProductPerYearSelector> createState() => _ProductPerYearSelectorState();
}

class _ProductPerYearSelectorState extends State<ProductPerYearSelector> with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<int> years = [];
  @override
  void initState() {
    widget.productList.forEach((product) {
      DateTime date = product.releaseDate;
      if(!years.contains(date.year)) {
        years.add(date.year);
      }
    });

    years.sort((a,b) => b.compareTo(a));

    tabController = TabController(length: years.length,
        animationDuration: Duration.zero,
        initialIndex: 0,
        vsync: this);

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

      List filteredProduct = List.from(widget.productList)..removeWhere((product) => product.releaseDate.year != year);

      Widget page = GridView.builder(
        padding: EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
          childAspectRatio: 0.7,
        ),
        itemCount: filteredProduct.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, id) {
          var product = filteredProduct[id];
          return Card(
            color: widget.selection.containsKey(product) ? Colors.green : Colors.grey.shade700,
            child: TextButton(
              child: Column(
                  children: [
                    Expanded(child: product.image()),
                    Center(child: Text(product.name, style: TextStyle(fontSize: product.name.length > 9 ? 9 : 12), softWrap: true))
                  ]
              ),
              onPressed: (){
                // Add new
                if( !widget.selection.containsKey(product) )
                  widget.selection[product] = UserProductCounter.fromOpened(0);

                var info = widget.selection[product];
                // Configure
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return createProductCounterSelection(context, product, info);
                    }
                ).then((value) {
                  setState(() {
                    if(info.opened+info.seal == 0)
                      widget.selection.remove(product);
                  });
                });
              },
            ),
          );
        },
      );

      productsTab.add(page);
    });
    assert(yearsTab.length == productsTab.length);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          isScrollable: true,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blueAccent,
          ),
          tabs: yearsTab
        ),
        Expanded(
          child: TabBarView(
              controller: tabController,
              children: productsTab
          )
        )
      ]
    );
  }
}

SimpleDialog createProductCounterSelection(BuildContext context, product, counter)
{
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
                    child: Column(children: [
                      Icon(Icons.lock_open, size: 60),
                      Text(StatitikLocale.of(context).read('PSPE_B1')),
                    ]),
                  )),
              SpinBox(
                value: counter.opened.toDouble(),
                min: 0,
                max: 255,
                textStyle: TextStyle(fontSize: 13),
                onChanged: (value) {
                  counter.opened = value.toInt();
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
                    child: Column(children: [
                      Icon(Icons.lock_outline, size: 60),
                      Text(StatitikLocale.of(context).read('PSPE_B2')),
                    ]),
                  )),
              SpinBox(
                value: counter.seal.toDouble(),
                min: 0,
                max: 255,
                textStyle: TextStyle(fontSize: 13),
                onChanged: (value) {
                  counter.seal = value.toInt();
                },
              ),
            ],
          ),
        ),
      )
    ],
  );
}