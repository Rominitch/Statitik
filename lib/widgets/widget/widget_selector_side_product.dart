import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/products/poke_product_category.dart';

class WidgetSelectorSideProduct extends StatefulWidget {
  final PokeNavLanguage _nav;
  final bool     edition;
  const WidgetSelectorSideProduct(this._nav, {this.edition=false, super.key});

  @override
  State<WidgetSelectorSideProduct> createState() => _SideProductSelectionState();
}

class _SideProductSelectionState extends State<WidgetSelectorSideProduct> {
  PokeProductCategory? filterCategory;

  Widget categorySelector() {
    List<Widget> widgets=[];
    widget._nav.collection.productCategories().forEach((category) {
      if(!category.isContainer) {
        widgets.add(Card(
          child: TextButton(
            child: Center(child:
            Text(category.name(widget._nav.language),
                style: Theme.of(context).textTheme.headlineSmall, softWrap: true)),
            onPressed: () {
              setState(() {
                filterCategory = category;
              });
            },
          ),
        ));
      }
    });

    return GridView.count(
      crossAxisCount: 3,
      primary: false,
      shrinkWrap: true,
      children: widgets,
    );
  }

  Widget productSelector() {
    List<Widget> widgets=[];
    widget._nav.collection.productSides().forEach((sideProduct) {
      if( sideProduct.category == filterCategory) {
        widgets.add(Card(
          child: TextButton(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  sideProduct.image(),
                  Text(sideProduct.name(widget._nav.language), style: Theme.of(context).textTheme.titleLarge, softWrap: true),
                ]
            ),
            onPressed: () {
              setState(() {
                Navigator.of(context).pop(sideProduct);
              });
            },
          ),
        ));
      }
    });

    return GridView.count(
      crossAxisCount: 3,
      primary: false,
      shrinkWrap: true,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return(filterCategory == null) ? categorySelector() : productSelector();
  }
}
