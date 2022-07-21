import 'package:flutter/material.dart';

import 'package:statitikcard/screen/admin/card_editor.dart';
import 'package:statitikcard/screen/admin/card_effect_panel.dart';
import 'package:statitikcard/screen/admin/search_extension_card_id.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/button_check.dart';
import 'package:statitikcard/services/models/card_design.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/screen/widgets/card_image.dart';
import 'package:statitikcard/screen/widgets/custom_radio.dart';
import 'package:statitikcard/screen/widgets/energy_slider.dart';
import 'package:statitikcard/screen/widgets/list_selector.dart';
import 'package:statitikcard/screen/widgets/slider_with_text.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

class CardCreator extends StatefulWidget {
  final Language              activeLanguage;
  final bool                  editor;
  final SubExtension          se;
  final PokemonCardExtension  card;
  final CardIdentifier        idCard;
  final Function(int listId, int?)?   onAppendCard;
  final Function(int listId)?         onChangeList;
  final List                  listRarity;
  final String                title;
  final List?                 secondTypes;
  final CardEditorOptions     options;

  CardCreator.editor(this.activeLanguage, this.se, this.card, this.idCard, this.title, this.options, {Key? key}):
    editor=true, onAppendCard=null, onChangeList=null,
    listRarity = (se.extension.language.isWorld() ? Environment.instance.collection.worldRarity : Environment.instance.collection.japanRarity)
      ..removeWhere((element) => element == Environment.instance.collection.unknownRarity),
    secondTypes = [TypeCard.unknown] + energies,
    super(key: key);

  CardCreator.quick(this.activeLanguage, this.se, this.card, this.idCard, this.onAppendCard, bool isWorldCard, {Key? key, this.onChangeList}):
    editor=false, listRarity = (isWorldCard ? Environment.instance.collection.worldRarity : Environment.instance.collection.japanRarity), title="",
    secondTypes=null, options = CardEditorOptions(), super(key: key);

  @override
  State<CardCreator> createState() => _CardCreatorState();
}

class _CardCreatorState extends State<CardCreator> with TickerProviderStateMixin {
  late CustomRadioController typeController        = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController      = CustomRadioController(onChange: (value) { onRarityChanged(value); });
  late CustomRadioController typeExtController     = CustomRadioController(onChange: (value) { onTypeExtChanged(value); });
  late CustomRadioController levelController       = CustomRadioController(onChange: (value) { onLevel(value); });
  late CustomRadioController listChooserController = CustomRadioController(onChange: (value) { onChangeList(value); });
  late CustomButtonCheckController setController = CustomButtonCheckController(onChangeSets);
  late TabController         tabController;

  final specialIDController = TextEditingController();

  bool         _auto    = false;

  void onChangeSets() {
    setState(() {
      if( widget.card.sets.isNotEmpty ) {
        while(widget.card.images.length < widget.card.sets.length) {
          widget.card.images.add([]);
        }
        while(widget.card.images.length > widget.card.sets.length) {
          widget.card.images.removeLast();
        }
      }
    });
  }

  void onChangeList(value) {
    widget.onChangeList!(value);
  }

  void onTypeChanged(value) {
    widget.card.data.type = value;
  }
  void onLevel(value) {
    widget.card.data.level = value;
  }
  void onTypeExtChanged(value) {
    if(value == TypeCard.unknown) {
      widget.card.data.typeExtended = null;
    } else {
      widget.card.data.typeExtended = value;
    }
  }

  void onRarityChanged(value) {
    widget.card.rarity = value;
    if(_auto) {
      widget.onAppendCard!(listChooserController.currentValue, null);
    }
  }

  @override
  void initState() {
    tabController = TabController( length: 6, vsync: this, initialIndex: widget.options.tabIndex );
    tabController.addListener(() {
      widget.options.tabIndex = tabController.index;
    });

    // Auto fill (only for japanese card)
    if(widget.activeLanguage.isJapanese() && widget.editor) {
      for(int idSet=0; idSet < widget.card.images.length; idSet+=1) {
        for(int idImage=0; idImage < widget.card.images[idSet].length; idImage+=1) {
          var id = CardImageIdentifier(idSet,idImage);
          if(widget.card.image(id)!.jpDBId == 0) {
            CardImageCreator.computeJPCardID(widget.se, widget.card, widget.idCard, id);
          }
        }
      }
    }

    listChooserController.currentValue = 0;

    selectCard();

    super.initState();
  }

