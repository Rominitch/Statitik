import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/commonPages/sideProductSelection.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/screen/widgets/CardsSelection.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class NewProductPage extends StatefulWidget {
  final Language activeLanguage;
  final Product? editProduct;

  NewProductPage([this.editProduct, Language? l]) :
    activeLanguage = (l != null ? l : Environment.instance.collection.languages[1]!);

  @override
  _NewProductPageState createState() => _NewProductPageState();
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
    if(widget.editProduct != null)
      product = widget.editProduct!;

    radioLangue.clear();
    for( Language l in Environment.instance.collection.languages.values)
    {
      radioLangue.add(
        Expanded(
          child: Container(
            child: TextButton(
              child: Image(
                image: AssetImage('assets/langue/${l.image}.png'),
              ),
              onPressed: () {
                setState(() {
                  product.language = l;
                });
              },
            ),
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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: product.outDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        product.outDate = picked;
      });
  }

  void sendProduct() {
    if ( product.validate() && _formKey.currentState!.validate()) {
      error = null;
      try {
        EasyLoading.show();
        Environment env = Environment.instance;
        env.db.transactionR( (connection) async {

          var outDate = DateFormat('yyyy-MM-dd 00:00:00').format(product.outDate);
          String query;
          List myData = <Object?>[];
          if(widget.editProduct == null) {
            var req = await connection.query('SELECT count(idProduit) FROM `Produit`;');
            for (var row in req) {
              product.idDB = row[0] + 1;
            }
            query = 'INSERT INTO `Produit` (`idProduit`, `idLangue`, `nom`, `icone`, `sortie`, `idCategorie`, `contenu` )'
            ' VALUES (?, ?, ?, ?, ?, ?, ?);';
            myData += [product.idDB];
          } else {
            assert(product.idDB > 0);
            query = 'UPDATE `Produit` SET `idLangue` = ?, `nom`= ?, `icone`= ?, `sortie`= ?, `idCategorie`= ?, `contenu`= ?'
            ' WHERE `idProduit` = ${product.idDB};';
          }
          myData += [ product.language!.id, product.name, product.imageURL,
            outDate, product.category!.idDB,
            Int8List.fromList(product.toBytes())
          ];
          // Go
          await connection.queryMulti(query, [myData]);
        } ).then((value) {
          if(value) {
            EasyLoading.dismiss();
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
          else
            EasyLoading.showError("Erreur produit");
        }).onError((errorInfo, stackTrace) {
          error = errorInfo.toString();
          EasyLoading.showError(error!);
        });
      } catch (e) {
        printOutput(e.toString());
        EasyLoading.dismiss();
      }
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
          child: Center( child: Icon(Icons.add_shopping_cart) ),
          onPressed: () {
            // Go to product selector
            Navigator.push(context, MaterialPageRoute(builder: (context) => SideProductSelection(widget.activeLanguage))).then((value) {
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
    product.otherCards.forEach((otherCard) {
      cardsWidget.add(OtherCardCount(product, otherCard, (){ setState(() {}); }));
    });
    //
    cardsWidget.add(
        Card(
          color: Colors.deepOrange.shade300,
          child: TextButton(
            child: Center( child: Icon(Icons.add_photo_alternate_outlined) ),
            onPressed: () {
              // Go to product selector
              Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.activeLanguage,
                  afterSelected: (BuildContext context, Language language, SubExtension subExtension) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CardsSelection(language, subExtension)));
                  }, addMode: false))).then((value) {
                if(value != null) {
                  // Added only new product and refresh
                  setState(() {
                    var counter = CodeDraw.fromSet(value.card.sets.length);
                    counter.countBySet[0] = 1;
                    product.otherCards.add(ProductCard(value.subExtension, value.card, AlternativeDesign.Basic, false, counter) );
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
    if(product.language == null)
      formular.add(Card( child: Row( children: radioLangue) ));
    if(product.category == null)
      formular.add(Card( child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Text(''),
      ]+radioCat) ));
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
            child: Text(product.category!.name.name(widget.activeLanguage)),
          ))),
        ]),
        TextFormField(
          decoration: InputDecoration(
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
          decoration: InputDecoration(
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
            child: Text(DateFormat('yyyy-MM-dd').format(product.outDate)),
          )
        ),
      ] + bs + [
        GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          children: sideProductWidget,
          primary: false,
          shrinkWrap: true,
        ),
        GridView.count(
          crossAxisCount: 3,
          children: cardsWidget,
          childAspectRatio: 1.5,
          primary: false,
          shrinkWrap: true,
        ),
        if(error != null)
          Text(error!),
      ];
    }
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(StatitikLocale.of(context).read('NP_T0')),
        ),
        actions: [
          if(product.category != null && product.language != null)
            Card(
              color: Colors.green,
              child: TextButton(
                onPressed: sendProduct,
                child: Text('Envoyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    );
  }
}

class BoostersInfo extends StatefulWidget {
  final Function        productAdd;
  final ProductBooster? newProd;
  final Language        l;

  BoostersInfo(this.productAdd, this.newProd, this.l);

  @override
  _BoostersInfoState createState() => _BoostersInfoState();
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
              style: TextButton.styleFrom(minimumSize: Size(0.0, 40.0)),
              child: (widget.newProd!.subExtension != null) ? widget.newProd!.subExtension!.image(hSize: iconSize) : Icon(Icons.add_to_photos),
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
                decoration: InputDecoration(labelText: 'Boosters'),
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
                decoration: InputDecoration(labelText: 'Cartes'),
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
          child: Center( child: Icon(Icons.add_to_photos) ),
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
          widget.productSide.image(),
          Text(widget.productSide.name, softWrap: true, style: Theme.of(context).textTheme.headline6),
          SpinBox(
            value: widget.product.sideProducts[widget.productSide]!.toDouble(),
            min: 0,
            max: 255,
            textStyle: TextStyle(fontSize: 13),
            onChanged: (value) {
              if(value.toInt() == 0) {
                widget.product.sideProducts.remove(widget.productSide);
                widget.refresh();
              }
              else
                widget.product.sideProducts[widget.productSide] = value.toInt();
            },
          ),
        ]
      )
    );
  }
}

class OtherCardCount extends StatefulWidget {
  final Product     product;
  final ProductCard info;
  final Function    refresh;

  const OtherCardCount(this.product, this.info, this.refresh, {Key? key}) : super(key: key);

  @override
  State<OtherCardCount> createState() => _OtherCardCountState();
}

class _OtherCardCountState extends State<OtherCardCount> {
  @override
  Widget build(BuildContext context) {
    var idCard = widget.info.subExtension.seCards.computeIdCard(widget.info.card);
    return Card(
        color: Colors.deepOrange.shade300,
        child: TextButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widget.info.subExtension.image(hSize: 30),
                  widget.info.card.imageType(),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(widget.info.subExtension.seCards.numberOfCard(idCard[1])),
                  Text(widget.info.counter.countBySet.join(" | "))
                ]
              ),
            ],
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CardSelector(widget.info.subExtension, widget.info.card, widget.info.counter);
                }
            ).then((value) {
              setState(() {
                if(widget.info.counter.count() == 0) {
                  widget.product.otherCards.remove(widget.info);
                  widget.refresh();
                }
              });
            });
          }
        )
    );
  }
}


