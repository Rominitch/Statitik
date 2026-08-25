import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/models/poke_level.dart';
import 'package:statitikcard/screens/card/card_images_list.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/type_card.dart';

import 'card_viewer.dart';
class CardBody extends StatefulWidget {
  final PokeCardViewerIdentifier cvId;
  //final PokeLangage         language;
  //final PokeExpansion       expansion;
  //final PokeCardIdentifier  idCard;
  //final PokeCardInExpansion cardInExpansion;
  const CardBody(this.cvId, {super.key});

  static const double maxHP      = 340.0;
  static const double maxRetreat = 5.0;

  static const double labelSpace = 100;
  static const double valueSpace = 70;
  static const double lineHeight = 10.0;

  Widget buildHeader(BuildContext context) {
    final cardInExpansion = cvId.cardInExp();
    return Row(
        children:[
          Expanded(child: Text(cvId.readTitleOfCard(), style: Theme.of(context).textTheme.headlineSmall)),
          getImageType(cardInExpansion.card.type),
          if(cardInExpansion.card.typeExtended != null) getImageType(cardInExpansion.card.typeExtended!),
          if(cardInExpansion.rarity != Environment.instance.pkCollection().unknownRarity())  Row(children: Environment.instance.pkRendering().imageRarity(cardInExpansion.rarity)),
        ]
    );
  }

  @override
  State<CardBody> createState() => _CardBodyState();
}

class _CardBodyState extends State<CardBody> with TickerProviderStateMixin {
  Map<PokeLangage, List<PokeCardViewerIdentifier>> allDesigns = {};
  List<Widget> findCard = [];
  late TabController languageController;
  late TabController pageController;

  @override
  void initState() {
    final collection = Environment.instance.pkCollection();
    final data = widget.cvId.cardInExp().card;
    collection.searchCardIntoSubExtension(data).forEach((result) {
      findCard.add(Card(
          color: Colors.grey[800],
          child: TextButton(
              onPressed: (){
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => CardViewer.from(result)),
                );
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    result.expansion.image(result.specificLanguage!, wSize: 25.0, hSize: 25.0),
                    Text(result.expansion.cards.numberOfCard(result.idCard.numberId), style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, softWrap: true)
                  ]
              )
          )
      ));
    });
    collection.searchCardIntoSubExtension(data, true).forEach((PokeCardViewerIdentifier result) {
      final card = result.cardInExp();
      for(final language in result.compatibleLanguage()) {
        // Add language
        if(!allDesigns.containsKey(language)) {
          allDesigns[language] = [];
        }
        result.cardInExp().setInfo.forEach( (set, images) {
          for (int idImage=0; idImage < images.length; idImage +=1) {
            allDesigns[language]!.add(PokeCardViewerIdentifier(
                result.expansion, result.idCard,
                specificLanguage: language,
                idImage: PokeCardImageIdentifier(set, idImage)));
          }
        });
      }
    });

    var index = allDesigns.keys.toList(growable: false).indexOf(widget.cvId.specificLanguage!);
    languageController = TabController(initialIndex: index, length: allDesigns.length, vsync: this);
    pageController     = TabController(initialIndex: 0, length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.cvId.cardInExp().card;
    List<Widget> effectsWidgets = [];
    //for (var effect in data.cardEffects.effects) {
    //  effectsWidgets.add(EffectViewer(effect, widget.cvId.specificLanguage!));
    //}

    List<Widget> imageTabHeaders = [];
    List<Widget> imageTabPages   = [];

    allDesigns.forEach((language, identifiers) {
      imageTabHeaders.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: language.barIcon(),
      ));
      imageTabPages.add(CardImagesList(identifiers, widget.cvId));
    });

    List<Widget> tabHeaders = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
        child: Text(AppLocalizations.of(context)!.caview_b11),

      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
        child: Text(AppLocalizations.of(context)!.caview_b12),
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
                              Expanded(child: Text(AppLocalizations.of(context)!.caview_b4, style: Theme.of(context).textTheme.headlineSmall)),
                              Card(
                                color: Colors.grey[800],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(PokeLevel.getLevelText(context, data.level)),
                                ),
                              )
                            ]),
                            if( isPokemonType(data.type) )
                              Row(children: [
                                SizedBox(width: CardBody.labelSpace, child: Text(AppLocalizations.of(context)!.caview_b0)),
                                SizedBox(width: CardBody.valueSpace, child: Text(data.life.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headlineSmall )),
                                const SizedBox(width: 10.0),
                                Expanded(child: LinearPercentIndicator(
                                  lineHeight: CardBody.lineHeight,
                                  percent: (data.life.toDouble() / CardBody.maxHP).clamp(0.0, 1.0),
                                  progressColor: Colors.red,
                                )),
                              ]),
                            if( isPokemonType(data.type) )
                              Row(children: [
                                SizedBox(width: CardBody.labelSpace, child: Text(AppLocalizations.of(context)!.caview_b1)),
                                SizedBox(width: CardBody.valueSpace, child: Text(data.retreat.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headlineSmall )),
                                const SizedBox(width: 10.0),
                                Expanded(child: LinearPercentIndicator(
                                  lineHeight: CardBody.lineHeight,
                                  percent: (data.retreat.toDouble() / CardBody.maxRetreat).clamp(0.0, 1.0),
                                  progressColor: Colors.white,
                                )),
                              ]),
                            if( data.resistance != null && data.resistance!.energy != TypeCard.unknown )
                              Row(children: [
                                SizedBox(width: CardBody.labelSpace, child: Text(AppLocalizations.of(context)!.caview_b2)),
                                SizedBox(width: CardBody.valueSpace, child: Text(data.resistance!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headlineSmall )),
                                const SizedBox(width: 10.0),
                                energyImage(data.resistance!.energy),
                                const Expanded(child: SizedBox()),
                              ]),
                            if( data.weakness != null && data.weakness!.energy != TypeCard.unknown )
                              Row(children: [
                                SizedBox(width: CardBody.labelSpace, child: Text(AppLocalizations.of(context)!.caview_b3)),
                                SizedBox(width: CardBody.valueSpace, child: Text(data.weakness!.value.toString(), textAlign: TextAlign.right, style: Theme.of(context).textTheme.headlineSmall )),
                                const SizedBox(width: 10.0),
                                energyImage(data.weakness!.energy),
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
                              Text(AppLocalizations.of(context)!.caview_b5, style: Theme.of(context).textTheme.headlineSmall),
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
                              Text(AppLocalizations.of(context)!.caview_b6, style: Theme.of(context).textTheme.headlineSmall),
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