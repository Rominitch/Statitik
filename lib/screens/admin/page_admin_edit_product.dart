import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinbox/material.dart';

import 'package:intl/intl.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector_in_product.dart';
import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_subject.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product.dart';
import 'package:statitikcard/models/products/poke_product_booster.dart';
import 'package:statitikcard/models/products/poke_product_card.dart';
import 'package:statitikcard/models/products/poke_product_category.dart';
import 'package:statitikcard/models/products/poke_product_side.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';

import 'package:statitikcard/screenOld/commonPages/extension_page.dart';
import 'package:statitikcard/screenOld/commonPages/side_product_selection.dart';
import 'package:statitikcard/screenOld/widgets/CardSelector/card_selector_product_card.dart';
import 'package:statitikcard/screenOld/widgets/cards_selection.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/screenOld/widgets/pokemon_card.dart';
import 'package:statitikcard/screens/wizard/wizard_select_until_card.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/widgets/widget/widget_button_check.dart';
import 'package:statitikcard/widgets/widget/widget_selector_booster.dart';
import 'package:statitikcard/widgets/widget/widget_selector_card_viewer.dart';
import 'package:statitikcard/widgets/widget/widget_selector_side_product.dart';
import 'package:statitikcard/widgets/expansion/widget_expansions_selector.dart';

class PageAdminEditProduct extends StatefulWidget {
  final PokeNavAdmin _nav;
  final PokeProduct? editProduct;

  const PageAdminEditProduct(this._nav, {super.key}): editProduct = null;

  const PageAdminEditProduct.edit(this._nav, this.editProduct, {super.key});

  @override
  State<PageAdminEditProduct> createState() => _PageAdminEditProductState();
}

class _PageAdminEditProductState extends State<PageAdminEditProduct> {
  final _formKey = GlobalKey<FormState>();
  late CustomRadioController    _langueController;

  late PokeIdentifier           _pid;
  DateTime                      _releaseDate = DateTime.now();
  late PokeProductCategory      _category;


  Map<PokeProductBooster?, int> _boosters = {};
  Map<PokeProductSide, int>     _sideProducts = {};
  List<PokeProductCard>         _otherCards   = [];
  int                           _nbRandomPerProduct = 0;
  List<PokeLanguage>            _excludeLanguage = [];
  CardLocation                  _location = CardLocation.Monde;

  List<PokeFullCardPokemon>     _honoredPokemon = [];
  List<PokeIdentifier>          _honoredOther   = [];


  List<Widget>  radioCat    = [];
  List<Widget>  radioLangue = [];

  String? error;

  late PokeNavLanguage nav;

  void onAdd()
  {
    setState(() {
      _boosters[null] = _location == CardLocation.Asie ? 5 : 11;
    });
  }

  PokeIdentifier newProductId() {
    return widget._nav.collection.newId(PokeIdentifierType.product, widget._nav.collection.products());
  }

  @override
  void initState() {
    if(widget.editProduct != null) {
      final p = widget.editProduct!;
      _pid                = p.pid();
      _category           = p.category;
      _boosters           = Map<PokeProductBooster?, int>.from(p.boosters());
      _sideProducts       = Map<PokeProductSide, int>.from(p.sideProducts);
      _otherCards         = List<PokeProductCard>.from(p.otherCards);
      _nbRandomPerProduct = p.nbRandomPerProduct;
      _excludeLanguage    = List<PokeLanguage>.from(p.excludeLanguage());
      _location           = p.location();
      _honoredPokemon     = List<PokeFullCardPokemon>.from(p.honoredPokemon());
      _honoredOther       = List<PokeIdentifier>.from(p.honoredOther());
      _releaseDate        = p.releaseDate;
    } else {
      _category           = widget._nav.collection.productCategories().first;
      _pid                = newProductId();
    }

    updateNav();

    _langueController = CustomRadioController(
      initialValue: _location,
      onChange: (value){
        setState(() {
          if( value != _location) {
            _location = value;
            _excludeLanguage.clear();
            updateNav();
          }
        }
        );
    });
    super.initState();
  }

