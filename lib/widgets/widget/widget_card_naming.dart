import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_form.dart';
import 'package:statitikcard/models/poke_region.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/screens/wizard/wizard_select_title_name.dart';

class WidgetCardNaming extends StatefulWidget {
  final PokeNavAdmin             _nav;
  final PokeCardViewerIdentifier _card;
  final int                   idName;
  final Function()            _refresh;

  const WidgetCardNaming(this._nav, this._card, this.idName, this._refresh, {super.key});

  PokeCard card() {
    return _card.cardInExp().card;
  }

  PokeFullCardPokemon nameInfo() {
    return card().title.title[idName];
  }

  @override
  State<WidgetCardNaming> createState() => _WidgetCardNamingState();


}

class _WidgetCardNamingState extends State<WidgetCardNaming> {
  late CustomRadioController specialController = CustomRadioController(onChange: (PokeForm?  value) { onSpecialChanged(value); });
  late CustomRadioController regionController  = CustomRadioController(onChange: (PokeRegion? value) { onRegionChanged(value); });

  void onRegionChanged(PokeRegion? value) {
    widget.nameInfo().region = value;
  }

  void onSpecialChanged(PokeForm? value) {
    widget.nameInfo().form = value;
  }

  @override
  Widget build(BuildContext context) {
    final regions = widget._nav.collection.regions();
    final forms   = widget._nav.collection.forms();
    var name = widget.nameInfo();
    List<Widget> formWidget   = [];

    for (final form in widget._nav.collection.forms()) {
      final text = widget._nav.showLanguage.label(form)!;
      formWidget.add(CustomRadio(value: form, controller: specialController,
        widget: Row(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Center(child: Text(
              text,
              style: TextStyle(fontSize: text.length > 12 ? 8 : 10), softWrap: true)))
          ])
      )
      );
    }
    regionController.afterPress(name.region);
    specialController.afterPress(name.form);

    final nbItems = (MediaQuery.of(context).size.width / 200).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.grey[700],
                child: TextButton(
                  child: Text( name.name.name(widget._nav.showLanguage)!, style: const TextStyle(fontSize: 9.0)),
                  onPressed: () {
                    setState(() {
                      WizardSelectTitleName.select(context, widget._nav, isPokemonCard(widget.card().type),
                        (CardTitle selectedTitle) {
                          setState(() {
                            widget.card().title.title[widget.idName] = PokeFullCardPokemon(selectedTitle);
                          });
                        });
                    });
                  }
                )
              )
            ),
            IconButton(
              onPressed: (){
                widget.card().title.title.remove(widget.nameInfo());
                widget._refresh();
              },
              icon: const Icon(Icons.delete)
            ),
          ],
        ),
        if( isPokemonType(widget.card().type) )
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: regions.length + 1,
              itemBuilder: (context, index) {
                if( index < regions.length ) {
                  final region = regions[index];
                  return widget._nav.rendering.createRegionWidget(
                    region, region.applicableName(widget._nav.showLanguage)!,
                    regionController
                  );
                } else {
                  return widget._nav.rendering.createRegionWidget(
                    null, AppLocalizations.of(context)!.reg_0,
                      regionController,
                  );
                }
              },
            ),
          ),
        if( isPokemonType(widget.card().type) )
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: nbItems, crossAxisSpacing: 0, mainAxisSpacing: 0,
              childAspectRatio: 3.0),
            primary: false,
            shrinkWrap: true,
            itemCount: forms.length + 1,
            itemBuilder: (context, index) {
              if( index < forms.length) {
                final form = forms[index];
                final text = widget._nav.showLanguage.label(form)!;
                return CustomRadio(value: form, controller: specialController,
                  widget: Text(text, style: TextStyle(fontSize: text.length > 12 ? 8 : 10), softWrap: true)
                );
              } else {
                return CustomRadio(value: null, controller: specialController,
                  widget: Text("", style: TextStyle(fontSize: 8), softWrap: true)
                );
              }
            }
          )
      ],
    );
  }
}