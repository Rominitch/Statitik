import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';

enum ProductPageMode {
  SingleSelection,
  MultiSelection,
}

class ProductPage extends StatefulWidget {
  final Language language;
  final SubExtension subExt;
  final Function afterSelected;
  final ProductPageMode mode;

  ProductPage({ this.mode, this.language, this.subExt, this.afterSelected });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Widget> widgetProd;
  bool productFound = false;

  bool isMulti() {
    return (widget.mode == ProductPageMode.MultiSelection);
  }

  void setupProducts(BuildContext context) {
    if(widgetProd != null)
      widgetProd.clear();

    Environment.instance.readProducts(widget.language, widget.subExt, false, -1).then((products) {
      widgetProd = [];
      productFound = false;

      // All products
      if( isMulti() ) {
        widgetProd.add(
            Card(
              child: FlatButton(child: Row(
                  children: [
                    Text(StatitikLocale.of(context).read('S_B9'), style: Theme
                        .of(context)
                        .textTheme
                        .headline5),
                    Expanded(child: SizedBox(width: 10)),
                    Text(StatitikLocale.of(context).read('TP_B2'),
                        style: TextStyle(fontSize: 9)),
                    Icon(Icons.arrow_right_outlined)
                  ]),
                onPressed: () {
                  widget.afterSelected(context, widget.language, null, -1);
                },
              ),
            ));
      }

      // For each product
      int count = 1;
      for (var catProd in products) {
        int idCategory = count;
        List<Widget> productCard = [];

        for (Product prod in catProd) {
          productFound = true;

          String nameProduct = prod.name;
          if(isMulti()) {
            int countP = prod.countProduct();
            // Stop and don't show
            if(countP == 0)
              continue;

            nameProduct += ' (${countP.toString()})';
          }

          bool productImage = prod.hasImages() && Environment.instance.showPressProductImages;
          productCard.add(Card(
              color: prod.color,
              child: FlatButton(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if(productImage) prod.image(),
                      if(productImage) Text(
                          nameProduct, textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(fontSize: ((prod.name.length > 15)
                              ? 8
                              : 13)))
                      else
                        Text(nameProduct, textAlign: TextAlign.center,
                          softWrap: true,),

                    ]
                ),
                onPressed: () {
                  widget.afterSelected(context, widget.language, prod, -1);
                },
              )
          ));
        }

        if (productCard.isNotEmpty) {
          assert(1 <= idCategory && idCategory <= Environment.instance.collection.category);
          if(isMulti()) {
            widgetProd.add(
                Card(
                  child: FlatButton(
                    child: Row(
                    children: [
                      Text(categoryName(context, idCategory), style: Theme
                      .of(context)
                      .textTheme
                      .headline5),
                      Expanded(child: SizedBox(width: 10)),
                      Text(StatitikLocale.of(context).read('TP_B2'), style: TextStyle(fontSize: 9)),
                      Icon(Icons.arrow_right_outlined)
                    ]),
                    onPressed: () {
                      widget.afterSelected(context, widget.language, null, idCategory);
                    },
                  ),

                ));
          } else {
            widgetProd.add(
                Text(categoryName(context, idCategory), style: Theme
                    .of(context)
                    .textTheme
                    .headline5));
          }
          widgetProd.add(GridView.count(
            crossAxisCount: 3,
            scrollDirection: Axis.vertical,
            primary: false,
            children: productCard,
            shrinkWrap: true,
          ));
        }
        count += 1;
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    setupProducts(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Container(
                child: Row(
                  children:[
                    Text(StatitikLocale.of(context).read('TP_T0')),
                    SizedBox(width: 10.0),
                    widget.language.barIcon(),
                    SizedBox(width: 10.0),
                    widget.subExt.image( wSize: iconSize ),
                  ],
                ),
              ),
              actions: [
                Card(child: FlatButton(
                    child: Icon(Icons.help_outline,),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => new AlertDialog(
                            title: new Text(StatitikLocale.of(context).read('help')),
                            content: Text( StatitikLocale.of(context).read('TP_B1'),
                                textAlign: TextAlign.justify),
                            )
                      );
                    },
                ))
              ],
            ),
            body:
                widgetProd == null
                    ? Center( child: Text(StatitikLocale.of(context).read('loading'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1))
                    : (widgetProd.isEmpty ? Center( child: Text(StatitikLocale.of(context).read('TP_B0'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1))
                      : SingleChildScrollView(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widgetProd,
                          ),
                      )
              )
    );
  }
}