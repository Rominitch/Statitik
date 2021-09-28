import 'package:flutter/material.dart';
import 'package:statitikcard/services/CardEffect.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardViewer extends StatelessWidget {
  final SubExtension se;
  final int id;
  final PokemonCardExtension card;
  const CardViewer(this.se, this.id, this.card, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(se.seCards.titleOfCard(se.extension.language, id), style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          //child:
        )
      )
    );
  }
}

class EffectViewer extends StatelessWidget {
  final CardEffect effect;
  const EffectViewer(this.effect, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

