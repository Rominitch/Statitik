
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/widgets/widget/widget_selector_name_list.dart';

enum ListInfo {
  Pokemon,
  Trainer,
  Effect,
  EffectDescription
}

class WizardSelectTitleName extends StatefulWidget {
  final PokeNavAdmin _navAdmin;
  final ListInfo     _kindList;

  const WizardSelectTitleName(this._navAdmin, this._kindList, {super.key});

  @override
  State<WizardSelectTitleName> createState() => _WizardSelectTitleNameState();

  static void select(BuildContext context, PokeNavAdmin navAdmin, ListInfo kindList, Function(dynamic selectedTitle) afterSelectName) {
    if(isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
          WizardSelectTitleName( navAdmin, kindList)),
      ).then((idDB) {
        afterSelectName( idDB );
      });
    } else {
      showDialog(context: context, builder:
        (BuildContext context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(8.0),
            insetPadding: const EdgeInsets.symmetric(horizontal: 0),
            children: [
              SizedBox(
                width: min(MediaQuery.of(context).size.width-50, 500),
                height: MediaQuery.of(context).size.height-50,
                child: WizardSelectTitleName( navAdmin, kindList ))
            ]
          );
        }
      ).then((idDB) {
        afterSelectName( idDB );
      });
    }
  }
}

class _WizardSelectTitleNameState extends State<WizardSelectTitleName> {
  @override
  Widget build(BuildContext context) {
    switch( widget._kindList ) {
      case ListInfo.Pokemon :
        return WidgetSelectorNameList(widget._navAdmin, widget._navAdmin.collection.pokemons(), multiLangue: true);
      case ListInfo.Trainer :
        return WidgetSelectorNameList(widget._navAdmin, widget._navAdmin.collection.otherCards(), multiLangue:true,
          addNewData: (String newText, PokeLanguage langue) async {
            PokeIdentifier? newId;
            await widget._navAdmin.database.transactionR( (connection) async
              {
                newId = await widget._navAdmin.collection.addNewDresseurObjectName(connection, newText, langue);
                return true;
              }
            );
            return newId;
          }
        );
      case ListInfo.Effect :
        return WidgetSelectorNameList(widget._navAdmin, widget._navAdmin.collection.effectNames());
      case ListInfo.EffectDescription :
        return WidgetSelectorNameList(widget._navAdmin, widget._navAdmin.collection.descriptions());
    }
  }
}
