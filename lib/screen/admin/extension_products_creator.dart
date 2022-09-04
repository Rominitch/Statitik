import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/screen/commonPages/extension_page.dart';
import 'package:statitikcard/screen/widgets/cards_selection.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/product.dart';

class ExtensionProductsCreator extends StatefulWidget {
  final Language     language;
  final SubExtension subExtension;

  const ExtensionProductsCreator(this.language, this.subExtension, {Key? key}) : super(key: key);

  @override
  State<ExtensionProductsCreator> createState() => _ExtensionProductsCreatorState();
}

enum ProductKind {
  booster,
  display,
  buildBattle,
  buildBattleStadium,
  etb,
  etbPokeCenter,
  etbAlternative,

  simplePack,
  triPack,
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
    return productSelected[ProductKind.buildBattle.index] || productSelected[ProductKind.buildBattleStadium.index];
  }

  bool isValid() {
    bool valid = true;
    if(hasRandomCard()) {
      valid = selection != null;
    }
    for (var element in simplePacks) { valid &= element.selection != null; }
    for (var element in triPacks) { valid &= element.selection != null; }
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

  ProductCard createCardProduct(SubExtension subExtension, idCard, random) {
    var code = CodeDraw.fromPokeCardExtension(subExtension.cardFromId(idCard));
    code.setCount(1, 0);
    return ProductCard(subExtension, idCard, AlternativeDesign.basic, false, random, code);
  }

  void createProducts() {
    EasyLoading.show();

    List<Product> products = [];
    if(productSelected[ProductKind.booster.index]) {
      products.add(createProduct(ProductKind.booster, 1));
    }
    if(productSelected[ProductKind.display.index]) {
      products.add(createProduct(ProductKind.display, widget.language.isWorld() ? 36 : 30));
    }
    if(productSelected[ProductKind.buildBattle.index]) {
      var p = createProduct(ProductKind.buildBattle, 4);
      p.nbRandomPerProduct = 1;
      for (var idCard in selection!.cards) {
        p.otherCards.add(createCardProduct(selection!.subExtension, idCard, true));
      }
      products.add(p);
    }
    if(productSelected[ProductKind.buildBattleStadium.index]) {
      var p = createProduct(ProductKind.buildBattleStadium, 12);
      p.nbRandomPerProduct = 2;
      for (var idCard in selection!.cards) {
        p.otherCards.add(createCardProduct(selection!.subExtension, idCard, true));
      }
      products.add(p);
    }
    for (var triPack in triPacks) {
      var p = createProduct(ProductKind.triPack, 3, triPack.name);
      for (var idCard in triPack.selection!.cards) {
        p.otherCards.add(createCardProduct(triPack.selection!.subExtension, idCard, false));
      }
      products.add(p);
    }
    for (var simplePack in simplePacks) {
      var p = createProduct(ProductKind.simplePack, 1, simplePack.name);
      for (var idCard in simplePack.selection!.cards) {
        p.otherCards.add(createCardProduct(simplePack.selection!.subExtension, idCard, false));
      }
      products.add(p);
    }

    if(productSelected[ProductKind.etb.index]) {
      var p = createProduct(ProductKind.etb, 8);
      products.add(p);
    }
    if(productSelected[ProductKind.etbAlternative.index]) {
      var p = createProduct(ProductKind.etbAlternative, 8);
      products.add(p);
    }
    if(productSelected[ProductKind.etbPokeCenter.index]) {
      var p = createProduct(ProductKind.etbPokeCenter, 10);
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
                  packSelector(ProductKind.simplePack, Colors.deepOrange, simplePacks),
                  //Tripack
                  packSelector(ProductKind.triPack, Colors.blueAccent, triPacks),
                ],
              )
            ),
          )
        )
      )
    );
  }
}
