import 'package:flutter/material.dart';
import 'package:statitik_pokemon/screen/extensionPage.dart';
import 'package:statitik_pokemon/screen/view.dart';
import 'package:statitik_pokemon/services/models.dart';
import 'package:statitik_pokemon/services/environment.dart';

class LanguagePage extends StatefulWidget {
  final Function afterSelected;

  LanguagePage({this.afterSelected});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetLanguage = [];
    for( Language l in Environment.instance.collection.languages)
    {
      Function press = (ctx) {
        return ExtensionPage(language: l, afterSelected: widget.afterSelected);
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