  void selectCard() {
    // Set current value
    typeController.afterPress(widget.card.data.type);
    rarityController.afterPress(widget.card.rarity);
    specialIDController.text = widget.card.specialID;
  }

  void automaticFill() {
    widget.se.seCards.cards.forEach((extCards) {
      var extCard = extCards.first;
      // Automatic add missing design
      extCard.images.forEach((imageCard) {
        if(imageCard.isEmpty) {
          addBestDesign(widget.se.seCards.computeIdCard(extCard)!, imageCard, extCard.images.indexOf(imageCard));
        }
      });

      // Automatic first design
      if(extCard.images.isNotEmpty) {
        var basicDesign = extCard.images.first;
        if(basicDesign.isNotEmpty) {
          var cardDesign = basicDesign.first;
          if( widget.se.extension.language.isWorld() && cardDesign.cardDesign.design == 0) {
            if( extCard.rarity.id == 37) {
              cardDesign.cardDesign.design  = Design.arcEnCiel.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art     = ArtFormat.fullArt;
              extCard.isSecret = true;
            } else if( extCard.rarity.id == 36) {
              cardDesign.cardDesign.design  = Design.gold.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art     = ArtFormat.fullArt;
              extCard.isSecret = true;
            } else if( extCard.rarity.id == 13) {
              cardDesign.cardDesign.design  = Design.full.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art     = ArtFormat.halfArt;
            } else if( extCard.rarity.id == 18) {
              cardDesign.cardDesign.design  = Design.full.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art     = ArtFormat.fullArt;
            } else if( extCard.rarity.id == 6) {
              cardDesign.cardDesign.design  = Design.holographic.index;
              if(widget.se.extension.id == 3) {
                cardDesign.cardDesign.pattern = 0;
              } else {
                cardDesign.cardDesign.pattern = 2;
              }
            }
          }
        }
      }
    });
  }

  void addBestDesign(CardIdentifier idCard, List images, int index) {
    var imageDesign = ImageDesign();
    // Search ancestor
    var idImage = images.length;
    for(int id=idCard.numberId-1; id >= 0; id-=1) {
      var oldId = CardIdentifier.copy(idCard);
      oldId.cardId[1] = id;
      var oldCard = widget.se.cardFromId(oldId);
      if(index < oldCard.images.length) {
        if( idImage < oldCard.images[index].length) {
          imageDesign.cardDesign.copyFrom(oldCard.images[index][idImage].cardDesign);
          break;
        }
      }
    }
    images.add(imageDesign);
  }

