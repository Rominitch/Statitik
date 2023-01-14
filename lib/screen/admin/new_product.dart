import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinbox/material.dart';

import 'package:intl/intl.dart';

import 'package:statitikcard/screen/commonPages/extension_page.dart';
import 'package:statitikcard/screen/commonPages/side_product_selection.dart';
import 'package:statitikcard/screen/widgets/CardSelector/card_selector_product_card.dart';
import 'package:statitikcard/screen/widgets/cards_selection.dart';
import 'package:statitikcard/screen/widgets/pokemon_card.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

class NewProductPage extends StatefulWidget {
  final Language activeLanguage;
  final Product? editProduct;

  NewProductPage([this.editProduct, Language? l, key]) :
    activeLanguage = (l ?? Environment.instance.collection.languages[1]!),
    super(key: key);

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = GlobalKey<FormState>();

  Product       product     = Product.empty();
  List<Widget>  radioCat    = [];
  List<Widget>  radioLangue = [];

  String? error;

  void onAdd()
  {
    setState(() {
      product.boosters.add(ProductBooster(null, 1, product.language!.isJapanese() ? 5 : 11));
    });
  }

  @override
  void initState() {
    if(widget.editProduct != null) {
      product = widget.editProduct!;
    }

    radioLangue.clear();
    for( Language l in Environment.instance.collection.languages.values)
    {
      radioLangue.add(
        Expanded(
          child: TextButton(
            child: Image(
              image: AssetImage('assets/langue/${l.image}.png'),
            ),
            onPressed: () {
              setState(() {
                product.language = l;
              });
            },
          )
        )
      );
    }

    radioCat.clear();
    Environment.instance.collection.categories.forEach((idDB, category) {
      if(category.isContainer) {
        radioCat.add(
          RadioListTile<ProductCategory>(
            title: Text(category.name.name(widget.activeLanguage)),
            value: category,
            groupValue: product.category,
            onChanged: (ProductCategory? value) {
              setState(() {
                product.category = value!;
              });
            },
          )
        );
      }
    });
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: product.releaseDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1998),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        product.releaseDate = picked;
      });
    }
  }

  void sendProduct() {
    if ( product.validate() && _formKey.currentState!.validate()) {
      EasyLoading.show();

      Environment.instance.sendProducts([product], widget.editProduct == null).then((value) {
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

  void duplicateProduct() {
    if ( product.validate() && _formKey.currentState!.validate()) {
      EasyLoading.show();

      Environment.instance.duplicateProducts(product).then((value) {
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

  List<Widget> fillSideProducts() {
    List<Widget>  sideProductWidget = [];
    sideProductWidget.clear();
    product.sideProducts.forEach((productSide, value) {
      sideProductWidget.add(SideProductCount(product, productSide, (){ setState(() {}); }));
    });
    //
    sideProductWidget.add(
      Card(
        color: Colors.blueAccent,
        child: TextButton(
          child: const Center( child: Icon(Icons.add_shopping_cart) ),
          onPressed: () {
            // Go to product selector
            Navigator.push(context, MaterialPageRoute(builder: (context) => SideProductSelection(product.language!, edition: true, productInfo: product))).then((value) {
              if(value != null) {
                // Added only new product and refresh
                if( !product.sideProducts.containsKey(value) ) {
                  setState(() {
                    product.sideProducts[value] = 1;
                  });
                }
              }
            });
          },
        ),
      )
    );
    return sideProductWidget;
  }

  List<Widget> fillAdditionalCards() {
    List<Widget>  cardsWidget = [];
    cardsWidget.clear();
    for (var otherCard in product.otherCards) {
      var selector = CardSelectorProductCard(otherCard);
      cardsWidget.add(PokemonCard(selector,
        refresh: (){ setState(() {
          if( otherCard.counter.count() == 0 ) {
            product.otherCards.remove(otherCard);
          }
            });
        },
        readOnly: false, singlePress: true));
    }
    //
    cardsWidget.add(
        Card(
          color: Colors.deepOrange.shade300,
          child: TextButton(
            child: const Center( child: Icon(Icons.add_photo_alternate_outlined) ),
            onPressed: () {
              // Go to product selector
              Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: product.language!,
                  afterSelected: (BuildContext context, Language language, SubExtension subExtension) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CardsSelection(language, subExtension)));
                  }, addMode: false))).then((value) {
                if(value != null) {
                  // Added only new product and refresh
                  setState(() {
                    value.cards.forEach((cardId){
                      var card = value.subExtension.cardFromId(cardId);
                      var counter = CodeDraw.fromPokeCardExtension(card);
                      counter.setCount(1, 0);
                      product.otherCards.add(ProductCard(value.subExtension, cardId, AlternativeDesign.basic, false, false, counter) );
                    });
                  });
                }
              });
            },
          ),
        )
    );
    return cardsWidget;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formular = [];
    if(product.language == null) {
      formular.add(Card( child: Row( children: radioLangue) ));
    }
    if(product.category == null) {
      formular.add(Card( child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        const Text(''),
      ]+radioCat) ));
    }
    if(product.category != null && product.language != null) {
      List<Widget> bs=[];
      for(ProductBooster booster in product.boosters) {
        bs.add(BoostersInfo(onAdd, booster, product.language!));
      }
      bs.add(BoostersInfo(onAdd, null, product.language!));

      var sideProductWidget = fillSideProducts();
      var cardsWidget       = fillAdditionalCards();

      formular = [
        Row(children: [
          product.language!.barIcon(),
          Expanded(child: Card(child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(product.category!.name.name(product.language!)),
          ))),
        ]),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Nom du produit'
          ),
          initialValue: product.name,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Veuillez donner un nom.';
            }
            product.name = value;
            return null;
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Image'
          ),
          initialValue: product.imageURL,
          validator: (value) {
            product.imageURL = value ?? "";
            return null;
          },
        ),
        Card(
          child: TextButton(
            onPressed: () { _selectDate(context); },
            child: Text(DateFormat('yyyy-MM-dd').format(product.releaseDate)),
          )
        ),
      ] + bs + [
        GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          primary: false,
          shrinkWrap: true,
          children: sideProductWidget,
        ),
        SpinBox(
          value: product.nbRandomPerProduct.toDouble(),
          min: 0,
          max: 5,
          decoration: const InputDecoration(labelText: 'Nombre de cartes aléatoires'),
          onChanged: (value) {
            product.nbRandomPerProduct = value.toInt();
          },
        ),
        GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          primary: false,
          shrinkWrap: true,
          children: cardsWidget,
        ),
        if(error != null)
          Text(error!),
      ];
    }
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child:Scaffold(
        appBar: AppBar(
          title: Text(StatitikLocale.of(context).read( widget.editProduct != null ? 'NP_T1' : 'NP_T0')),
          actions: [
            if(widget.editProduct != null && widget.editProduct!.language!.isWorld())
              Card(
                color: Colors.pink.shade900,
                child: TextButton(
                  onPressed: duplicateProduct,
                  child: const Text('Copie\nMonde', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            if(product.category != null && product.language != null)
              Card(
                color: Colors.green,
                child: TextButton(
                  onPressed: sendProduct,
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
              children: formular,
            )
          ),
        )
      )
    );
  }
}

class BoostersInfo extends StatefulWidget {
  final Function        productAdd;
  final ProductBooster? newProd;
  final Language        l;

  const BoostersInfo(this.productAdd, this.newProd, this.l, {Key? key}) : super(key: key);

  @override
  State<BoostersInfo> createState() => _BoostersInfoState();
}

class _BoostersInfoState extends State<BoostersInfo> {

  void afterSelected(BuildContext context, Language language, SubExtension subExt) {
    Navigator.pop(context);
    setState(() {
      widget.newProd!.subExtension = subExt;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.newProd != null) {
      return Card(
          child: Row(children: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(0.0, 40.0)),
              child: (widget.newProd!.subExtension != null) ? widget.newProd!.subExtension!.image(hSize: iconSize) : const Icon(Icons.add_to_photos),
              onPressed: (){
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.l, afterSelected: afterSelected, addMode: false)));
                });
              },
            ),
            Expanded(
              child: SpinBox(
                value: widget.newProd!.nbBoosters.toDouble(),
                min: 1,
                max: 50,
                decoration: const InputDecoration(labelText: 'Boosters'),
                onChanged: (value) {
                  widget.newProd!.nbBoosters = value.toInt();
                },
              ),
            ),
            Expanded(
              child: SpinBox(
                value: widget.newProd!.nbCardsPerBooster.toDouble(),
                min: 1,
                max: 15,
                decoration: const InputDecoration(labelText: 'cartes'),
                onChanged: (value) {
                  widget.newProd!.nbCardsPerBooster = value.toInt();
                },
              ),
            ),
          ])
      );
    } else {
      return Card(
        child: TextButton(
          child: const Center( child: Icon(Icons.add_to_photos) ),
          onPressed: () {
            widget.productAdd();
          },
        ),
      );
    }
  }
}

class SideProductCount extends StatefulWidget {
  final Product     product;
  final ProductSide productSide;
  final Function    refresh;

  const SideProductCount(this.product, this.productSide, this.refresh, {Key? key}) : super(key: key);

  @override
  State<SideProductCount> createState() => _SideProductCountState();
}

class _SideProductCountState extends State<SideProductCount> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          widget.productSide.image(
              alternativeRendering: Text(widget.productSide.name, softWrap: true, style:Theme.of(context).textTheme.headline6)
          ),
          SpinBox(
            value: widget.product.sideProducts[widget.productSide]!.toDouble(),
            min: 0,
            max: 255,
            textStyle: const TextStyle(fontSize: 13),
            onChanged: (value) {
              if(value.toInt() == 0) {
                widget.product.sideProducts.remove(widget.productSide);
                widget.refresh();
              }
              else {
                widget.product.sideProducts[widget.productSide] = value.toInt();
              }
            },
          ),
        ]
      )
    );
  }
}


