import 'package:flutter/material.dart';
import 'package:statitik_pokemon/screen/tirage/tirage_extension.dart';
import 'package:statitik_pokemon/screen/view.dart';
import 'package:statitik_pokemon/services/models.dart';
import 'package:statitik_pokemon/services/environment.dart';

class Tirage extends StatefulWidget {
  @override
  _TirageState createState() => _TirageState();
}

class _TirageState extends State<Tirage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetLanguage = [];
    for( Language l in Environment.instance.collection.languages)
    {
      Function press = (ctx) {
        return ProductExtFilter(language: l);
      };
      widgetLanguage.add(createLanguage(l, context, press));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sélection de la langue'),
       ),
        body: SafeArea(
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: widgetLanguage,
          ),
        ),
    );
  }
}