  Widget createImageFieldWidget() {
    const iconSize = 30.0;
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: widget.card.images.length,
      itemBuilder: (BuildContext context, int index){
        List<Widget> images = [widget.card.sets[index].imageWidget(height: 50)];
        int idImg=0;
        widget.card.images[index].forEach( (element){
          var localIdImg = CardImageIdentifier(index, idImg);
          images.add(Card(
            child: TextButton(
              child: element.cardDesign.iconFullDesign(height: iconSize),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CardImageCreator(
                    widget.se, widget.card, widget.idCard, localIdImg, widget.activeLanguage, widget.options)),
                ).then((value) {
                  setState(() {});
                });
              },
              onLongPress: () {
                setState(() {
                  widget.card.removeImage(localIdImg);
                });
              },
            )
          ));
          idImg +=1;
        });

        images.add(Card(
          child: IconButton(icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              setState(() {
                addBestDesign(widget.idCard, widget.card.images[index], index);
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

  @override
  Widget build(BuildContext context) {
    List<Widget> others = [];
    if(widget.editor) {
      int id=0;
      List<Widget> namedWidgets = [];
      widget.card.data.title.forEach((element) {
        namedWidgets.add(PokeCardNaming(widget.activeLanguage, widget.idCard, widget.card, id));
        id+=1;
      });

      typeExtController.afterPress(widget.card.data.typeExtended != null ? widget.card.data.typeExtended! : TypeCard.unknown);

      widget.card.data.weakness   ??= EnergyValue(TypeCard.unknown, 0);
      widget.card.data.resistance ??= EnergyValue(TypeCard.unknown, 0);

      levelController.afterPress(widget.card.data.level);
      int? databaseCardId = Environment.instance.collection.pokemonCards.containsValue(widget.card.data)
                          ? Environment.instance.collection.rPokemonCards[widget.card.data]
                          : null;

      var codeDB = databaseCardId != null
                 ? databaseCardId.toString()
                 : StatitikLocale.of(context).read('CA_B29');

      const newResistances = <int>[3, 6, 9];
      int defaultResistance = newResistances.contains(widget.se.extension.id) ? 30 : 20;

      List<Widget> cardInfo = [];
      if(isPokemonType(widget.card.data.type)){
        cardInfo += [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 2.0),
            itemCount: Level.values.length,
            primary: false,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var element = Level.values[index];
              return CustomRadio(value: element, controller: levelController, widget: Text( getLevelText(context, element) ));
            }
          ),
          Row(children: [
            SizedBox(width: 60, child: Text(StatitikLocale.of(context).read('CA_B25'), style: const TextStyle(fontSize: 12))),
            Expanded(
              child: SliderInfo( SliderInfoController(() {
                return widget.card.data.life.toDouble();
              },
                      (double value){
                    widget.card.data.life = value.round().toInt();
                  }),
                  minLife, maxLife,
                  division: 40),
            ),
          ]),
          // Retreat
          Row(children: [
            SizedBox(width: 60, child: Text(StatitikLocale.of(context).read('CA_B26'), style: const TextStyle(fontSize: 12))),
            Expanded(
              child: SliderInfo( SliderInfoController(() {
                return widget.card.data.retreat.toDouble();
              },
              (double value){
                widget.card.data.retreat = value.round().toInt();
              }),
              minRetreat, maxRetreat,
              division: 5),
            ),
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(StatitikLocale.of(context).read('CA_B28'), style: const TextStyle(fontSize: 12)),
              EnergySlider(widget.card.data.weakness!, 2, minWeakness, maxWeakness, division: 5)
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(StatitikLocale.of(context).read('CA_B27'), style: const TextStyle(fontSize: 12)),
              EnergySlider(widget.card.data.resistance!, defaultResistance, minResistance, maxResistance, division: 6)
            ],
          )
        ];
      }

      List<Widget> tabHeaders = [
        Text(StatitikLocale.of(context).read('CA_B22'), style: const TextStyle(fontSize: 12)),
        const Icon(Icons.info_outline, size: 28),                 //Text(StatitikLocale.of(context).read('CA_B18'), style: TextStyle(fontSize: 10)),
        const Icon(Icons.add_photo_alternate_outlined, size: 28), // Text(StatitikLocale.of(context).read('CA_B39'), style: TextStyle(fontSize: 10)),
        const Icon(Icons.bookmark_border_outlined, size: 28),     //Text(StatitikLocale.of(context).read('CA_B16'), style: TextStyle(fontSize: 10)),
        Text(StatitikLocale.of(context).read('CA_B17'), style: const TextStyle(fontSize: 12)),
        Text(StatitikLocale.of(context).read('CA_B15'), style: const TextStyle(fontSize: 10)),
      ];

      List<Widget> tabPages = [
        // Page 1
        SingleChildScrollView(
          child: Column(
            children: namedWidgets + [
              Card(child: TextButton(
                child: Text(StatitikLocale.of(context).read('NCE_B7')),
                onPressed: () {
                  widget.card.data.title.add(Pokemon(Environment.instance.collection.pokemons[1]));
                  PokeCardNaming.selectCardName(context, widget.activeLanguage, widget.idCard, widget.card, widget.card.data.title.length-1).then((value) {
                    setState(() {});
                  });
                },
              ))
            ]
          ),
        ),
        // Page 2
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: cardInfo
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text("Carte secrète: "),
                  Checkbox(value: widget.card.isSecret, onChanged: (value) {
                    setState(() {
                      widget.card.isSecret = value!;
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
                itemCount: Environment.instance.collection.sets.values.length,
                itemBuilder: (BuildContext context, int index) {
                  var element = Environment.instance.collection.sets.values.elementAt(index);
                  return CardSetButtonCheck(widget.activeLanguage, widget.card.sets, element, controller: setController);
                },
              ),
              Row(
                children:[
                  Text(StatitikLocale.of(context).read('CA_B38')),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: specialIDController,
                      decoration: InputDecoration(hintText: StatitikLocale.of(context).read('CA_B38') ),
                      onChanged: (data) {
                      widget.card.specialID = data;
                      }
                    ),
                  )
                ]
              ),
              createImageFieldWidget()
            ]
          ),
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 2.5),
          itemCount: Environment.instance.collection.markers.values.length,
          itemBuilder: (BuildContext context, int index) {
             var element = Environment.instance.collection.markers.values.elementAt(index);
             return MarkerButtonCheck(widget.activeLanguage, widget.card.data.markers, element);
          }
        ),
        SingleChildScrollView(
          child: CardEffectsPanel(widget.card, widget.activeLanguage)
        ),
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
                  children: getImageRarity(element, widget.activeLanguage, fontSize: 8.0, textureSize: null, generate: true))
              );
            }
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1),
            primary: false,
            shrinkWrap: true,
            itemCount: TypeCard.values.length,
            itemBuilder: (BuildContext context, int index) {
              var element = TypeCard.values.elementAt(index);
              return CustomRadio(value: element, controller: typeController, widget: getImageType(element));
            }
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1),
            primary: false,
            shrinkWrap: true,
            itemCount: widget.secondTypes!.length,
            itemBuilder: (BuildContext context, int index){
              var element = widget.secondTypes!.elementAt(index);
              return CustomRadio(value: element, controller: typeExtController, widget: getImageType(element));
            }
          ),
        ]),
      ];
      const imageSize = 270.0;

      return Column(children:
        [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
            children: [
              SizedBox(height: imageSize, child: genericCardWidget(widget.se, widget.idCard, CardImageIdentifier(), height: imageSize, reloader: true)),
              const SizedBox(width:8),
              Expanded(child: Text("${StatitikLocale.of(context).read('CA_B30')} $codeDB", style: Theme.of(context).textTheme.headline5)),
              Card(
                color: widget.card.data.title.isNotEmpty ? Colors.grey.shade500 : Colors.grey.shade900,
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('CA_B32')),
                  onPressed: () {
                    if(widget.card.data.title.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchExtensionsCardId(widget.card.data.type,
                            widget.card.data.title.isNotEmpty ? widget.card.data.title[0].name : null, widget.title, databaseCardId ?? 0)),
                      ).then((idCard) {
                        if(idCard != null) {
                          setState(() {
                            // Change object
                            widget.card.data = Environment.instance.collection.pokemonCards[idCard];
                            // Recompute default value
                            selectCard();
                          });
                        }
                      });
                    }
                  }
                )
              )
            ]),
          ),
          TabBar(
            controller: tabController,
            indicatorPadding: const EdgeInsets.all(1),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
            tabs: tabHeaders),
          Expanded(
            child: Card(
              color: Colors.teal.shade900,
              child: TabBarView(
                controller: tabController,
                children: tabPages,
              ),
            )
          )
        ]
      );
    } else {
      others = [
        GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.05),
            primary: false,
            shrinkWrap: true,
            itemCount: TypeCard.values.length,
            itemBuilder: (BuildContext context, int index) {
              var element = TypeCard.values.elementAt(index);
              return CustomRadio(value: element, controller: typeController, widget: getImageType(element));
            }
        ),
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
                children: getImageRarity(element, widget.activeLanguage, textureSize: null, fontSize: 8.0, generate: true)
              )
            );
          }
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRadio(value: 0, controller: listChooserController, widget: const Text("Normal")),
            CustomRadio(value: 1, controller: listChooserController, widget: const Text("Energie")),
            CustomRadio(value: 2, controller: listChooserController, widget: const Text("Special")),
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: const Icon(Icons.add_circle_outline),
                  onPressed: (){
                    widget.onAppendCard!(listChooserController.currentValue, null);
                  },
                )
              ),
              Card(
                color: _auto ? Colors.green : Colors.grey[800],
                child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B2')),
                    onPressed: () {
                      setState((){
                        _auto = !_auto;
                      });
                    }
                )
              ),
              Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: const Icon(Icons.format_color_fill),
                  onPressed: () {
                    setState((){
                      automaticFill();
                    });
                  }
                )
              ),
            ]
        ),
      ];
      return Card( child: Column(children: others) );
    }
  }
}

