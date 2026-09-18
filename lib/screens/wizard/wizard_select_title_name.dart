
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/widgets/widget/widget_selector_name_list.dart';

class WizardSelectTitleName extends StatefulWidget {
  final PokeNavAdmin _navAdmin;
  final bool isPokemon;

  const WizardSelectTitleName(this._navAdmin, this.isPokemon, {super.key});

  @override
  State<WizardSelectTitleName> createState() => _WizardSelectTitleNameState();

  static void select(BuildContext context, PokeNavAdmin navAdmin, bool isPokemon, Function(CardTitle selectedTitle) afterSelectName) {
    if(isMobile) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
          WizardSelectTitleName( navAdmin, isPokemon)),
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
                child: WizardSelectTitleName( navAdmin, isPokemon))
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
    if( widget.isPokemon ) {
      return WidgetSelectorNameList(widget._navAdmin, widget._navAdmin.collection.pokemons(), multiLangue: true);
    } else {
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
    }
  }
}
