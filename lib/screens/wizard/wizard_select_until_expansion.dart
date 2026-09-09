
import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_language.dart';

import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/widgets/expansion/widget_expansions_selector.dart';

class WizardSelectUntilExpansion extends StatefulWidget {
  final ExpansionSelection selection;
  final void Function()    onPress;

  const WizardSelectUntilExpansion(this.selection, {required this.onPress, super.key});

  @override
  State<WizardSelectUntilExpansion> createState() => _WizardSelectUntilExpansionState();
}

class _WizardSelectUntilExpansionState extends State<WizardSelectUntilExpansion> {

  @override
  void initState() {
    super.initState();
  }

  Widget languageIcons(List<Language> languages) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        itemCount: languages.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final id = languages[index];
          final l = Environment.instance.pkCollection().language(id);
          return TextButton(
            child: Image(image: l.create()),
            onPressed: () {
              _onClickLanguage(context, l);
            },
          );
        }
      ),
    );
  }

  void _onClickLanguage(BuildContext context, PokeLanguage l) {
    setState(() {
      widget.selection.language = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row( children: [
          Card( child: Row( children:[Icon(Icons.catching_pokemon), languageIcons([Language.jp])] )),
          Card( child: Row( children:[Icon(Icons.language), languageIcons([Language.en, Language.fr])] ))
        ]),
        if( widget.selection.language != null )
          Expanded(child: Card(child: WidgetExpansionsSelector(widget.selection, widget.onPress, false) ))
      ],
    );
  }
}