Widget buildTitle(BuildContext context, Language language, PokemonCardExtension card, CardIdentifier idCard) {
  return Row(
    children:
      [ getImageType(card.data.type, generate: false), const SizedBox(width: 8.0) ] +
      card.rarity.icon(language) +
      [ const SizedBox(width: 8.0), Text( "- ${idCard.numberId+1}: ${card.data.titleOfCard(language)}", style: Theme.of(context).textTheme.headline6?..copyWith(fontSize: 10.0)) ],
  );
}

class PokeCardNaming extends StatefulWidget {
  final Language              language;
  final PokemonCardExtension  card;
  final CardIdentifier        idCard;
  final int                   idName;

  const PokeCardNaming(this.language, this.idCard, this.card, this.idName, {Key? key}) : super(key: key);

  Pokemon nameInfo() {
    return card.data.title[idName];
  }

  @override
  State<PokeCardNaming> createState() => _PokeCardNamingState();

  static Future selectPokemonName(BuildContext context, Language language, CardIdentifier id, PokemonCardExtension card, int idName) {

    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListSelector(buildTitle(context, language, card, id), language, Environment.instance.collection.pokemons, multiLangue: true)),
    ).then((idDB) {
      if(idDB != null) {
        card.data.title[idName].name = Environment.instance.collection.pokemons[idDB];
      }
    });
  }

  static Future<int?> addNewDresseurObjectName(String newText, int idLangue) async {
    printOutput("Start add new value");
    return await Environment.instance.addNewDresseurObjectName(newText, idLangue);
  }

  static Future selectOtherName(BuildContext context, Language language, CardIdentifier id, PokemonCardExtension card, int idName) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListSelector(buildTitle(context, language, card, id), language, Environment.instance.collection.otherNames, multiLangue:true,
          addNewData: addNewDresseurObjectName)),
    ).then((idDB) {
      if(idDB != null) {
        card.data.title[idName].name = Environment.instance.collection.otherNames[idDB];
      }
    });
  }

  static Future selectCardName(BuildContext context, Language language, CardIdentifier id, PokemonCardExtension card, int idName) {
    if( isPokemonCard(card.data.type) ) {
      return selectPokemonName(context, language, id, card, idName);
    } else {
      return selectOtherName(context, language, id, card, idName);
    }
  }
}

