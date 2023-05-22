import 'package:flutter/material.dart';
import 'package:statitikcard/screen/admin/side_product_creator.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/product_category.dart';

class SideProductSelection extends StatefulWidget {
  final Language activeLanguage;
  final bool     edition;
  final Product? productInfo;
  const SideProductSelection(this.activeLanguage, {this.edition=false, this.productInfo, Key? key}) : super(key: key);

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
                  style: Theme.of(context).textTheme.headlineSmall, softWrap: true)),
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
      primary: false,
      shrinkWrap: true,
      children: widgets,
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
               Text(value.name, style: Theme.of(context).textTheme.titleLarge, softWrap: true),
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
      primary: false,
      shrinkWrap: true,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('SPS_T0'), style: Theme.of(context).textTheme.headlineSmall),
        actions: widget.edition && Environment.instance.isAdministrator() ? [
          IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SideProductCreator(widget.activeLanguage, product: widget.productInfo))).then((value) {
                setState(() {
                  filterCategory = null;
                });
              });
            },
            icon: const Icon(Icons.add_box_outlined))
        ] : [],
      ),
      body: SafeArea(
        child: (filterCategory == null) ?
          categorySelector()
        : productSelector(),
      )
    );
  }
}
