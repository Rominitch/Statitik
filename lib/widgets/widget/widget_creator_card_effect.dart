import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card_effect.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/widgets/widget/widget_creator_card_effects.dart';
import 'package:statitikcard/widgets/widget/widget_energy_button.dart';

class WidgetCreatorCardEffect extends StatefulWidget {
  final PokeNavAdmin    _navAdmin;
  final PokeCardEffect  _effect;

  const WidgetCreatorCardEffect(this._navAdmin, this._effect, {super.key});

  @override
  State<WidgetCreatorCardEffect> createState() => _WidgetCreatorCardEffectState();
}

class _WidgetCreatorCardEffectState extends State<WidgetCreatorCardEffect> {
  double typeSize = 40.0;

  static const double maxParam = 1000.0;

  void onTypeChanged(id, effect, value) {
    effect.attack[id] = value;
  }

  @override
  void initState() {
    // Fill with 5 elements
    while(widget._effect.attack.length < 5) {
      widget._effect.attack.add(PokeCardType.unknown);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final language = widget._navAdmin.showLanguage;

    String name        = AppLocalizations.of(context)!.ca_b23;
    String description = AppLocalizations.of(context)!.ca_b24;
    int nbParameters = 0;
    if(widget._effect.title != null) {
      name = language.label(widget._effect.title!.pid())!;
    }

    List<Widget> parameterWidgets = [];
    /*
    if(widget._effect.description != null) {
      description = widget._effect.description!.decrypted(Environment.instance.collection.descriptions, widget.parent.l).finalString.join();
      RegExp re = RegExp(r"\{(\d*)\}", unicode: true);
      re.allMatches(description).forEach((element) {
        nbParameters = max(nbParameters, int.parse(element.group(1)!));
      });
      //nbParameters = re.allMatches(description).length;

      int id = 0;
      while( id < nbParameters) {
        // Create parameter if needed
        if( id >= widget._effect.description!.parameters.length) {
          widget._effect.description!.parameters.add(0);
        }

        int localId = id;
        parameterWidgets.add(
            Row(
                children: [
                  Text(AppLocalizations.of(context)!.ca_b19),
                  Expanded(
                    child: SpinBox(value: widget._effect.description!.parameters[localId].toDouble(), max: maxParam,
                        onChanged: (value){
                          setState(() {
                            if (widget._effect.description!.parameters.isEmpty) {
                              widget._effect.description!.parameters.add(value.toInt());
                            } else {
                              widget._effect.description!.parameters[localId] = value.toInt();
                            }
                          });
                        }),
                  )
                ]
            )
        );
        id += 1;
      }
    }*/

    return Card(
        color: Colors.grey[800],
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Effect
              Card(
                color: Colors.grey[600],
                child: TextButton(
                  onPressed: (){
                  /*
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListSelector(Text(AppLocalizations.of(context)!.ca_t3, style: Theme.of(context).textTheme.displaySmall), widget.parent.l, Environment.instance.collection.effects)),
                    ).then((value) {
                      setState(() {
                        if(value != null) {
                          widget._effect.title = value;
                        }
                      });
                    });
                  });
                  */
                }, child: Text(name)),
              ),
              if(widget._effect.title != null)
                Row(
                    children: [
                      Text(AppLocalizations.of(context)!.ca_b21),
                      Expanded(
                        child: SpinBox(value: widget._effect.power.toDouble(), max: 300,
                          onChanged: (value){
                            setState(() {
                              widget._effect.power = value.toInt();
                            });
                          }),
                      )
                    ]
                ),
              if(widget._effect.title != null)
                Row( children: [
                  WidgetEnergyButton(WidgetEnergyButtonEffectController(widget._effect, 0)),
                  WidgetEnergyButton(WidgetEnergyButtonEffectController(widget._effect, 1)),
                  WidgetEnergyButton(WidgetEnergyButtonEffectController(widget._effect, 2)),
                  WidgetEnergyButton(WidgetEnergyButtonEffectController(widget._effect, 3)),
                  WidgetEnergyButton(WidgetEnergyButtonEffectController(widget._effect, 4)),
                ]),
              //Description
              Card(
                color: Colors.grey[600],
                child: TextButton(onPressed: (){
                  /*
                  setState(() {
                    Map finalEffectList = {};
                    for(var effect in Environment.instance.collection.descriptions.entries) {
                      WidgetSelectorNameList
                      var d = CardDescription(effect.key);
                      finalEffectList[effect.key] = MultiLanguageString(
                          [
                            d.decrypted(Environment.instance.collection.descriptions, Environment.instance.collection.languages[1]!).finalString.join(),
                            d.decrypted(Environment.instance.collection.descriptions, Environment.instance.collection.languages[2]!).finalString.join(),
                            d.decrypted(Environment.instance.collection.descriptions, Environment.instance.collection.languages[3]!).finalString.join(),
                          ]);
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListSelector(Text(AppLocalizations.of(context)!.ca_t4, style: Theme.of(context).textTheme.displaySmall), widget.parent.l, finalEffectList)),
                    ).then((value) {
                      setState(() {
                        if(value != null) {
                          if(widget._effect.description == null) {
                            widget._effect.description = PokeCardDescription(value);
                          }
                          else {
                            widget._effect.description!.idDescription = value;
                          }
                        }
                      });
                    });
                  });
                  */
                }, child: Text(description, softWrap: true)),
              ),
            ] + parameterWidgets
        )
    );
  }
}