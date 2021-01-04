import 'package:flutter/material.dart';
import 'package:statitik_pokemon/screen/view.dart';
import 'package:statitik_pokemon/services/models.dart';
import 'package:statitik_pokemon/services/environment.dart';

import 'package:statitik_pokemon/screen/tirage/tirage_produit.dart';

class ProductExtFilter extends StatefulWidget {
  final Language language;

  ProductExtFilter({ this.language });

  @override
  _ProductExtFilterState createState() => _ProductExtFilterState();
}

class _ProductExtFilterState extends State<ProductExtFilter> {
  bool showName = false;

  @override
  Widget build(BuildContext context) {
    //80% of screen width
    double cWidth = MediaQuery.of(context).size.width;

    List<Widget> ext = [];
    for( Extension e in Environment.instance.collection.extensions)
    {
      List<Widget> se = [];
      for( SubExtension e in Environment.instance.collection.getSubExtensions(e))
      {
        Function press = (ctx) {
          return ProductPage(language: widget.language, subExt: e);
        };
        se.add( createSubExtension(e, context, press, showName) );
      }
      ext.add(Container(
        color: Colors.grey[800],
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(e.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5,
              ),
            ),
            Container(
              height: 60.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: se,
              ),
            ),
          ],
        ),
      ),
      );
    }

    return Container(
        child: Scaffold(
          appBar: AppBar(
            title: Container(
              child: Row(
                children:[
                  Text('Selection d\'une extension'),
                  SizedBox(width: 10.0),
                  Image(
                    image: widget.language.create(),
                    height: AppBar().preferredSize.height * 0.6,
                  ),
                ],
              ),
            ),
          ),
          body: Container(
              padding: const EdgeInsets.all(10.0),
              width: cWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Veuillez choisir l\'extension d\'un booster de votre produit.'),
                  //SizedBox( height: 10.0, ),
                  CheckboxListTile(
                    title: Text("Afficher les noms"),
                    value: showName,
                    onChanged: (newValue) {
                      setState(() {
                        showName = newValue;
                      });
                    },
                  ),
                  //SizedBox( height: 10.0, ),
                  ListView( shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: ext ),
                ],
              )
          ),
        )
    );
  }
}