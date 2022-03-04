import 'package:flutter/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/models.dart';

class SideProductSelection extends StatefulWidget {
  final Language activeLanguage;
  const SideProductSelection(this.activeLanguage, {Key? key}) : super(key: key);

  @override
  State<SideProductSelection> createState() => _SideProductSelectionState();
}

class _SideProductSelectionState extends State<SideProductSelection> {
  ProductCategory? filterCategory;

  Widget categorySelector() {
    List<Widget> widgets=[];
    Environment.instance.collection.categories.forEach((key, value) {
      if(!value.isContainer) {
        widgets.add(Card(
          child: TextButton(
            child: Center(child:
              Text(value.name.name(widget.activeLanguage),
                  style: Theme.of(context).textTheme.headline5, softWrap: true)),
            onPressed: () {
              setState(() {
                filterCategory = value;
              });
            },
          ),
        ));
      }
    });

    return GridView.count(
      crossAxisCount: 3,
      children: widgets,
      primary: false,
      shrinkWrap: true,
    );
  }

  Widget productSelector() {
    List<Widget> widgets=[];
    Environment.instance.collection.productSides.forEach((key, value) {
      if( value.category == filterCategory) {
        widgets.add(Card(
          child: TextButton(
            child: Column(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               value.image(),
               Text(value.name, style: Theme.of(context).textTheme.headline6, softWrap: true),
             ]
            ),
            onPressed: () {
              setState(() {
                Navigator.of(context).pop(value);
              });
            },
          ),
        ));
      }
    });

    return GridView.count(
      crossAxisCount: 3,
      children: widgets,
      primary: false,
      shrinkWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('SPS_T0'), style: Theme.of(context).textTheme.headline5),
      ),
      body: SafeArea(
        child: (filterCategory == null) ?
          categorySelector()
        : productSelector(),
      )
    );
  }
}
