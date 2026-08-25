
import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_serie.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/screenOld/widgets/button_check.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/widgets/widget_expansion_button.dart';

class WidgetExpansionsSelector extends StatefulWidget {
  final ExpansionSelection _selection;
  final void Function()    onPress;
  final bool               addMode;
  const WidgetExpansionsSelector(this._selection, this.onPress, this.addMode, {super.key});

  @override
  State<WidgetExpansionsSelector> createState() => _WidgetExpansionsSelectorState();
}

class _WidgetExpansionsSelectorState extends State<WidgetExpansionsSelector> {
  late List<ExpansionType> series = widget.addMode ? [ExpansionType.Normal] : [ExpansionType.Normal, ExpansionType.Promo, ExpansionType.Deck];
  late CustomButtonCheckController refreshController = CustomButtonCheckController(refresh);

  void refresh() {
    setState(() {

    });
  }

  int _bestNumberOfExpansions(double parentWidth) {
    if( parentWidth > 500) {
      final int nbItems = (parentWidth / 90).toInt();
      return Environment.instance.pkConfig().showExtensionName ? (nbItems / 2.8).ceil() : nbItems;
    } else {
      return Environment.instance.pkConfig().showExtensionName ? 3 : 5;
    }
  }

  List<Widget> buildExts() {
    final collection = Environment.instance.pkCollection();
    List<Widget> ext = [];
    for( final serie in collection.series() )
    {
      List<Widget> subExtensions = [];

      final expansions = serie.expansions(widget._selection.language!.location());
      if( expansions != null ) {
        for( PokeExpansion se in expansions)
        {
          if( series.contains(se.type()) ) {
            press() {
              setState(() {
                widget._selection.expansion = se;
                widget.onPress();
              });
            }
            subExtensions.add(WidgetExpansionButton(serie: serie, selection: widget._selection, expansion: se, press: press));
          }
        }
        if(subExtensions.isNotEmpty) {
          ext.add(Container(
            color: Colors.grey[800],
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(serie.label(widget._selection.language!)!,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                ),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // constraints.maxWidth and constraints.maxHeight are your parent's size.
                    return GridView.count(
                      crossAxisCount: _bestNumberOfExpansions(constraints.maxWidth),
                      childAspectRatio: Environment.instance.pkConfig().showExtensionName ? 2.5 : 1,
                      shrinkWrap: true,
                      primary: false,
                      children: subExtensions,
                    );
                  }
                )
              ],
            ),
          ),
          );
        }
      } else {
        subExtensions.add(Text("Nothing"));
      }
    }
    return ext;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filters = [];
    if(!widget.addMode) {
      for (var element in ExpansionType.values) {
        filters.add(
            Expanded(child: ExpansionTypeButtonCheck(series, element, controller: refreshController))
        );
      }
    }
    List<Widget> ext = buildExts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.addMode ? Text(AppLocalizations.of(context)!.ep_b0)
            : Row( children: filters,
        ),
        CheckboxListTile(
          title: Text(AppLocalizations.of(context)!.ep_b1),
          value: Environment.instance.pkConfig().showExtensionName,
          onChanged: (newValue) {
            setState(() {
              Environment.instance.pkConfig().toggleShowExtensionName();
            });
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column( children: ext ),
          ),
        )
      ]);
  }
}
