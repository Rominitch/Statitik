import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/commonPages/extension_page.dart';
import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class LanguagePage extends StatefulWidget {
  final Function(BuildContext, LanguageOld, SubExtension) afterSelected;
  final bool addMode;

  const LanguagePage({required this.afterSelected, required this.addMode, super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late List<Widget> widgetLanguage;

  @override
  void initState() {
    widgetLanguage = [];
    for( LanguageOld l in Environment.instance.collection.languages.values)
    {
      Widget press(ctx) {
        return ExtensionPage(language: l, afterSelected: widget.afterSelected, addMode: widget.addMode);
      }
      widgetLanguage.add(createLanguage(l, context, press));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.l_t0),
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

class LanguageSelector extends StatelessWidget {
  final Function(BuildContext, LanguageOld) onClickLanguage;

  const LanguageSelector(this.onClickLanguage, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetLanguage = [];
    for( LanguageOld l in Environment.instance.collection.languages.values)
    {
      widgetLanguage.add(TextButton(
        child: Image(image: l.create()),
        onPressed: () {
          onClickLanguage(context, l);
        },
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.l_t0),
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



