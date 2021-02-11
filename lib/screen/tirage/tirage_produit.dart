import 'package:flutter/material.dart';
import 'package:statitikcard/screen/tirage/tirage_resume.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';

class ProductPage extends StatefulWidget {
  final Language language;
  final SubExtension subExt;

  ProductPage({ this.language, this.subExt });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Widget> widgetProd;
  bool productFound = false;

  void setupProducts(BuildContext context) {
    Environment.instance.readProducts(widget.language, widget.subExt).then((products) {
      widgetProd = [];
      productFound = false;

      for (int id = 0; id < products.length; id += 1) {
        List<Widget> productCard = [];

        for (Product prod in products[id]) {
          productFound = true;
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
                          prod.name, textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(fontSize: ((prod.name.length > 15)
                              ? 8
                              : 13)))
                      else
                        Text(prod.name, textAlign: TextAlign.center,
                          softWrap: true,),

                    ]
                ),
                onPressed: () {
                  // Build new session of draw
                  Environment.instance.currentDraw =
                      SessionDraw(product: prod, language: widget.language);
                  // Go to page
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ResumePage()));
                },
              )
          ));
        }

        if (productCard.isNotEmpty) {
          assert(Environment.instance.collection.category.containsKey(id));
          widgetProd.add(
              Text(Environment.instance.collection.category[id], style: Theme
                  .of(context)
                  .textTheme
                  .headline5));
          widgetProd.add(GridView.count(
            crossAxisCount: 3,
            scrollDirection: Axis.vertical,
            primary: false,
            children: productCard,
            shrinkWrap: true,
          ));
        }
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    setupProducts(context);
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widgetProd,
                          ),
                      )
              )
    );
  }
}