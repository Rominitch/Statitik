
import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_langage.dart';

import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/widgets/widget_expansions_selector.dart';

class WidgetCardVersionSelector extends StatefulWidget {
  final ExpansionSelection selection;
  final Function onPress;

  const WidgetCardVersionSelector(this.selection, {required this.onPress, super.key});

  @override
  State<WidgetCardVersionSelector> createState() => _WidgetCardVersionSelectorState();
}

class _WidgetCardVersionSelectorState extends State<WidgetCardVersionSelector> {

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

  void _onClickLanguage(BuildContext context, PokeLangage l) {
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
