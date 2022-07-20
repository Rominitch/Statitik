import 'dart:math';

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

class CardViewerIdentifier {
  final SubExtension        se;
  final CardIdentifier      idCard;
  final CardImageIdentifier idImage;

  CardViewerIdentifier(this.se, this.idCard, this.idImage);
}

class CardViewerBody extends StatefulWidget {
  final SubExtension          se;
  final CardIdentifier        idCard;
  final PokemonCardExtension  card;
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
  State<CardViewerBody> createState() => _CardViewerBodyState();
}

class _CardViewerBodyState extends State<CardViewerBody> with TickerProviderStateMixin {
  Map<Language, List<CardViewerIdentifier>> allDesigns = {};
  List<Widget> findCard = [];
  late TabController languageController;
  late TabController pageController;

  @override
  void initState() {
    Environment.instance.collection.searchCardIntoSubExtension(widget.card.data).forEach((result) {
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
              Text(result.se.seCards.numberOfCard(result.idCard.numberId), style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, softWrap: true)
            ]
          )
        )
      ));
    });
    Environment.instance.collection.searchCardIntoSubExtension(widget.card.data, true).forEach((result) {
      var language = result.se.extension.language;
      // Add language
      if(!allDesigns.containsKey(language)) {
        allDesigns[language] = [];
      }
      var idSet=0;
      result.card.images.forEach((imagePerSet) {
        var idImage = 0;
        imagePerSet.forEach((element) {
          allDesigns[language]!.add(CardViewerIdentifier(result.se, result.idCard, CardImageIdentifier(idSet, idImage)));
          idImage += 1;
        });
        idSet+=1;
      });
    });

    var index = allDesigns.keys.toList(growable: false).indexOf(widget.se.extension.language);
    languageController = TabController(initialIndex: index, length: allDesigns.length, vsync: this);
    pageController     = TabController(initialIndex: 0, length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> effectsWidgets = [];
    widget.card.data.cardEffects.effects.forEach((effect) {
      effectsWidgets.add(EffectViewer(effect, widget.se.extension.language));
    });

    List<Widget> imageTabHeaders = [];
    List<Widget> imageTabPages   = [];

    allDesigns.forEach((language, identifiers) {
      imageTabHeaders.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: language.barIcon(),
      ));
      imageTabPages.add(CardImageViewer(identifiers, widget.se, widget.idCard));
    });

    List<Widget> tabHeaders = [
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(StatitikLocale.of(context).read('CAVIEW_B11')),
      ),
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(StatitikLocale.of(context).read('CAVIEW_B12')),
      ),
    ];
    List<Widget> tabPages   = [
      Column(
        children: [
          TabBar(
            controller: languageController,
            indicatorPadding: const EdgeInsets.all(1),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
            tabs: imageTabHeaders
          ),
          Expanded(
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: languageController,
                children: imageTabPages
            ),
          ),
        ]
      ),
      SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                            child: Text(getLevelText(context, widget.card.data.level)),
                          ),
                        )
                      ]),
                      if( isPokemonType(widget.card.data.type) )
                        Row(children: [
                          SizedBox(width: CardViewerBody.labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B0'))),
                          SizedBox(width: CardViewerBody.valueSpace, child: Text(widget.card.data.life.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                          const SizedBox(width: 10.0),
                          Expanded(child: LinearPercentIndicator(
                            lineHeight: CardViewerBody.lineHeight,
                            percent: (widget.card.data.life.toDouble() / CardViewerBody.maxHP).clamp(0.0, 1.0),
                            progressColor: Colors.red,
                          )),
                        ]),
                      if( isPokemonType(widget.card.data.type) )
                        Row(children: [
                          SizedBox(width: CardViewerBody.labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B1'))),
                          SizedBox(width: CardViewerBody.valueSpace, child: Text(widget.card.data.retreat.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                          const SizedBox(width: 10.0),
                          Expanded(child: LinearPercentIndicator(
                            lineHeight: CardViewerBody.lineHeight,
                            percent: (widget.card.data.retreat.toDouble() / CardViewerBody.maxRetreat).clamp(0.0, 1.0),
                            progressColor: Colors.white,
                          )),
                        ]),
                      if( widget.card.data.resistance != null && widget.card.data.resistance!.energy != TypeCard.Unknown )
                        Row(children: [
                          SizedBox(width: CardViewerBody.labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B2'))),
                          SizedBox(width: CardViewerBody.valueSpace, child: Text(widget.card.data.resistance!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                          const SizedBox(width: 10.0),
                          energyImage(widget.card.data.resistance!.energy),
                          const Expanded(child: SizedBox()),
                        ]),
                      if( widget.card.data.weakness != null && widget.card.data.weakness!.energy != TypeCard.Unknown )
                        Row(children: [
                          SizedBox(width: CardViewerBody.labelSpace, child: Text(StatitikLocale.of(context).read('CAVIEW_B3'))),
                          SizedBox(width: CardViewerBody.valueSpace, child: Text(widget.card.data.weakness!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headline5 )),
                          const SizedBox(width: 10.0),
                          energyImage(widget.card.data.weakness!.energy),
                          const Expanded(child: SizedBox()),
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
      )
    ];

    return Column(
      children: [
        TabBar(
          controller: pageController,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          tabs: tabHeaders
        ),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: tabPages
          ),
        ),
      ]
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
          const SizedBox(width: 5),
          if(attackType.isNotEmpty)
            Expanded(child: Row( children: attackType)),
          if(attackType.isNotEmpty)
            SizedBox(width: valueSpace, child: Text(effect.power.toString())),
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
                  const SizedBox(width: 5),
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

  const CardViewer(this.se, this.id, this.card, {Key? key}) : super(key: key);

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

  const CardSEViewer(this.se, this.idCard, {Key? key}) : super(key: key);

  @override
  State<CardSEViewer> createState() => _CardSEViewerState();
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

class CardImageViewer extends StatefulWidget {
  final SubExtension   selectSE;
  final CardIdentifier selectIdCard;
  final List<CardViewerIdentifier> ids;
  const CardImageViewer(this.ids, this.selectSE, this.selectIdCard, {Key? key}) : super(key: key);

  @override
  State<CardImageViewer> createState() => _CardImageViewerState();
}

class _CardImageViewerState extends State<CardImageViewer> with TickerProviderStateMixin {
  late TabController imagesController;

  @override
  void initState() {
    var index = max(0, widget.ids.indexWhere((element) => element.se == widget.selectSE && element.idCard.compareTo(widget.selectIdCard)==0));
    imagesController = TabController(length: widget.ids.length, initialIndex: index,
      vsync: this,
      animationDuration: Duration.zero
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> imageTabHeaders = [];
    List<Widget> imageTabPages   = [];
    widget.ids.forEach((image) {
      var card = image.se.cardFromId(image.idCard);
      imageTabHeaders.add(
        Row(
          children: [
            image.se.image(wSize: 40, hSize: 40),
            const SizedBox(width: 2),
            card.tryGetImage(image.idImage).cardDesign.iconFullDesign(height: 26)
          ]
        )
      );
      imageTabPages.add(
        genericCardWidget(image.se, image.idCard, image.idImage, quality: FilterQuality.high, reloader: true,
          fit: BoxFit.fitWidth
        )
      );
    });

    return Column(
      children: [
        TabBar(
          controller: imagesController,
          indicatorPadding: const EdgeInsets.all(1),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          tabs: imageTabHeaders,
          isScrollable: true,
        ),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: imagesController,
            children: imageTabPages
          ),
        ),
      ]
    );
  }
}

