import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/product.dart';

enum ProductPageMode {
  SingleSelection,
  MultiSelection,
}

class ProductPage extends StatefulWidget {
  final Language language;
  final SubExtension subExt;
  final Function afterSelected;
  final ProductPageMode mode;

  ProductPage({ required this.mode, required this.language, required this.subExt, required this.afterSelected });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Widget>? widgetProd;
  bool productFound = false;

  bool isMulti() {
    return (widget.mode == ProductPageMode.MultiSelection);
  }

  void setupProducts(BuildContext context) {
    if(widgetProd != null) {
      widgetProd!.clear();
    }

    readProducts(widget.language, widget.subExt, null, isMulti() ? widget.subExt : null ).then((products) {
      widgetProd = [];
      productFound = false;

      // All products
      if( isMulti() ) {
        widgetProd!.add(
            Card(
              child: TextButton(child: Row(
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
              child: TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
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
            widgetProd!.add(
                Card(
                  child: TextButton(
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
            widgetProd!.add(
                Text(categoryName(context, idCategory), style: Theme
                    .of(context)
                    .textTheme
                    .headline5));
          }
          widgetProd!.add(GridView.count(
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
                    Text(StatitikLocale.of(context).read('TP_T0'), style: Theme.of(context).textTheme.headline5),
                    SizedBox(width: 5),
                    widget.language.barIcon(),
                    widget.subExt.image( wSize: iconSize ),
                  ],
                ),
              ),
              actions: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  radius: 20,
                  child: TextButton(
                      child: Icon(Icons.add_photo_alternate_outlined,),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) => createRequest()
                        );
                      },
                  ),
                ),
                SizedBox(width: 5),
                CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    radius: 20,
                    child: TextButton(
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
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
            body:
                widgetProd == null
                    ? drawLoading(context)
                    : (widgetProd!.isEmpty ? Center( child: Text(StatitikLocale.of(context).read('TP_B0'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1))
                      : SingleChildScrollView(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widgetProd!,
                          ),
                      )
              )
    );
  }

  AlertDialog createRequest()
  {
    String info="";
    String eac="";
    return new AlertDialog(
      title: new Text(StatitikLocale.of(context).read('TP_B3')),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [Text(StatitikLocale.of(context).read('TP_B4')),
                TextField(
                    onChanged: (value) {
                      info = value;
                    }
                ),
              ]),
            )),
            Card(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [Text(StatitikLocale.of(context).read('TP_B5')),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    eac = value;
                  }
                ),
              ]),
            )),
          ]
      ),
      actions: <Widget>[
        TextButton(
          child: Text(StatitikLocale.of(context).read('confirm')),
          onPressed: () {
            if(info.isNotEmpty) {
              Environment.instance.sendRequestProduct(info, eac).then((value) => Navigator.of(context).pop());
            }
          },
        ),
        TextButton(
          child: Text(StatitikLocale.of(context).read('cancel')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}