class _PokeCardNamingState extends State<PokeCardNaming> {
  late CustomRadioController specialController = CustomRadioController(onChange: (Forme?  value) { onSpecialChanged(value); });
  late CustomRadioController regionController  = CustomRadioController(onChange: (Region? value) { onRegionChanged(value); });

  void onRegionChanged(Region? value) {
    widget.nameInfo().region = value;
  }

  void onSpecialChanged(Forme? value) {
    widget.nameInfo().forme = value;
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.nameInfo();
    List<Widget> regionsWidget = createRegionsWidget(context, regionController, widget.language);
    List<Widget> formeWidget   = [];

    Environment.instance.collection.formes.values.forEach((element) {
      var text = element.applyToPokemonName(widget.language);
      formeWidget.add(CustomRadio(value: element, controller: specialController,
          widget: Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: Center(child: Text(
                  text,
                  style: TextStyle(fontSize: text.length > 12 ? 8 : 10), softWrap: true)))
              ])
      )
      );
    });
    regionController.afterPress(name.region);
    specialController.afterPress(name.forme);

    // Show only good list based on Type
    Widget nameWidget = isPokemonCard(widget.card.data.type) ?
      Card(
        color: Colors.grey[700],
        child: TextButton(
          child: Text((name.name.isPokemon()) ? name.name.defaultName() : "", style: const TextStyle(fontSize: 9.0)),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListSelector(buildTitle(context, widget.language, widget.card, widget.idCard), widget.language, Environment.instance.collection.pokemons, multiLangue: true)),
            ).then((idDB) {
              if(idDB != null) {
                setState(() {
                  name.name = Environment.instance.collection.pokemons[idDB];
                });
              }
            });
          },
        )
      ) : Card(
        color: Colors.grey[700],
        child: TextButton(
          child: Text((!name.name.isPokemon()) ? name.name.defaultName() : "", style: const TextStyle(fontSize: 9.0)),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListSelector(buildTitle(context, widget.language, widget.card, widget.idCard), widget.language, Environment.instance.collection.otherNames, multiLangue:true,
                  addNewData: PokeCardNaming.addNewDresseurObjectName)),
            ).then((idDB) {
              if(idDB != null) {
                setState(() {
                  name.name = Environment.instance.collection.otherNames[idDB];
                });
              }
            });
          },
        )
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Row(
            children: [
              Expanded(
                child: nameWidget
              ),
              IconButton(onPressed: (){
                  setState(() {
                    widget.card.data.title.remove(widget.nameInfo());
                  });
                },
                icon: const Icon(Icons.delete)
              ),
            ],
          ),
          if( isPokemonType(widget.card.data.type) )
            GridView.count(
              crossAxisCount: 5,
              childAspectRatio: 2.0,
              primary: false,
              shrinkWrap: true,
              children: regionsWidget,
            ),
          if( isPokemonType(widget.card.data.type) )
            GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 3.0,
              primary: false,
              shrinkWrap: true,
              children: formeWidget,
            ),
      ],
    );
  }
}
class CardImageCreator extends StatefulWidget {
  final SubExtension         se;
  final PokemonCardExtension card;
  final CardIdentifier       idCard;
  final CardImageIdentifier  idImage;
  final Language             activeLanguage;
  final CardEditorOptions    options;

