import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';

class LanguagePage extends StatefulWidget {
  final Function afterSelected;

  LanguagePage({this.afterSelected});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  List<Widget> widgetLanguage;

  @override
  void initState() {
    widgetLanguage = [];
    for( Language l in Environment.instance.collection.languages)
    {
      Function press = (ctx) {
        return ExtensionPage(language: l, afterSelected: widget.afterSelected);
      };
      widgetLanguage.add(createLanguage(l, context, press));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('L_T0')),
       ),
        body: SafeArea(
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(10),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: widgetLanguage,
          ),
        ),
    );
  }
}



