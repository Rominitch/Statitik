import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/admin_card_creator.dart';
import 'package:statitikcard/models/admin/admin_html_card_parser.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/screenOld/widgets/button_check.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/services/tools.dart';

class WidgetCreatorCardFromExpansion extends StatefulWidget {
  final PokeNavAdmin          _navAdmin;
  final PokeCardViewerIdentifier _cardView;
  final AdminCardCreator?        _creator;

  final Function(int listId, int?)?   onAppendCard;
  final Function(int listId)?         onChangeList;
  final Function()?                   onNeedRefresh;
  final List<PokeRarity>      listRarity;
  final String                title;
  final List?                 secondTypes;
  final CardEditorOptions     options;

  // Computed
  //final PokeCardInExpansion _card;
  final bool                editor;

  WidgetCreatorCardFromExpansion.editor(this._navAdmin, this._cardView, this.title, this.options, {super.key}):
    editor=true, onAppendCard=null, onChangeList=null, onNeedRefresh=null,
    listRarity = (_cardView.expansion.location() == CardLocation.Monde ? _navAdmin.collection.worldRarity() : _navAdmin.collection.japanRarity()).toList()
      ..removeWhere((element) => element == _navAdmin.collection.unknownRarity()),
    secondTypes = [PokeCardType.unknown] + energies,
    _creator = null;

  WidgetCreatorCardFromExpansion.quick(this._navAdmin, this._creator, this._cardView, this.onAppendCard, this.onNeedRefresh, {super.key, this.onChangeList}):
    editor=false, listRarity = (_cardView.expansion.location() == CardLocation.Monde ? _navAdmin.collection.worldRarity() : _navAdmin.collection.japanRarity()), title="",
    secondTypes=null, options = CardEditorOptions();

  @override
  State<WidgetCreatorCardFromExpansion> createState() => _WidgetCreatorCardFromExpansionState();
}

class _WidgetCreatorCardFromExpansionState extends State<WidgetCreatorCardFromExpansion> with TickerProviderStateMixin {
  late CustomRadioController typeController = CustomRadioController(
      onChange: (value) {
        onTypeChanged(value);
      });
  late CustomRadioController rarityController = CustomRadioController(
      onChange: (value) {
        onRarityChanged(value);
      });
  late CustomRadioController typeExtController = CustomRadioController(
      onChange: (value) {
        onTypeExtChanged(value);
      });
  late CustomRadioController levelController = CustomRadioController(
      onChange: (value) {
        onLevel(value);
      });
  late CustomRadioController listChooserController = CustomRadioController(
      onChange: (value) {
        onChangeList(value);
      });
  late CustomButtonCheckController setController = CustomButtonCheckController(
      onChangeSets);
  late TabController tabController;

  PokeCardInExpansion? _newCard;

  late PokeRarity _selectRarity;
  PokeCardType    _selectType = PokeCardType.plante;

  final specialIDController = TextEditingController();

  bool _auto = false;

  bool isJapanese() {
    return widget._cardView.expansion.location() == CardLocation.Asie;
  }

  void onChangeSets() {
    setState(() {
      /*
      if (_newCard!.setInfo.isNotEmpty) {
        while (_newCard!.images.length < _newCard!.sets.length) {
          _newCard!.images.add([]);
        }
        while (_newCard!.images.length > _newCard!.sets.length) {
          _newCard!.images.removeLast();
        }
      }*/
    });
  }

  void onChangeList(value) {
    widget.onChangeList!(value);
  }

  void onTypeChanged(value) {
    _selectType = value;
    if( _newCard != null) {
      _newCard!.card.type = _selectType;
    }
    if(widget._creator != null) {
      widget._creator!.type = _selectType;
    }
  }

  void onLevel(value) {
    _newCard!.card.level = value;
  }

  void onTypeExtChanged(PokeCardType value) {
    if (value == PokeCardType.unknown) {
      _newCard!.card.typeExtended = null;
    } else {
      _newCard!.card.typeExtended = value;
    }
  }

  void onRarityChanged(PokeRarity value) {
    _selectRarity = value;
    if(_newCard != null) {
      _newCard!.rarity = _selectRarity;
    }
    if(widget._creator != null) {
      widget._creator!.rarity = _selectRarity;
    }
    if (_auto) {
      widget.onAppendCard!(listChooserController.currentValue, null);
    }
  }