  const CardImageCreator(this.se, this.card, this.idCard, this.idImage, this.activeLanguage, this.options, {Key? key}) : super(key: key);

  static void computeJPCardID(SubExtension se, PokemonCardExtension card, CardIdentifier idCard, CardImageIdentifier idImage) {
    try {
      int idFind = 0;
      // Search list of card
      PokemonCardExtension ancestorCard;
      switch(idCard.listId) {
        case 0:
          ancestorCard = se.seCards.cards.sublist(0, idCard.numberId).reversed.firstWhere((element) {
            idFind+=1;
            var img = element[idCard.alternativeId].image(idImage);
            return img != null && img.jpDBId != 0;
          })[0];
          break;
        case 1:
          ancestorCard = se.seCards.energyCard.sublist(0, idCard.numberId).reversed.firstWhere((element) {
            idFind+=1;
            var img = element.image(idImage);
            return img != null && img.jpDBId != 0;
          });
          break;
        case 2:
          ancestorCard = se.seCards.noNumberedCard.sublist(0, idCard.numberId).reversed.firstWhere((element) {
            idFind+=1;
            var img = element.image(idImage);
            return img != null && img.jpDBId != 0;
          });
          break;
        default:
          throw StatitikException("Unknown list !");
      }

      // Zero propagation or next number
      var jpDB = ancestorCard
          .image(idImage)!
          .jpDBId;
      if (jpDB != 0) {
        card.image(idImage)!.jpDBId = jpDB + idFind;
      }

      // Copy name of parent
      var name = card.tryGetImage(CardImageIdentifier()).image;
      if(name.isNotEmpty) {
        card.image(idImage)!.image = name;
      }
    } catch(e) {
      // Nothing found !
      printOutput("ComputeJCard: impossible to find $e");
    }
  }

