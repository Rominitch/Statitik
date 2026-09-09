
import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/widgets/expansion/widget_selector_card_in_expansion.dart';
import 'package:statitikcard/widgets/expansion/widget_expansions_selector.dart';

class WizardSelectUntilCard extends StatefulWidget {
  final PokeLanguage _language;
  const WizardSelectUntilCard(this._language, {super.key});

  @override
  State<WizardSelectUntilCard> createState() => _WizardSelectUntilCardState();
}

class _WizardSelectUntilCardState extends State<WizardSelectUntilCard> {

  late ExpansionSelection selection;

  @override
  void initState() {
    selection = ExpansionSelection(language: widget._language);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return selection.expansion == null
      ? WidgetExpansionsSelector(selection, () { setState(() {}); }, false )
      : WidgetSelectorCardInExpansion(widget._language, selection.expansion!);
  }
}
