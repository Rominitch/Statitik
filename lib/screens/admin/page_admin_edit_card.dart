import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/admin_html_card_parser.dart';
import 'package:statitikcard/models/card/poke_card.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/card/poke_card_energy_value.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_level.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/screenOld/widgets/button_check.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/screens/wizard/wizard_select_title_name.dart';
import 'package:statitikcard/widgets/widget/widget_card_naming.dart';
import 'package:statitikcard/widgets/widget/widget_energy_slider.dart';
import 'package:statitikcard/widgets/widget/widget_slider_info.dart';

class PageAdminEditCard extends StatefulWidget {
  final PokeNavAdmin             _navAdmin;
  final PokeCardViewerIdentifier _activeCard;
  final CardEditorOptions        _options;

  // Computed
  final List<PokeRarity> listRarity;

  PageAdminEditCard(this._navAdmin, this._activeCard, this._options, {super.key}):
    listRarity = (_activeCard.expansion.location() == CardLocation.Monde ? _navAdmin.collection.worldRarity() : _navAdmin.collection.japanRarity());

  @override
  State<PageAdminEditCard> createState() => _PageAdminEditCardState();
}

/*
class CardCreator extends StatefulWidget {
  final LanguageOld              activeLanguage;
  final bool                  editor;
  final SubExtension          se;
  final PokemonCardExtension  card;
  final CardIdentifier        idCard;
  final Function(int listId, int?)?   onAppendCard;
  final Function(int listId)?         onChangeList;
  final Function()?                   onNeedRefresh;
  final List                  listRarity;
  final String                title;
  final List?                 secondTypes;
  final CardEditorOptions     options;

  CardCreator.editor(this.activeLanguage, this.se, this.card, this.idCard, this.title, this.options, {super.key}):
        editor=true, onAppendCard=null, onChangeList=null, onNeedRefresh=null,
        listRarity = (se.extension.language.isWorld() ? Environment.instance.collection.worldRarity : Environment.instance.collection.japanRarity)
          ..removeWhere((element) => element == Environment.instance.collection.unknownRarity),
        secondTypes = [TypeCard.unknown] + energies;

  CardCreator.quick(this.activeLanguage, this.se, this.card, this.idCard, this.onAppendCard, this.onNeedRefresh, bool isWorldCard, {super.key, this.onChangeList}):
        editor=false, listRarity = (isWorldCard ? Environment.instance.collection.worldRarity : Environment.instance.collection.japanRarity), title="",
        secondTypes=null, options = CardEditorOptions();

  @override
  State<CardCreator> createState() => _CardCreatorState();
}
*/

class _PageAdminEditCardState extends State<PageAdminEditCard> with TickerProviderStateMixin {

  late CustomRadioController typeController      = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController    = CustomRadioController(onChange: (value) { onRarityChanged(value); });
  late CustomRadioController typeExtController   = CustomRadioController(onChange: (value) { onTypeExtChanged(value); });
  late CustomRadioController levelController     = CustomRadioController(onChange: (value) { onLevel(value); });
  late CustomButtonCheckController setController = CustomButtonCheckController(onChangeSets);
  late TabController         tabController;

  final secondTypes = [PokeCardType.unknown] + energies;
  final specialIDController = TextEditingController();

  void onChangeSets() {
    setState(() {
      final card = widget._activeCard.cardInExp();
      /*
      if( card.sets.isNotEmpty ) {
        while(widget.card.images.length < widget.card.sets.length) {
          widget.card.images.add([]);
        }
        while(widget.card.images.length > widget.card.sets.length) {
          widget.card.images.removeLast();
        }
      }
      */
    });
  }

  void onTypeChanged(PokeCardType value) {
    widget._activeCard.cardInExp().card.type = value;
  }
  void onLevel(PokeLevel value) {
    widget._activeCard.cardInExp().card.level = value;
  }
  void onTypeExtChanged(PokeCardType value) {
    widget._activeCard.cardInExp().card.typeExtended
      = value == PokeCardType.unknown
        ? null : value;
  }

  void onRarityChanged(PokeRarity value) {
    widget._activeCard.cardInExp().rarity = value;
  }

