import 'package:flutter/material.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';

class CardViewerBody extends StatelessWidget {
  final SubExtension se;
  final CardIdentifier idCard;
  final PokemonCardExtension card;
  const CardViewerBody(this.se, this.idCard, this.card, {Key? key}) : super(key: key);

  static const double maxHP      = 340.0;
  static const double maxRetreat = 5.0;

  static const double labelSpace = 100;
  static const double valueSpace = 70;
  static const double lineHeight = 10.0;

  Widget buildHeader(BuildContext context) {
    return Row(
        children:[
          Expanded(child: Text(se.seCards.titleOfCard(se.extension.language, idCard.numberId), style: Theme.of(context).textTheme.headline5)),
          getImageType(card.data.type),
          if(card.data.typeExtended != null) getImageType(card.data.typeExtended!),
          if(card.rarity != Environment.instance.collection.unknownRarity)  Row(children: getImageRarity(card.rarity, se.extension.language)),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> effectsWidgets = [];
    card.data.cardEffects.effects.forEach((effect) {
      effectsWidgets.add(EffectViewer(effect, se.extension.language));
    });

    List<Widget> languageCards = [];
    Environment.instance.collection.subExtensions.forEach((key, parseSe) {
      if(se.seCards == parseSe.seCards) {
        languageCards.add(Card(
          color: Colors.grey[800],
          child: se == parseSe ? parseSe.extension.language.barIcon()
            : TextButton(
            onPressed: (){
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CardViewer(parseSe, idCard, parseSe.cardFromId(idCard)))
              );
            },
            child: parseSe.extension.language.barIcon()
          )
        ));
      }
    });

    List<Widget> findCard = [];
    Environment.instance.collection.searchCardIntoSubExtension(card.data).forEach((result) {
      findCard.add(Card(
        color: Colors.grey[800],
        child: TextButton(
          onPressed: (){
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CardViewer(result.se, result.idCard, result.card)),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              result.se.image(wSize: 25.0, hSize: 25.0),
              Text(result.se.seCards.numberOfCard(result.idCard.numberId), style: TextStyle(fontSize: 11), textAlign: TextAlign.center, softWrap: true)
            ]
          )
        )
      ));
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 50,
            child: ListView(
              children: languageCards,
              primary: false,
              shrinkWrap: false,
              scrollDirection: Axis.horizontal,
            ),
          ),
          genericCardWidget(se, idCard, CardImageIdentifier(), quality: FilterQuality.high, width: MediaQuery.of(context).size.width-16, reloader: true),
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
                  if( card.data.resistance != null && card.data.resistance!.energy != TypeCard.Unknown )
                    Row(children: [
                      Container(width: labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B2'))),
                      Container(width: valueSpace, child: Text(card.data.resistance!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                      SizedBox(width: 10.0),
                      energyImage(card.data.resistance!.energy),
                      Expanded(child: SizedBox()),
                    ]),
                  if( card.data.weakness != null && card.data.weakness!.energy != TypeCard.Unknown )
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
                    crossAxisCount: 4,
                    childAspectRatio: 1.2,
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
        if(type != TypeCard.Unknown) {
          attackType.add(energyImage(type));
        }
      });

      attackPanel = Row(
        children: <Widget>[
          Text(Environment.instance.collection.effects[effect.title!].name(l), style: Theme.of(context).textTheme.headline5,),
          SizedBox(width: 5),
          if(attackType.isNotEmpty)
            Expanded(child: Row( children: attackType)),
          if(attackType.isNotEmpty)
            Container(width: valueSpace, child: Text(effect.power.toString())),
        ],
      );
    }
    List<Widget> descriptionMarkerWidgets = [];
    if(effect.description != null) {
      descriptionPanel = effect.description!.toWidget(Environment.instance.collection.descriptions, Environment.instance.collection.pokemons, l);
      effect.description!.effects.forEach((element) {
        descriptionMarkerWidgets.add(
            Tooltip(message: labelDescriptionEffect(context, element),
                    child: getDescriptionEffectWidget(element)
            )
        );
      });
    }

    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(attackPanel != null) attackPanel,
            if(descriptionPanel != null)
              Row(
                children: [
                  Column(children: descriptionMarkerWidgets),
                  SizedBox(width: 5),
                  Expanded(child: descriptionPanel),
                ],
              ),
          ],
        ),
      )
    );
  }
}

class CardViewer extends StatelessWidget {
  final SubExtension   se;
  final CardIdentifier id;
  final PokemonCardExtension card;
  const CardViewer(this.se, this.id, this.card);

  @override
  Widget build(BuildContext context) {
    CardViewerBody body = CardViewerBody(se, id, card);
    return Scaffold(
      appBar: AppBar(
        title: body.buildHeader(context)
      ),
      body: SafeArea(
        child: body
      )
    );
  }
}

class CardSEViewer extends StatefulWidget {
  final SubExtension se;
  final CardIdentifier idCard;

  const CardSEViewer(this.se, this.idCard);

  @override
  _CardSEViewerState createState() => _CardSEViewerState();
}

class _CardSEViewerState extends State<CardSEViewer> {
  late PageController _pageController;
  CardViewerBody? viewer;
  late CardIdentifier idCurrentCard;

  @override
  void initState() {
    idCurrentCard = widget.idCard;
    _pageController = PageController(keepPage: false, initialPage: idCurrentCard.numberId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(viewer == null) {
      var card = widget.se.cardFromId(idCurrentCard);
      viewer = CardViewerBody(widget.se, idCurrentCard, card);
    }

    return Scaffold(
      appBar: AppBar(
        title: viewer!.buildHeader(context)
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.se.seCards.cardList(idCurrentCard).length,
        pageSnapping: true,
        onPageChanged: (position) {
          setState(() {
            viewer = CardViewerBody(widget.se, idCurrentCard, widget.se.cardFromId(idCurrentCard.changeNumber(position)));
          });
        },
        itemBuilder: (context, position) {
          var newIdCard = idCurrentCard.changeNumber(position);
          viewer = CardViewerBody(widget.se, newIdCard, widget.se.cardFromId(newIdCard));
          return viewer!;
        }
      )
    );
  }
}
