import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/widgets/CardsSelection.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/PokemonCardData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/product.dart';

class ExtensionProductsCreator extends StatefulWidget {
  final Language     language;
  final SubExtension subExtension;

  const ExtensionProductsCreator(this.language, this.subExtension, {Key? key}) : super(key: key);

  @override
  State<ExtensionProductsCreator> createState() => _ExtensionProductsCreatorState();
}

enum ProductKind {
  Booster,
  Display,
  Build_Battle,
  Build_Battle_Stadium,
  ETB,
  ETB_PokeCenter,
  ETB2,

  SimplePack,
  TriPack,
}

const List<String> _languageCode = ["FR", "EN", "JP"];
const List<String> _productCode  = ["Booster", "Display", "BB", "BBS", "ETB", "ETB_Center", "ETB2", "", ""];
const List<int>    _categoryCode = [1,1,1,1,6,6,6,2,2];

class PackInfo
{
  String             name = "";
  CardSelectionData? selection;
}

class _ExtensionProductsCreatorState extends State<ExtensionProductsCreator> {
  static const maxKind = 7;
  List<bool> productSelected = List<bool>.generate(maxKind, (index) => true);

  CardSelectionData? selection;

  List<PackInfo> simplePacks = [];
  List<PackInfo> triPacks    = [];

  bool hasRandomCard() {
    return productSelected[ProductKind.Build_Battle.index] || productSelected[ProductKind.Build_Battle_Stadium.index];
  }

  bool isValid() {
    bool valid = true;
    if(hasRandomCard()) {
      valid = selection != null;
    }
    simplePacks.forEach((element) { valid &= element.selection != null; });
    triPacks.forEach((element) { valid &= element.selection != null; });
    return valid;
  }