  @override
  void initState() {
    tabController = TabController( length: 6, vsync: this, initialIndex: widget._options.tabIndex );
    tabController.addListener(() {
      widget._options.tabIndex = tabController.index;
    });

    // Auto fill (only for japanese card)
    if( widget._navAdmin.showLanguage.location() == CardLocation.Asie ) {
      final sets = widget._activeCard.cardInExp().setInfo;
      for(final set in sets.entries) {
        int idImage = 0;
        for(final image in set.value) {
          if(image.jpDBId == 0) {
            final id = widget._activeCard;
            id.idImage = PokeCardImageIdentifier(set.key, idImage);
            //TODO
            //CardImageCreator.computeJPCardID(id);
          }
          idImage += 1;
        }
      }
    }

    selectCard();

    super.initState();
  }

  void selectCard() {
    final card = widget._activeCard.cardInExp();
    // Set current value
    typeController.afterPress(card.card.type);
    rarityController.afterPress(card.rarity);
    specialIDController.text = card.specialID;
  }
  //TODO
/*
  void addBestDesign(PokeCardIdentifier idCard, List images, int index) {
    var imageDesign = PokeCardDesign();
    // Search ancestor
    var idImage = images.length;
    for(int id=idCard.numberId-1; id >= 0; id-=1) {
      var oldId = PokeCardIdentifier.copy(idCard);
      oldId.cardId[1] = id;
      var oldCard = widget._activeCard.expansion.cards.cardFromId(oldId);
      if(index < oldCard.images.length) {
        if( idImage < oldCard.images[index].length) {
          imageDesign.cardDesign.copyFrom(oldCard.images[index][idImage].cardDesign);
          break;
        }
      }
    }
    images.add(imageDesign);
  }
*/
  Widget createImageFieldWidget() {
    const iconSize = 30.0;
    final cardInExp = widget._activeCard.cardInExp();
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: cardInExp.setInfo.length,
        itemBuilder: (BuildContext context, int index){
          final setAndImages = cardInExp.setInfo.entries.elementAt(index);
          List<Widget> images = [setAndImages.key.imageWidget(height: 50)];
          int idImg=0;
          for (final image in setAndImages.value) {
            final localIdImg = PokeCardImageIdentifier(setAndImages.key, idImg);
            images.add(Card(
                child: TextButton(
                  child: widget._navAdmin.rendering.iconFullDesign(image, height: iconSize),
                  onPressed: () {
                    // TODO
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardImageCreator(
                          widget.se, widget.card, widget.idCard, localIdImg, widget.activeLanguage, widget.options)),
                    ).then((value) {
                      setState(() {});
                    });
                    */
                  },
                  onLongPress: () {
                    setState(() {
                      cardInExp.removeImage(localIdImg);
                    });
                  },
                )
            ));
            idImg +=1;
          }