  @override
  void initState() {
    _selectRarity = widget._navAdmin.collection.unknownRarity();
    if(widget._creator != null) {
      _selectRarity = widget._creator!.rarity;
      _selectType   = widget._creator!.type;
    }

    tabController = TabController(
        length: 6, vsync: this, initialIndex: widget.options.tabIndex);
    tabController.addListener(() {
      widget.options.tabIndex = tabController.index;
    });

// Auto fill (only for japanese card)
    if (isJapanese() && widget.editor) {
      for(final s in _newCard!.setInfo.entries) {
        for(int imageID = 0; imageID < s.value.length; imageID += 1) {
          final id = PokeCardImageIdentifier(s.key, imageID);
          if (_newCard!.image(id)!.jpDBId == 0) {
            //TODO
            /*
            CardImageCreator.computeJPCardID(
                widget.expansion, _newCard!, widget.idCard, id);
            */
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
    typeController.afterPress(_selectType);
    rarityController.afterPress(_selectRarity);
    if( _newCard != null ) {
      specialIDController.text = _newCard!.specialID;
    }
  }

  void automaticFill() {
    /*
    for (var extCards in widget.expansion.cards.cards) {
      var extCard = extCards.first;
// Automatic add missing design
      for (var imageCard in extCard.images) {
        if (imageCard.isEmpty) {
          addBestDesign(widget.expansion.cards.computeIdCard(extCard)!, imageCard,
              extCard.images.indexOf(imageCard));
        }
      }

// Automatic first design
      if (extCard.images.isNotEmpty) {
        var basicDesign = extCard.images.first;
        if (basicDesign.isNotEmpty) {
          var cardDesign = basicDesign.first;
          if (widget.expansion.location() == CardLocation.Monde &&
              cardDesign.cardDesign.design == 0) {
            if (extCard.rarity.id() == 37) {
              cardDesign.cardDesign.design = Design.arcEnCiel.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art = ArtFormat.fullArt;
              extCard.isSecret = true;
            } else if (extCard.rarity.id() == 36) {
              cardDesign.cardDesign.design = Design.gold.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art = ArtFormat.fullArt;
              extCard.isSecret = true;
            } else if (extCard.rarity.id() == 13) {
              cardDesign.cardDesign.design = Design.full.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art = ArtFormat.halfArt;
            } else if (extCard.rarity.id() == 18) {
              cardDesign.cardDesign.design = Design.full.index;
              cardDesign.cardDesign.pattern = 0;
              cardDesign.cardDesign.art = ArtFormat.fullArt;
            } else if (extCard.rarity.id() == 6) {
              cardDesign.cardDesign.design = Design.holographic.index;
              if (widget.expansion.extension.id == 3) {
                cardDesign.cardDesign.pattern = 0;
              } else {
                cardDesign.cardDesign.pattern = 2;
              }
            }
          }
        }
      }
    }
    */
  }

  void addBestDesign(PokeCardIdentifier idCard, List images, PokeSet index) {
    /*
    var imageDesign = ImageDesign();
// Search ancestor
    var idImage = images.length;
    for (int id = idCard.numberId - 1; id >= 0; id -= 1) {
      var oldId = PokeCardIdentifier.copy(idCard);
      oldId.cardId[1] = id;
      var oldCard = widget.expansion.cards.cardFromId(oldId);
      final imageSet = oldCard.setInfo[index];
      if (imageSet != null) {
        if (idImage < imageSet.length) {
          imageDesign.cardDesign.copyFrom(
              imageSet[idImage].cardDesign);
          break;
        }
      }
    }
    images.add(imageDesign);
    */
  }

  Widget createImageFieldWidget() {
    return Placeholder();
    /*
    const iconSize = 30.0;
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _newCard!.images.length,
        itemBuilder: (BuildContext context, int index) {
          List<Widget> images = [
            _newCard!.sets[index].imageWidget(height: 50)
          ];
          int idImg = 0;
          for (var element in _newCard!.images[index]) {
            var localIdImg = CardImageIdentifier(index, idImg);
            images.add(Card(
                child: TextButton(
                  child: element.cardDesign.iconFullDesign(height: iconSize),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          CardImageCreator(
                              widget.expansion, _newCard!, widget.idCard, localIdImg,
                              widget.activeLanguage, widget.options)),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  onLongPress: () {
                    setState(() {
                      _newCard!.removeImage(localIdImg);
                    });
                  },
                )
            ));
            idImg += 1;
          }

          images.add(Card(
            child: IconButton(icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    addBestDesign(
                        widget.idCard, _newCard!.images[index], index);
                  });
                }
            ),
          ));

          return Row(
              children: images
          );
        }
    );
    */
  }

  Future<void> fillEffects([bool forceRefill=false]) async {
    double count = 0.0;

    final parser = AdminHtmlCardParser(widget._navAdmin);

    for(var cardsList in widget._cardView.expansion.cards.cards) {
      EasyLoading.showProgress(count / widget._cardView.expansion.cards.cards.length, status: "$count / ${widget._cardView.expansion.cards.cards.length}");

      for(var card in cardsList) {
        if(card.card.cardEffects.effects.isEmpty || forceRefill) {
          await parser.readEffectsJP(card);
        }
      }
      count += 1.0;
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> others = [];
    if(widget.editor) {
      return Placeholder();
      /*
      List<Widget> namedWidgets = [];
      for (int id=0; id < _newCard!.data.title.length; id+=1) {
        namedWidgets.add(PokeCardNaming(widget.activeLanguage, widget.idCard, _newCard!, id));
      }

      typeExtController.afterPress(_newCard!.data.typeExtended != null ? _newCard!.data.typeExtended! : TypeCard.unknown);

      _newCard!.data.weakness   ??= EnergyValue(TypeCard.unknown, 0);
      _newCard!.data.resistance ??= EnergyValue(TypeCard.unknown, 0);

      levelController.afterPress(_newCard!.data.level);
      int? databaseCardId = Environment.instance.collection.pokemonCards.containsValue(_newCard!.data)
          ? Environment.instance.collection.rPokemonCards[_newCard!.data]
          : null;

      var codeDB = databaseCardId != null
          ? databaseCardId.toString()
          : AppLocalizations.of(context)!.ca_b29;

      const newResistances = <int>[3, 6, 9, 12, 13, 14];
      int defaultResistance = newResistances.contains(widget.expansion.extension.id) ? 30 : 20;

      List<Widget> cardInfo = [];
      if(isPokemonType(_newCard!.data.type)){
        cardInfo += [
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 2.0),
              itemCount: Level.values.length,
              primary: false,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                var element = Level.values[index];
                return CustomRadio(value: element, controller: levelController, widget: Text( levelText(context, element) ));
              }
          ),
          Row(children: [
            SizedBox(width: 60, child: Text(AppLocalizations.of(context)!.ca_b25, style: const TextStyle(fontSize: 12))),
            Expanded(
              child: SliderInfo( SliderInfoController(() {
                return _newCard!.data.life.toDouble();
              },
                      (double value){
                    _newCard!.data.life = value.round().toInt();
                  }),
                  minLife, maxLife,
                  division: 40),
            ),
          ]),
          // Retreat
          Row(children: [
            SizedBox(width: 60, child: Text(AppLocalizations.of(context)!.ca_b26, style: const TextStyle(fontSize: 12))),
            Expanded(
              child: SliderInfo( SliderInfoController(() {
                return _newCard!.data.retreat.toDouble();
              },
                      (double value){
                    _newCard!.data.retreat = value.round().toInt();
                  }),
                  minRetreat, maxRetreat,
                  division: 5),
            ),
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(context)!.ca_b28, style: const TextStyle(fontSize: 12)),
              EnergySlider(_newCard!.data.weakness!, 2, minWeakness, maxWeakness, division: 5)
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(context)!.ca_b27, style: const TextStyle(fontSize: 12)),
              EnergySlider(_newCard!.data.resistance!, defaultResistance, minResistance, maxResistance, division: 6)
            ],
          )
        ];
      }

      List<Widget> tabHeaders = [
        Text(AppLocalizations.of(context)!.ca_b22, style: const TextStyle(fontSize: 12)),
        const Icon(Icons.info_outline, size: 28),                 //Text(AppLocalizations.of(context)!.ca_b18, style: TextStyle(fontSize: 10)),
        const Icon(Icons.add_photo_alternate_outlined, size: 28), // Text(AppLocalizations.of(context)!.ca_b39, style: TextStyle(fontSize: 10)),
        const Icon(Icons.bookmark_border_outlined, size: 28),     //Text(AppLocalizations.of(context)!.ca_b16, style: TextStyle(fontSize: 10)),
        Text(AppLocalizations.of(context)!.ca_b17, style: const TextStyle(fontSize: 12)),
        Text(AppLocalizations.of(context)!.ca_b15, style: const TextStyle(fontSize: 10)),
      ];

      List<Widget> tabPages = [
        // Page 1
        SingleChildScrollView(
          child: Column(
              children: namedWidgets + [
                Card(child: TextButton(
                  child: Text(AppLocalizations.of(context)!.nce_b7),
                  onPressed: () {
                    _newCard!.data.title.add(Pokemon(1, Environment.instance.collection.pokemons[1]!));
                    PokeCardNaming.selectCardName(context, widget.activeLanguage, widget.idCard, _newCard!, _newCard!.data.title.length-1).then((value) {
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
                    Checkbox(value: _newCard!.isSecret, onChanged: (value) {
                      setState(() {
                        _newCard!.isSecret = value!;
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
                    return CardSetButtonCheck(widget.activeLanguage, _newCard!.sets, element, controller: setController);
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
                              _newCard!.specialID = data;
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
              return MarkerButtonCheck(widget.activeLanguage, _newCard!.data.markers, element, null);
            }
        ),
        SingleChildScrollView(
            child: CardEffectsPanel(_newCard!, widget.activeLanguage)
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
                SizedBox(height: imageSize, child: genericCardWidget(widget.expansion, widget.idCard, CardImageIdentifier(), height: imageSize, reloader: true)),
                const SizedBox(width:8),
                Expanded(child: Text("${AppLocalizations.of(context)!.ca_b30} $codeDB", style: Theme.of(context).textTheme.headlineSmall)),
                Card(
                    color: _newCard!.data.title.isNotEmpty ? Colors.grey.shade500 : Colors.grey.shade900,
                    child: TextButton(
                        child: Text(AppLocalizations.of(context)!.ca_b32),
                        onPressed: () {
                          if(_newCard!.data.title.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchExtensionsCardId(_newCard!.data.type,
                                  _newCard!.data.title.isNotEmpty ? _newCard!.data.title[0].name : null, widget.title, databaseCardId ?? 0)),
                            ).then((idCard) {
                              if(idCard != null) {
                                setState(() {
                                  // Change object
                                  _newCard!.data = Environment.instance.collection.pokemonCards[idCard]!;
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
      */
    } else {
      others = [
        Card(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.05),
              primary: false,
              shrinkWrap: true,
              itemCount: PokeCardType.values.length,
              itemBuilder: (BuildContext context, int index) {
                var element = PokeCardType.values.elementAt(index);
                return CustomRadio(value: element, controller: typeController, widget: getImageType(element));
              }
          ),
        ),
        Card(
          child: LayoutBuilder(builder: (context, box){
            final count = (box.maxWidth / 70).ceil();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.3),
              itemCount: widget.listRarity.length,
              primary: false,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                var element = widget.listRarity.elementAt(index);
                return CustomRadio(value: element, controller: rarityController,
                    widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: widget._navAdmin.rendering.imageRarity(element, textureSize: null, fontSize: 8.0, generate: true)
                    )
                );
              }
          );
          }),
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
                      child: Text(AppLocalizations.of(context)!.nce_b2),
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
              if( isJapanese() ) Card(
                  color: Colors.grey[800],
                  child: TextButton(
                      child: Column(
                        children: [
                          const Icon(Icons.format_color_fill),
                          Text(AppLocalizations.of(context)!.nce_b9, style: const TextStyle(fontSize: 8.0))
                        ],
                      ),
                      onPressed: () {
                        EasyLoading.show();
                        fillEffects().then((value) {
                          EasyLoading.dismiss();
                          if(widget.onNeedRefresh != null) {
                            EasyLoading.dismiss();
                            widget.onNeedRefresh!();
                          }
                        }).onError((error, stackTrace) {
                          printOutput("$error - ${stackTrace.toString()}");
                          EasyLoading.dismiss();
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