  Widget buttonSelectCards(container, {size}) {
    return Card(
      color: container.selection != null ? Colors.green : Colors.deepOrange.shade300,
      child: TextButton(
        child: Center( child: container.selection != null
            ? Icon(Icons.check_box_outlined, size: size)
            : Icon(Icons.add_photo_alternate_outlined, size: size)
        ),
        onPressed: () {
          // Go to product selector
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.language,
              afterSelected: (BuildContext context, Language language, SubExtension subExtension) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CardsSelection(widget.language, subExtension)));
              }, addMode: false))).then((value) {
            if(value != null) {
              // Added only new product and refresh
              setState(() {
                container.selection = value;
              });
            }
          });
        },
      ),
    );
  }

  Widget packSelector(ProductKind kind, Color color, infoArray) {
    return Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(StatitikLocale.of(context).read('PROD_KIND_${kind.index}'), style: Theme.of(context).textTheme.headline5),
                  const Spacer(),
                  Card(
                    color: Colors.grey,
                    child: IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: (){
                      setState(() {
                        infoArray.add(PackInfo());
                      });
                    })
                  ),
                ],
              ),
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: infoArray.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 55,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            Text(StatitikLocale.of(context).read('EPC_B1')),
                            const SizedBox(width: 5),
                            Expanded(
                              child: TextFormField(
                                initialValue: infoArray[index].name,
                                onChanged: (value) {
                                  infoArray[index].name = value;
                                },
                              ),
                            ),
                            buttonSelectCards(infoArray[index], size: 18.0)
                          ],
                        ),
                      ),
                    ),
                  );
                }
              )
            ],
          ),
        )
    );
  }

  Product createProduct(ProductKind kind, int boosterCount, [String name=""]) {
    var image = "${_languageCode[widget.language.id-1]}_${widget.subExtension.icon}_${_productCode[kind.index]}$name";
    var product = Product(0, widget.language, StatitikLocale.of(context).read('PROD_KIND_${kind.index}'),
                          image,
                          widget.subExtension.out,
                          Environment.instance.collection.categories[_categoryCode[kind.index]],
                          [ProductBooster(widget.subExtension, boosterCount, widget.language.isWorld() ? 11 : 5)]);

    return product;
  }

  ProductCard createCardProduct(subExtension, card, random) {
    var code = CodeDraw.fromPokeCardExtension(card);
    code.setCount(1, 0);
    return ProductCard(subExtension, card, AlternativeDesign.Basic, false, random, code);
  }

  void createProducts() {
    EasyLoading.show();

    List<Product> products = [];
    if(productSelected[ProductKind.Booster.index]) {
      products.add(createProduct(ProductKind.Booster, 1));
    }
    if(productSelected[ProductKind.Display.index]) {
      products.add(createProduct(ProductKind.Display, widget.language.isWorld() ? 36 : 30));
    }
    if(productSelected[ProductKind.Build_Battle.index]) {
      var p = createProduct(ProductKind.Build_Battle, 4);
      p.nbRandomPerProduct = 1;
      selection!.cards.forEach( (card) {
        p.otherCards.add(createCardProduct(selection!.subExtension, card, true));
      });
      products.add(p);
    }
    if(productSelected[ProductKind.Build_Battle_Stadium.index]) {
      var p = createProduct(ProductKind.Build_Battle_Stadium, 12);
      p.nbRandomPerProduct = 2;
      selection!.cards.forEach( (card) {
        p.otherCards.add(createCardProduct(selection!.subExtension, card, true));
      });
      products.add(p);
    }
    triPacks.forEach((element) {
      var p = createProduct(ProductKind.TriPack, 3);
      selection!.cards.forEach( (card) {
        p.otherCards.add(createCardProduct(selection!.subExtension, card, false));
      });
    });
    simplePacks.forEach((element) {
      var p = createProduct(ProductKind.SimplePack, 1);
      selection!.cards.forEach( (card) {
        p.otherCards.add(createCardProduct(selection!.subExtension, card, false));
      });
    });

    if(productSelected[ProductKind.ETB.index]) {
      var p = createProduct(ProductKind.ETB, 8);
      products.add(p);
    }
    if(productSelected[ProductKind.ETB2.index]) {
      var p = createProduct(ProductKind.ETB2, 8);
      products.add(p);
    }
    if(productSelected[ProductKind.ETB_PokeCenter.index]) {
      var p = createProduct(ProductKind.ETB_PokeCenter, 10);
      products.add(p);
    }

    Environment.instance.sendProducts(products, true).then((value) {
      if(value) {
        // Reload all products and admin stuff
        Environment.instance.restoreAdminData();

        EasyLoading.dismiss();

        Navigator.of(context).pop();
      } else {
        EasyLoading.showError("Error");
      }
    }).onError((error, stackTrace)
    {
      EasyLoading.showError("Error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child:Scaffold(
        appBar: AppBar(
          title: Row(children: [
            widget.subExtension.image(wSize: 30),
            const SizedBox(width: 5),
            Text(StatitikLocale.of(context).read('ADMIN_B7'), style: Theme.of(context).textTheme.headline6),
          ]),
          actions: [
            if(isValid())
              Card(
                color: Colors.green,
                child: IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: createProducts,
                )
              )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1),
                    itemCount: maxKind,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var text = StatitikLocale.of(context).read('PROD_KIND_$index');
                      return Card(
                        color: productSelected[index] ? Colors.green : Colors.grey,
                        child: TextButton(child: Text(text, style: Theme.of(context).textTheme.headline6?.copyWith(
                          fontSize: text.length > 8 ? 12 : 20 )),
                          onPressed: () {
                            setState(() {
                              productSelected[index] = !productSelected[index];
                            });
                          },
                        )
                      );
                    }),
                  if( hasRandomCard() )
                    Card( child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Text(StatitikLocale.of(context).read('EPC_B0'), style: Theme.of(context).textTheme.headline5),
                          const Spacer(),
                          buttonSelectCards(this)
                        ],
                      ),
                    )
                  ),
                  //Simple pack
                  packSelector(ProductKind.SimplePack, Colors.deepOrange, simplePacks),
                  //Tripack
                  packSelector(ProductKind.TriPack, Colors.blueAccent, triPacks),
                ],
              )
            ),
          )
        )
      )
    );
  }
}