  void updateNav() {
    PokeLanguage l = widget._nav.collection.languagesBy(_location).first;
    nav = PokeNavLanguage( widget._nav.collection, widget._nav.rendering, l );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _releaseDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1998),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        _releaseDate = picked;
      });
    }
  }

  void sendProduct() {
    final newProduct = PokeProduct(_pid, _category, _releaseDate, "", _boosters, _sideProducts, _otherCards, _nbRandomPerProduct, _location, _excludeLanguage, _honoredPokemon, _honoredOther);

    if ( newProduct.validate() && _formKey.currentState!.validate()) {
      EasyLoading.show();

      widget._nav.database.transactionR( (connection) {
        return widget._nav.collection.sendProducts(connection,[newProduct], widget.editProduct == null);
      }).then((value) {
        if(value) {
          // Reload all products and admin stuff
          Environment.instance.restoreAdminData().then((value) {
            EasyLoading.dismiss();
            Navigator.popUntil(context, ModalRoute.withName('/'));
          });
        } else {
          EasyLoading.showError("Erreur produit");
        }

      }).onError((errorInfo, stackTrace) {
        error = errorInfo.toString();
        EasyLoading.showError(error!);
      });
    }
  }

  Widget infoProduct() {
    return SizedBox(
      height: 200,
      child: Card(
        color: PokeRendering.colorLightCard,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: PokeRendering.spacing,
            children: [
              PokeRendering.productImage(_pid, alternativeRendering: Text("${_pid.id()}"), photoView: true),
              Card(
                child: TextButton(
                  onPressed: () { _selectDate(context); },
                  child: Text(DateFormat('yyyy-MM-dd').format(_releaseDate)),
                )
              ),
              DropdownButton<PokeProductCategory>(
                value: _category,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                onChanged: (PokeProductCategory? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    _category = value!;
                  });
                },
                items: widget._nav.collection.productCategories().map<DropdownMenuItem<PokeProductCategory>>((PokeProductCategory value) {
                  return DropdownMenuItem<PokeProductCategory>(value: value, child: Text(value.name(widget._nav.showLanguage)));
                }).toList(),
              )
            ],
          ),
        ),
      )
    );
  }

  Widget sideProductsPanel() {
    return SizedBox(
      height: 200,
      child: Card(
        color: PokeRendering.colorLightCard,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _sideProducts.length + 1,
            itemBuilder: (context, index) {
              if( index < _sideProducts.length) {
                final sideProductInfo = _sideProducts.entries.elementAt(index);
                return SizedBox(
                  width: 200,
                  child: SideProductCount(widget._nav.showLanguage, _sideProducts, sideProductInfo.key, (){ setState(() {}); })
                );
              } else {
                return Card(
                  color: Colors.blueAccent,
                  child: TextButton(
                    child: const Center( child: Icon(Icons.add_shopping_cart) ),
                    onPressed: () {
                      setState(() {
                        showDialog(context: context, builder: (context) => SimpleDialog(
                          titlePadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.zero,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/4,
                              height: MediaQuery.of(context).size.height-MediaQuery.of(context).size.height/4,
                              child: WidgetSelectorSideProduct(nav)
                            )
                          ]
                        )).then((selection) {
                          if(selection) {
                            setState(() {
                              _sideProducts[selection] = 1;
                            });
                          }
                        });
                      });
                    }
                  ),
                );
              }
            },
          )
        )
      )
    );
  }

  Widget additionalCardsPanel() {
    return SizedBox(
      height: 200,
      child: Card(
        color: PokeRendering.colorLightCard,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: SpinBox(
                  value: _nbRandomPerProduct.toDouble(),
                  min: 0,
                  max: 5,
                  decoration: const InputDecoration(labelText: 'Nombre de cartes aléatoires'),
                  onChanged: (value) {
                    _nbRandomPerProduct = value.toInt();
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _otherCards.length + 1,
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index){
                    if(index < _otherCards.length) {
                      final otherCard = _otherCards[index];
                      var selector = PokeCardSelectorInProduct(nav.language, otherCard);
                      return WidgetSelectorCardViewer(nav, selector,
                          refresh: (){ setState(() {
                            if( otherCard.counter.count() == 0 ) {
                              _otherCards.remove(otherCard);
                            }
                          });
                          },
                          readOnly: false, singlePress: true
                      );
                    } else {
                      return Card(
                        color: Colors.deepOrange.shade300,
                        child: TextButton(
                          child: const Center( child: Icon(Icons.add_photo_alternate_outlined) ),
                          onPressed: () {
                            setState(() {
                              showDialog(context: context, builder: (context) => SimpleDialog(
                                titlePadding: EdgeInsets.zero,
                                contentPadding: EdgeInsets.zero,
                                insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/4,
                                    height: MediaQuery.of(context).size.height-MediaQuery.of(context).size.height/4,
                                    child: WizardSelectUntilCard(nav.language)
                                  )
                                ]
                              )).then((selection) {
                                if(selection != null) {
                                  setState(() {
                                    for(final PokeCardIdentifier cardId in selection.selectedCards) {
                                      final PokeExpansion exp = selection.expansion;
                                      final card = exp.cards.cardFromId(cardId);
                                      var counter = PokeCardDraw.fromPokeCardExtension(card);
                                      counter.setCount(1, card.setInfo.keys.first);
                                      _otherCards.add( PokeProductCard(exp, cardId, AlternativeDesign.basic, false, false, counter));
                                    }
                                  });
                                }
                              });
                            });
                          }
                        )
                      );
                    }
                  },
                ),
              ),
            ],
          )
        )
      ),
    );
  }
  
  Widget languagePanel() {
    List<Widget> languages = [];
    for(final language in widget._nav.collection.languagesBy(_location))
    {
      languages.add(WidgetLanguageCheck(_excludeLanguage, language));
    }

    return Card(
      color: PokeRendering.colorLightCard,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          spacing: PokeRendering.spacing,
          children: [
            CustomRadio(value: CardLocation.Monde, controller: _langueController, widget: Icon(Icons.language, size: 30.0)),
            CustomRadio(value: CardLocation.Asie,  controller: _langueController, widget: Icon(Icons.rice_bowl, size: 30.0)),
            SizedBox(width: 16.0),
            Text("Liste d'exclusion:"),
          ] + languages
        ),
      )
    );
  }

  Widget boosterCount(PokeNavLanguage nav, PokeProductBooster? booster, int count) {
    return SizedBox(
      width: 150.0,
      height: 300.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: PokeRendering.spacing,
            children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(0.0, 40.0)),
                child: (booster != null) ? booster.widget(context, 0, nav.language) : const Icon(Icons.add_to_photos),
                onPressed: (){
                  setState(() {
                    showDialog(context: context, builder: (context) => SimpleDialog(
                      titlePadding: EdgeInsets.zero,
                      contentPadding: EdgeInsets.zero,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width-50.0,
                          height: MediaQuery.of(context).size.height-50.0,
                          child: WidgetSelectorBooster(nav, ( PokeProductBooster booster ) {
                            Navigator.of(context).pop();
                            if( !_boosters.containsKey(booster) ) {
                              setState(() {
                                _boosters[booster] = 1;
                              });
                            }
                          } ),
                        )
                      ],
                    )
                    );
                  });
                },
              ),
            ),
            SpinBox(
              value: count.toDouble(),
              min: 0,
              max: 50,
              decoration: const InputDecoration(labelText: 'Boosters'),
              onChanged: (value) {
                if(value.isZero) {
                  setState(() {
                    _boosters.remove(booster);
                  });
                } else {
                  _boosters[booster] = value.toInt();
                }
              },
            ),
          ]
          ),
        )
      ),
    );
  }

  Widget boostersPanel()
  {
    return SizedBox(
      height: 250.0,
      child: Card(
        color: PokeRendering.colorLightCard,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
            if(index < _boosters.length) {
              final booster = _boosters.entries.elementAt(index);
              return boosterCount(nav, booster.key, booster.value);
            } else {
              return Card(
                child: TextButton(
                  child: const Center( child: Icon(Icons.add_to_photos) ),
                  onPressed: () {
                    setState(() {
                      _boosters[null] = 1;
                    });
                  },
                ),
              );
            }
          },
          separatorBuilder: (context, index) => const SizedBox(width: PokeRendering.spacing),
          itemCount: _boosters.length + 1)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
/*
    if(product.category == null) {
      formular.add(Card( child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(''),
          ]+radioCat) ));
    }
    */

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editProduct != null ? AppLocalizations.of(context)!.np_t1 : AppLocalizations.of(context)!.np_t0),
        actions: [
          Card(
            color: Colors.green,
            child: TextButton(
              onPressed: _boosters.isEmpty ? null : sendProduct,
              child: const Text('Envoyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              infoProduct(),
              languagePanel(),
              boostersPanel(),
              sideProductsPanel(),
              additionalCardsPanel(),
              if(error != null)
                Text(error!),
            ],
          )
        ),
      )
    );
  }
}

class SideProductCount extends StatefulWidget {
  final PokeLanguage _language;
  final Map<PokeProductSide, int> mapSideProduct;
  final PokeProductSide productSide;
  final Function    refresh;

  const SideProductCount(this._language, this.mapSideProduct, this.productSide, this.refresh, {super.key});

  @override
  State<SideProductCount> createState() => _SideProductCountState();
}

class _SideProductCountState extends State<SideProductCount> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child: Column(
        spacing: PokeRendering.spacing,
        children: [
          Expanded(
            child: widget.productSide.image(
              alternativeRendering: Text(widget.productSide.name(widget._language), softWrap: true, style:Theme.of(context).textTheme.titleLarge)
            )
          ),
          SpinBox(
            value: widget.mapSideProduct[widget.productSide]!.toDouble(),
            min: 0,
            max: 255,
            textStyle: const TextStyle(fontSize: 13),
            onChanged: (value) {
              if(value.toInt() == 0) {
                widget.mapSideProduct.remove(widget.productSide);
                widget.refresh();
              }
              else {
                widget.mapSideProduct[widget.productSide] = value.toInt();
              }
            },
          ),
        ]
      )
    );
  }
}