          images.add(Card(
            child: IconButton(icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    //TODO
                    //addBestDesign(widget.idCard, widget.card.images[index], index);
                  });
                }
            ),
          ));

          return Row(
              children: images
          );
        }
    );
  }

  Future<void> fillEffects([bool forceRefill=false]) async {
    double count = 0.0;

    final parser = AdminHtmlCardParser(widget._navAdmin);

    final expCards = widget._activeCard.expansion.cards;
    for(var cardsList in expCards.cards) {
      EasyLoading.showProgress(count / expCards.cards.length, status: "$count / ${expCards.cards.length}");

      for(var card in cardsList) {
        if(card.card.cardEffects.effects.isEmpty || forceRefill) {
          await parser.readEffectsJP(card);
        }
      }
      count += 1.0;
    }
    EasyLoading.dismiss();
  }

  Widget pageTitleCard() {
    final cardInExp = widget._activeCard.cardInExp();
    final cardData = cardInExp.card;

    return ListView.builder(
      itemCount: cardData.title.title.length + 1,
      itemBuilder: (context, index) {
        if(index < cardData.title.title.length) {
          return WidgetCardNaming(widget._navAdmin, widget._activeCard, index,
            (){ setState(() {}); }
          );
        } else {
          return Card(child: TextButton(
            child: Text(AppLocalizations.of(context)!.nce_b7),
            onPressed: () {
              setState(() {
                WizardSelectTitleName.select(context, widget._navAdmin, isPokemonCard(widget._activeCard.cardInExp().card.type),
                  (CardTitle selectedTitle) {
                    setState(() {
                      cardData.title.title.add(PokeFullCardPokemon(selectedTitle));
                    });
                });
              });
            },
            )
          );
        }
    });
  }

  Widget pageEffectInfo()
  {
    final cardInExp = widget._activeCard.cardInExp();
    final cardData = cardInExp.card;

    const newResistances = <int>[3, 6, 9, 12, 13, 14];
    int defaultResistance = newResistances.contains(widget._activeCard.expansion.pid().serie()) ? 30 : 20;

    return isPokemonType(cardData.type)
      ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children:
          [
            GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 2.0),
                itemCount: PokeLevel.values.length,
                primary: false,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  var element = PokeLevel.values[index];
                  return CustomRadio(value: element, controller: levelController, widget: Text( PokeLevel.getLevelText(context, element) ));
                }
            ),
            Row(children: [
              SizedBox(width: 60, child: Text(AppLocalizations.of(context)!.ca_b25, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: WidgetSliderInfo( WidgetSliderInfoController(() {
                  return cardData.life.toDouble();
                },
                  (double value){
                    cardData.life = value.round().toInt();
                  }),
                  PokeCard.minLife, PokeCard.maxLife,
                  division: 40),
              ),
            ]),
            // Retreat
            Row(children: [
              SizedBox(width: 60, child: Text(AppLocalizations.of(context)!.ca_b26, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: WidgetSliderInfo( WidgetSliderInfoController(() {
                  return cardData.retreat.toDouble();
                },
                (double value){
                  cardData.retreat = value.round().toInt();
                }),
                PokeCard.minRetreat, PokeCard.maxRetreat,
                division: 5),
              ),
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppLocalizations.of(context)!.ca_b28, style: const TextStyle(fontSize: 12)),
                WidgetEnergySlider(cardData.weakness, 2, PokeCard.minWeakness, PokeCard.maxWeakness, division: 5,
                  updateValue: (PokeEnergyValue? value){
                    cardData.weakness = value;
                  }
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppLocalizations.of(context)!.ca_b27, style: const TextStyle(fontSize: 12)),
                WidgetEnergySlider(cardData.resistance, defaultResistance, PokeCard.minResistance, PokeCard.maxResistance, division: 6,
                  updateValue: (PokeEnergyValue? value){
                    cardData.resistance = value;
                  }
                )
              ],
            )
          ]
        ),
      ) : Text("Pas de données");
  }
  Widget pageImageDesign() {
    final cardInExp = widget._activeCard.cardInExp();

    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text("Carte secrète: "),
                Checkbox(value: cardInExp.isSecret, onChanged: (value) {
                  setState(() {
                    cardInExp.isSecret = value!;
                  });
                }
                )
              ],
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 5.5),
              primary: false,
              shrinkWrap: true,
              itemCount: widget._navAdmin.collection.allSets().length,
              itemBuilder: (BuildContext context, int index) {
                var element = widget._navAdmin.collection.allSets().elementAt(index);
                //TODO
                //return CardSetButtonCheck(widget._navAdmin.showLanguage, widget.card.sets, element, controller: setController);
                return Placeholder();
              },
            ),
            Row(
                children:[
                  Text(AppLocalizations.of(context)!.ca_b38),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                        controller: specialIDController,
                        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.ca_b38 ),
                        onChanged: (data) {
                          cardInExp.specialID = data;
                        }
                    ),
                  )
                ]
            ),
            createImageFieldWidget()
          ]
      ),
    );
  }

  Widget cardTabs() {
    List<Widget> tabPages = [
      // Page 1
      pageTitleCard(),
      // Page 2
      pageEffectInfo(),
      // Page 3
      pageImageDesign(),
      // Page 4
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 2.5),
        itemCount: widget._navAdmin.collection.markers().length,
        itemBuilder: (BuildContext context, int index) {
          var element = widget._navAdmin.collection.markers().elementAt(index);
          return Placeholder();
          //return MarkerButtonCheck(widget._navAdmin.showLanguage, cardData.markers, element, null);
        }
      ),
      //TODO
      /*
      SingleChildScrollView(
          child: CardEffectsPanel(widget.card, widget.activeLanguage)
      ),
      */
      Column( children: [
        GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.3),
            itemCount: widget.listRarity.length,
            primary: false,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var element = widget.listRarity.elementAt(index);
              return CustomRadio(value: element, controller: rarityController,
                  widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: widget._navAdmin.rendering.imageRarity(element, fontSize: 8.0, textureSize: null, generate: true))
              );
            }
        ),
        GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1),
            primary: false,
            shrinkWrap: true,
            itemCount: PokeCardType.values.length,
            itemBuilder: (BuildContext context, int index) {
              final element = PokeCardType.values.elementAt(index);
              return CustomRadio(value: element, controller: typeController, widget: getImageType(element));
            }
        ),
        GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1),
            primary: false,
            shrinkWrap: true,
            itemCount: secondTypes.length,
            itemBuilder: (BuildContext context, int index){
              final element = secondTypes.elementAt(index);
              return CustomRadio(value: element, controller: typeExtController, widget: getImageType(element));
            }
        ),
      ]),
    ];

    return Column(
      children: [
        TabBar(
            controller: tabController,
            indicatorPadding: const EdgeInsets.all(1),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
            tabs: [
              Text(AppLocalizations.of(context)!.ca_b22, style: const TextStyle(fontSize: 12)),
              const Icon(Icons.info_outline, size: 28),                 //Text(AppLocalizations.of(context)!.ca_b18, style: TextStyle(fontSize: 10)),
              const Icon(Icons.add_photo_alternate_outlined, size: 28), // Text(AppLocalizations.of(context)!.ca_b39, style: TextStyle(fontSize: 10)),
              const Icon(Icons.bookmark_border_outlined, size: 28),     //Text(AppLocalizations.of(context)!.ca_b16, style: TextStyle(fontSize: 10)),
              Text(AppLocalizations.of(context)!.ca_b17, style: const TextStyle(fontSize: 12)),
              Text(AppLocalizations.of(context)!.ca_b15, style: const TextStyle(fontSize: 10)),
            ]),
        Expanded(
            child: Card(
              color: Colors.teal.shade900,
              child: TabBarView(
                controller: tabController,
                children: tabPages,
              ),
            )
        )
      ],
    );
  }

  Widget cardMainInfo() {
    const imageSize = 270.0;

    final cardInExp = widget._activeCard.cardInExp();
    final cardData = cardInExp.card;

    final int databaseCardId = cardData.pid().id();
    final codeDB = databaseCardId != 0
        ? databaseCardId.toString()
        : AppLocalizations.of(context)!.ca_b29;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: PokeRendering.spacing,
          children: [
          SizedBox(height: imageSize, child: widget._navAdmin.rendering.genericCardWidget(widget._activeCard, language: widget._navAdmin.showLanguage, height: imageSize, reloader: true)),
          Text("${AppLocalizations.of(context)!.ca_b30} $codeDB", style: Theme.of(context).textTheme.headlineSmall),
          Card(
            color: cardData.title.title.isNotEmpty ? Colors.grey.shade500 : Colors.grey.shade900,
            child: TextButton(
              child: Text(AppLocalizations.of(context)!.ca_b32),
              onPressed: () {
                //TODO
                /*
                  if(widget.card.data.title.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchExtensionsCardId(widget.card.data.type,
                          widget.card.data.title.isNotEmpty ? widget.card.data.title[0].name : null, widget.title, databaseCardId ?? 0)),
                    ).then((idCard) {
                      if(idCard != null) {
                        setState(() {
                          // Change object
                          widget.card.data = Environment.instance.collection.pokemonCards[idCard]!;
                          // Recompute default value
                          selectCard();
                        });
                      }
                    });
                  }
                  */
              }
            )
          )
        ]
      ),
    );
  }

  Widget mobileView(BuildContext context, BoxConstraints box)
  {
    return Placeholder();
  }

  Widget desktopView(BuildContext context, BoxConstraints box) {
    List<Widget> others = [];

    final cardInExp = widget._activeCard.cardInExp();
    final cardData = cardInExp.card;

    typeExtController.afterPress(cardData.typeExtended != null ? cardData.typeExtended! : PokeCardType.unknown);

    cardData.weakness   ??= PokeEnergyValue(PokeCardType.unknown, 0);
    cardData.resistance ??= PokeEnergyValue(PokeCardType.unknown, 0);

    levelController.afterPress(cardData.level);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        cardMainInfo(),
        Expanded(
          child: cardTabs()
        ),
    ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box){
      return box.maxWidth > 500
          ? desktopView(context, box) : mobileView(context, box);
    });
  }
}

/*
Widget buildTitle(BuildContext context, PokeLanguage language, PokemonCardExtension card, CardIdentifier idCard) {
  return Row(
    children:
    [ getImageType(card.data.type, generate: false), const SizedBox(width: 8.0) ] +
        card.rarity.icon(language) +
        [ const SizedBox(width: 8.0), Text( "- ${idCard.numberId+1}: ${card.data.titleOfCard(language)}", style: Theme.of(context).textTheme.titleLarge?..copyWith(fontSize: 10.0)) ],
  );
}
*/