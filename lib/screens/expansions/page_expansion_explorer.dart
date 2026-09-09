import 'package:flutter/material.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/screens/wizard/wizard_select_until_expansion.dart';

class PageExpansionExplorer extends StatefulWidget {
  final AppBar _appbar;
  final Function(ExpansionSelection) onSelection;

  const PageExpansionExplorer(this._appbar, this.onSelection, {super.key});

  @override
  State<PageExpansionExplorer> createState() => _PageExpansionExplorerState();
}

class _PageExpansionExplorerState extends State<PageExpansionExplorer> {
  ExpansionSelection selection = ExpansionSelection();

  @override
  Widget build(BuildContext context) {
    return selection.expansion == null
        ? Scaffold(
          appBar: widget._appbar,
          body: WizardSelectUntilExpansion(selection, onPress: () { setState(() {}); } )
        )
        : widget.onSelection(selection);
  }
}
