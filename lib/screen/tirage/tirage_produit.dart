import 'package:flutter/material.dart';
import 'package:statitik_pokemon/screen/tirage/tirage_resume.dart';
import 'package:statitik_pokemon/services/models.dart';
import 'package:statitik_pokemon/services/environment.dart';

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
                    Image(
                      image: prod.image(),
                        height: 70,
                    ),
                    Text( prod.name, softWrap: true, ),
                  ]
              ),
              onPressed: (){
                Environment.instance.boosterDraws = prod.buildBoosterDraw();
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResumePage(product: prod)));
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
                    Image(
                      image: widget.language.create(),
                      height: AppBar().preferredSize.height * 0.6,
                    ),
                    SizedBox(width: 10.0),
                    widget.subExt.image(),
                  ],
                ),
              ),
            ),
            body: Container(
              child:
                widgetProd == null
                    ? Center( child: Text("Chargement...", style: Theme.of(context).textTheme.headline1))
                    : (widgetProd.isEmpty ? Center( child: Text("Aucun produit n'est disponible", style: Theme.of(context).textTheme.headline1))
                      : GridView.count(
                          crossAxisCount: 3,
                          scrollDirection: Axis.vertical,
                          primary: false,
                          children: widgetProd,
                        )
                  ),
            )
    );
  }
}