import 'package:flutter/material.dart';
import 'package:statitikcard/screen/tirage/tirage_resume.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';

const bool imageRight = false; // Waiting autorization

class ProductPage extends StatefulWidget {
  final Language language;
  final SubExtension subExt;

  ProductPage({ this.language, this.subExt });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Widget> widgetProd;

  void setupProducts() async {
    List products = await Environment.instance.readProducts(widget.language, widget.subExt);

    widgetProd = [];
    if(products != null) {
      for(Product prod in products) {
        widgetProd.add(Card(
            child: FlatButton(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if(imageRight) prod.image(),
                    Text( prod.name, textAlign: TextAlign.center, softWrap: true, ),
                  ]
              ),
              onPressed: () {
                // Build new session of draw
                Environment.instance.currentDraw = SessionDraw(product: prod, language:widget.language);
                // Go to page
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResumePage()));
              },
            )
        ));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setupProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Container(
                child: Row(
                  children:[
                    Text('Produits'),
                    SizedBox(width: 10.0),
                    widget.language.barIcon(),
                    SizedBox(width: 10.0),
                    widget.subExt.image( wSize: iconSize ),
                  ],
                ),
              ),
            ),
            body:
                widgetProd == null
                    ? Center( child: Text("Chargement...", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1))
                    : (widgetProd.isEmpty ? Center( child: Text("Aucun produit n'est disponible", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1))
                      : GridView.count(
                          crossAxisCount: 3,
                          scrollDirection: Axis.vertical,
                          primary: false,
                          children: widgetProd,
                        )
              )
    );
  }
}