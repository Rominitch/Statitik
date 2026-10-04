import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/admin_html_card_parser.dart';
import 'package:statitikcard/models/card/poke_card.dart';
import 'package:statitikcard/models/card/poke_card_design.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/card/poke_card_energy_value.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_level.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/screens/wizard/wizard_select_title_name.dart';
import 'package:statitikcard/widgets/widget/widget_button_check.dart';
import 'package:statitikcard/widgets/widget/widget_button_pokedesign.dart';
import 'package:statitikcard/widgets/widget/widget_card_naming.dart';
import 'package:statitikcard/widgets/widget/widget_creator_card_effects.dart';
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

class _PageAdminEditCardState extends State<PageAdminEditCard> with TickerProviderStateMixin {

  late CustomRadioController typeController      = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController    = CustomRadioController(onChange: (value) { onRarityChanged(value); });
  late CustomRadioController typeExtController   = CustomRadioController(onChange: (value) { onTypeExtChanged(value); });
  late CustomRadioController levelController     = CustomRadioController(onChange: (value) { onLevel(value); });
  late WidgetCustomButtonCheckController setController = WidgetCustomButtonCheckController<PokeSet>(onChangeSets);
  late TabController         tabController;

  final secondTypes = [PokeCardType.unknown] + energies;
  final specialIDController = TextEditingController();

  void onChangeSets() {
    setState(() {});
  }
  void refresh() {
    setState(() {});
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
            widget._activeCard.idImage = PokeCardImageIdentifier(set.key, idImage);
            widget._activeCard.computeJPCardID();
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

  Widget createImageFieldWidget() {
    final cardInExp = widget._activeCard.cardInExp();
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: cardInExp.setInfo.length,
      itemBuilder: (BuildContext context, int index){
        final setAndImages = cardInExp.setInfo.entries.elementAt(index);
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            spacing: PokeRendering.spacing,
            children: [
              setAndImages.key.imageWidget(height: 50),
              Card(
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: setAndImages.value.length < 6  ? () {
                    setState(() {
                      addBestDesign(setAndImages);
                    });
                  } : null
                )
              ),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => const SizedBox(width: PokeRendering.spacing),
                    itemCount: setAndImages.value.length,
                    primary: false,
                    itemBuilder: (context, index) {
                      return WidgetButtonPokeDesign(widget._navAdmin,
                        PokeCardViewerIdentifier( widget._activeCard.expansion, widget._activeCard.idCard,
                          idImage: PokeCardImageIdentifier(setAndImages.key, index),
                          specificLanguage: widget._activeCard.specificLanguage,
                        ),
                        refresh
                      );
                    }
                  ),
                ),
              ),
            ],
          )
        );
      }
    );
  }

  //void addBestDesign(PokeCardIdentifier idCard, List images, int index) {
  void addBestDesign(MapEntry entrySet) {
    entrySet.value.add(PokeCardDesign(widget._navAdmin.collection.designs().first));
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
                WizardSelectTitleName.select(context, widget._navAdmin, isPokemonCard(widget._activeCard.cardInExp().card.type) ? ListInfo.Pokemon : ListInfo.Trainer,
                  (selectedTitle) {
                    setState(() {
                      if( selectedTitle != null ) {
                        cardData.title.title.add(PokeFullCardPokemon(selectedTitle));
                      }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          spacing: PokeRendering.spacing,
          children: [
            Row(
              children: [
                const Text("Carte secrète: "),
                Checkbox(value: cardInExp.isSecret, onChanged: (value) {
                  setState(() {
                    cardInExp.isSecret = value!;
                  });
                }
                ),
                Expanded(
                  child: Row(
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
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
            itemCount: widget._navAdmin.collection.allSets().length,
            itemBuilder: (BuildContext context, int index) {
              final element = widget._navAdmin.collection.allSets().elementAt(index);
              return WidgetCardSetButtonCheck( widget._activeCard.cardInExp().setInfo, element,
                defaultValue: [PokeCardDesign(widget._navAdmin.collection.designs().first)],
                controller: setController);
            },
          ),
        ),

        createImageFieldWidget()
      ]
    );
  }

  Widget pageMarkers() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 2.2),
      itemCount: widget._navAdmin.collection.markers().length,
      itemBuilder: (BuildContext context, int index) {
        var element = widget._navAdmin.collection.markers().elementAt(index);
        return WidgetMarkerButtonCheck(widget._navAdmin.showLanguage, widget._activeCard.cardInExp().card.markers.markers(), element, null);
      }
    );
  }

  Widget pageTypeRarity() {
    final delegateType = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.of(context).size.width / PokeRendering.bestTypeWidth).ceil(), crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: PokeRendering.bestTypeRatio);
    final delegateRarity = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.of(context).size.width / PokeRendering.bestRarityWidth).ceil(), crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: PokeRendering.bestRarityRatio);

    return Column( children: [
      Expanded(
        flex: 3,
        child: GridView.builder(
            gridDelegate: delegateRarity,
            itemCount: widget.listRarity.length,
            itemBuilder: (BuildContext context, int index) {
              var element = widget.listRarity.elementAt(index);
              return CustomRadio(value: element, controller: rarityController,
                  widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: widget._navAdmin.rendering.imageRarity(element, fontSize: 8.0, textureSize: null, generate: true))
              );
            }
        ),
      ),
      Expanded(
        flex: 2,
        child: GridView.builder(
            gridDelegate: delegateType,
            itemCount: PokeCardType.values.length,
            itemBuilder: (BuildContext context, int index) {
              final element = PokeCardType.values.elementAt(index);
              return CustomRadio(value: element, controller: typeController, widget: getImageType(element));
            }
        ),
      ),
      Expanded(
        flex: 2,
        child: GridView.builder(
            gridDelegate: delegateType,
            itemCount: secondTypes.length,
            itemBuilder: (BuildContext context, int index){
              final element = secondTypes.elementAt(index);
              return CustomRadio(value: element, controller: typeExtController, widget: getImageType(element));
            }
        ),
      ),
    ]);
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
      pageMarkers(),
      // Page 5
      WidgetCreatorCardEffects(widget._navAdmin, widget._activeCard),
      // Page 6
      pageTypeRarity()
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
          ]
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
    final imageSizeH = (MediaQuery.of(context).size.width > 500) ? null : 270.0;
    final imageSizeW = (MediaQuery.of(context).size.width > 500) ? 380.0 : null;

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
          SizedBox(width: imageSizeW, height: imageSizeH, child: widget._navAdmin.rendering.genericCardWidget(widget._activeCard, language: widget._navAdmin.showLanguage, reloader: true)),
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