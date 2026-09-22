import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card_effect.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_rendering.dart';

import 'package:statitikcard/widgets/widget/widget_creator_card_effect.dart';

class WidgetCreatorCardEffects extends StatefulWidget {
  final PokeNavAdmin             _navAdmin;
  final PokeCardViewerIdentifier _cvId;

  const WidgetCreatorCardEffects(this._navAdmin, this._cvId, {super.key});

  @override
  State<WidgetCreatorCardEffects> createState() => _WidgetCreatorCardEffectsState();
}

class _WidgetCreatorCardEffectsState extends State<WidgetCreatorCardEffects> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(width: PokeRendering.spacing),
        itemCount: widget._cvId.cardInExp().card.cardEffects.effects.length + 1,
        itemBuilder: (context, index) {
          if( index < widget._cvId.cardInExp().card.cardEffects.effects.length) {
            return WidgetCreatorCardEffect(widget._navAdmin, widget._cvId.cardInExp().card.cardEffects.effects[index]);
          } else {
            return Card(
              color: Colors.greenAccent,
              child: TextButton(
                child: Text( AppLocalizations.of(context)!.ca_b14 ),
                onPressed: (){
                  /*
                  setState(() {
                    final newEffect = PokeCardEffect(null, null, 0, []);
                    widget._cvId.cardInExp().card.cardEffects.effects.add(newEffect);
                  });
                  */
                }
              )
            );
          }
        },
    );
  }
}

