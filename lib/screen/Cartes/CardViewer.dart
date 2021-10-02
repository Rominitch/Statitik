import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/environment.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardViewer extends StatelessWidget {
  final SubExtension se;
  final int id;
  final PokemonCardExtension card;
  const CardViewer(this.se, this.id, this.card, {Key? key}) : super(key: key);

  static const double maxHP      = 340.0;
  static const double maxRetreat = 5.0;

  static const double labelSpace = 100;
  static const double valueSpace = 70;
  static const double lineHeight = 10.0;

  @override
  Widget build(BuildContext context) {
    String cardImage = "";
    if(Environment.instance.showTCGImages){
      if( se.extension.language.id == 1 )
        cardImage = "https://assets.pokemon.com/assets/cms2-fr-fr/img/cards/web/${se.icon}/${se.icon}_FR_${se.seCards.tcgImage(id)}.png";
      else if( se.extension.language.id == 2 )
        cardImage = "https://assets.pokemon.com/assets/cms2/img/cards/web/${se.icon}/${se.icon}_EN_${se.seCards.tcgImage(id)}.png";
      else if( card.data.jpImage.isNotEmpty )
        cardImage = "https://www.pokemon-card.com/assets/images/card_images/large/${se.icon}/${card.data.jpImage}.jpg";
    }

    List<Widget> effectsWidgets = [];
    card.data.cardEffects.effects.forEach((effect) {
      effectsWidgets.add(EffectViewer(effect, se.extension.language));
    });

    List<Widget> findCard = [];
    Environment.instance.collection.searchCardIntoSubExtension(card.data).forEach((result) {
      findCard.add(Card(
        color: Colors.grey[800],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            result.se.image(wSize: 30.0, hSize: 30.0),
            Text(result.se.seCards.numberOfCard(result.position), textAlign: TextAlign.center)
          ]
        )
      ));
    });

    return Scaffold(
        appBar: AppBar(
          title: Row(
           children:[
             Expanded(child: Text(se.seCards.titleOfCard(se.extension.language, id), style: Theme.of(context).textTheme.headline5)),
             getImageType(card.data.type),
             if(card.data.typeExtended != null) getImageType(card.data.typeExtended!),
             if(card.rarity != Rarity.Unknown)  Row(children: getImageRarity(card.rarity)),
           ]
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if(cardImage.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: cardImage,
                  errorWidget: (context, url, error) {
                      return Icon(Icons.help_outline);
                  },
                  placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
                  height: 400,
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(child: Text(StatitikLocale.of(context).read('CAVIEW_B4'), style: Theme.of(context).textTheme.headline5)),
                        Card(
                          color: Colors.grey[800],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(getLevelText(context, card.data.level)),
                          ),
                        )
                      ]),
                      if( isPokemonType(card.data.type) )
                      Row(children: [
                        Container(width: labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B0'))),
                        Container(width: valueSpace, child: Text(card.data.life.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                        SizedBox(width: 10.0),
                        Expanded(child: LinearPercentIndicator(
                          lineHeight: lineHeight,
                          percent: (card.data.life.toDouble() / maxHP).clamp(0.0, 1.0),
                          progressColor: Colors.red,
                        )),
                      ]),
                      if( isPokemonType(card.data.type) )
                      Row(children: [
                        Container(width: labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B1'))),
                        Container(width: valueSpace, child: Text(card.data.retreat.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                        SizedBox(width: 10.0),
                        Expanded(child: LinearPercentIndicator(
                          lineHeight: lineHeight,
                          percent: (card.data.retreat.toDouble() / maxRetreat).clamp(0.0, 1.0),
                          progressColor: Colors.white,
                        )),
                      ]),
                      if( card.data.resistance != null && card.data.resistance!.energy != Type.Unknown )
                        Row(children: [
                          Container(width: labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B2'))),
                          Container(width: valueSpace, child: Text(card.data.resistance!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                          SizedBox(width: 10.0),
                          energyImage(card.data.resistance!.energy),
                          Expanded(child: SizedBox()),
                        ]),
                      if( card.data.weakness != null && card.data.weakness!.energy != Type.Unknown )
                        Row(children: [
                          Container(width: labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B3'))),
                          Container(width: valueSpace, child: Text(card.data.weakness!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                          SizedBox(width: 10.0),
                          energyImage(card.data.weakness!.energy),
                          Expanded(child: SizedBox()),
                        ]),
                    ]
                  ),
                )
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(StatitikLocale.of(context).read('CAVIEW_B5'), style: Theme.of(context).textTheme.headline5),
                    ] + effectsWidgets
                  )
                )
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(StatitikLocale.of(context).read('CAVIEW_B6'), style: Theme.of(context).textTheme.headline5),
                      GridView.count(
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        primary: false,
                        children: findCard,
                      )
                    ]
                  )
                )
              ),
            ]
          )
        )
      )
    );
  }
}

class EffectViewer extends StatelessWidget {
  final Language   l;
  final CardEffect effect;
  const EffectViewer(this.effect, this.l,  {Key? key}) : super(key: key);

  static const double valueSpace = 40.0;

  @override
  Widget build(BuildContext context) {
    Widget? attackPanel;
    Widget? descriptionPanel;
    if(effect.title != null) {
      List<Widget> attackType = [];
      effect.attack.forEach((type) {
        if(type != Type.Unknown) {
          attackType.add(energyImage(type));
        }
      });

      attackPanel = Row(
        children: <Widget>[
          Text(Environment.instance.collection.effects[effect.title!].name(l), style: Theme.of(context).textTheme.headline5,),
          if(attackType.isNotEmpty)
            Expanded(child: Row( children: attackType)),
          if(attackType.isNotEmpty)
            Container(width: valueSpace, child: Text(effect.power.toString())),
        ],
      );
    }
    if(effect.description != null) {
      descriptionPanel = effect.description!.toWidget(Environment.instance.collection.descriptions, l);
    }

    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(attackPanel != null) attackPanel,
            if(descriptionPanel != null) descriptionPanel,
          ],
        ),
      )
    );
  }
}