  @override
  State<CardImageCreator> createState() => _CardImageCreatorState();
}

class _CardImageCreatorState extends State<CardImageCreator> {
  late CustomRadioController designController = CustomRadioController(onChange: (value) { onDesignChanged(value); });
  late CustomRadioController artController    = CustomRadioController(onChange: (value) { onArtChanged(value); });
  final imageController     = TextEditingController();
  final jpCodeController    = TextEditingController();


  void onDesignChanged(selectedDesign) {
    var art = widget.card.image(widget.idImage)!.cardDesign.art;
    widget.card.image(widget.idImage)!.cardDesign.copyFrom(selectedDesign);
    widget.card.image(widget.idImage)!.cardDesign.art = art;
  }

  void onArtChanged(value) {
    widget.card.image(widget.idImage)!.cardDesign.art = value;
  }

  @override
  void initState() {
    var imageDesign = widget.card.image(widget.idImage)!;
    imageController.text          = imageDesign.image;
    jpCodeController.text         = imageDesign.jpDBId.toString();
    // WARNING: don't copy by ref
    var newCardDesign = CardDesign();
    newCardDesign.copyFrom(imageDesign.cardDesign);
    designController.currentValue = newCardDesign;
    artController.currentValue    = imageDesign.cardDesign.art;

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    var imageDesign = widget.card.image(widget.idImage)!;
    var nextCardId = widget.se.seCards.nextId(widget.idCard);
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('CA_B41')),
        actions: [
          if(nextCardId != null)
            Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('NCE_B6')),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => CardEditor(widget.se, nextCardId, widget.options)),
                    );

                    // WARNING: refresh issue (don't known how to refresh new popped CardEditor page)
                    var nextCard = widget.se.cardFromId(nextCardId);
                    if(nextCard.images.length >= widget.idImage.idSet
                        && nextCard.images[widget.idImage.idSet].length > widget.idImage.idImage) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardImageCreator(
                            widget.se, nextCard, nextCardId, widget.idImage, widget.activeLanguage, widget.options)),
                      );
                    }
                  }
                )
            ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: genericCardWidget(widget.se, widget.idCard, widget.idImage, reloader: true)),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
            itemCount: Environment.instance.collection.validDesigns.length,
            primary: false,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var element = Environment.instance.collection.validDesigns[index];
              return CustomRadio(value: element, controller: designController, widget: element.icon() );
            }
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
            itemCount: ArtFormat.values.length,
            primary: false,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var element = ArtFormat.values[index];
              return CustomRadio(value: element, controller: artController, widget: iconArt(element) );
            }
          ),
          Text(StatitikLocale.of(context).read('CA_B34'), style: const TextStyle(fontSize: 12)),
          TextField(
            controller: imageController,
            decoration: InputDecoration(
                hintText: CardImage.computeJPPokemonName(widget.se, widget.card)
            ),
            onChanged: (data) {
              imageDesign.image = data;
            }
          ),
          if(widget.activeLanguage.isJapanese()) Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: jpCodeController,
                  onChanged: (data) {
                    setState(() {
                      if(data.isNotEmpty) {
                        imageDesign.jpDBId = int.parse(data);
                      } else {
                        imageDesign.jpDBId = 0;
                      }
                    });
                  }
                ),
              ),
              Card( child: IconButton(
                icon: const Icon(Icons.upgrade),
                onPressed: () async {
                  // Clean all data
                  imageDesign.finalImage = "";
                  Environment.instance.storage.cleanCardFile(widget.se, widget.idCard).then((value) {
                    CardImageCreator.computeJPCardID(widget.se, widget.card, widget.idCard, widget.idImage);
                    // Retry
                    setState(() {
                      jpCodeController.text = imageDesign.jpDBId.toString();
                    });
                  });
                },
              ))
            ]
          ),
          Card(
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                // Clean all data
                imageDesign.finalImage = "";
                await Environment.instance.storage.cleanCardFile(widget.se, widget.idCard);

                setState(() {
                  imageDesign.jpDBId = int.parse(jpCodeController.value.text);
                });
              },
            )
          ),
        ]
      )
    );
  }
}


