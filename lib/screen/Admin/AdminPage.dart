import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/Admin/newCardExtensions.dart';
import 'package:statitikcard/screen/Admin/newProduct.dart';
import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/PokeSpace/DrawHistory.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/product.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool demanded = false;

  @override
  void initState() {
    Environment.instance.db.transactionR( (connection) async {
        String query = "SELECT `idDemande` FROM Demande;";
        var exts = await connection.query(query);
        for(var _ in exts) {
          demanded = true;
        }
      }
    ).then((value){
      setState(() {});
    });

    super.initState();
  }

  void cleanOrphan() {
    var orphans = Environment.instance.collection.searchOrphanCard();
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            title: new Text(StatitikLocale.of(context).read('warning')),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text( sprintf(StatitikLocale.of(context).read('CA_B33'), [orphans.length]),
                      textAlign: TextAlign.justify),
                  if(orphans.isNotEmpty) Card(
                      color: Colors.red,
                      child: TextButton(
                          child: Text(StatitikLocale.of(context).read('yes')),
                          onPressed: () {
                            // Remove card
                            Environment.instance.removeOrphans(orphans).then((value) {
                              if(value) {
                                // Reload full database to have all real data
                                Environment.instance.restoreAdminData().then( (value){
                                  Navigator.pop(context);
                                });
                              }
                            });
                          }
                      )
                  )
                ]
            )
        )
    );
  }

  void goToProductPage(BuildContext context, Language language, SubExtension subExt) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.AllSelection, language: language, subExt: subExt, afterSelected: afterSelectProduct) ));
  }

  void afterSelectProduct(BuildContext context, Language language, ProductRequested? product, ProductCategory? category) {
    // Go to page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NewProductPage(product!.product))).then( (value)
    {
      setState(() {});
    });
  }

  Widget createButton(String codeText, IconData icon, Color colorBox, Function() action) {
    return Card(
      color: colorBox,
      child: TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon,
              color: Colors.white,
              size: 50,
            ),
            Text(StatitikLocale.of(context).read(codeText)),
          ],
        ),
        onPressed: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(createButton('ADMIN_B0', Icons.add_shopping_cart, Colors.lightGreen, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => NewProductPage()));
    }));
    buttons.add(createButton('ADMIN_B1', Icons.shopping_cart_outlined, Colors.green.shade700, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage, addMode: true)));
    }));
    buttons.add(createButton('ADMIN_B2', Icons.post_add_outlined, Colors.deepOrange, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => NewCardExtensions()));
    }));
    buttons.add(createButton('ADMIN_B3', Icons.remove_red_eye_rounded, Colors.blueAccent, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DrawHistory(true)));
    }));
    buttons.add(createButton('ADMIN_B4', Icons.delete_forever, Colors.orangeAccent, cleanOrphan));
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text( StatitikLocale.of(context).read('H_T4'), style: Theme.of(context).textTheme.headline3 )),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if(demanded)
                  Card(
                    color: Colors.red.shade900,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded),
                          Text(StatitikLocale.of(context).read('ADMIN_B5'), style: Theme.of(context).textTheme.headline5)
                        ]
                      )
                    )
                  ),
                Card(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row( children: [
                    Text(StatitikLocale.of(context).read('O_B2')),
                    Checkbox(value: useDebug,
                        onChanged: (newValue) {
                          useDebug = newValue!;
                          EasyLoading.show();
                          Environment.instance.restoreAdminData().then((value){
                            setState(() {});
                            EasyLoading.dismiss();
                          });
                        }
                    ),
                    Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey, // background
                          ),
                          onPressed: () {
                            EasyLoading.show();
                            Environment.instance.restoreAdminData().then((value) {
                              EasyLoading.dismiss();
                            });
                          },
                          child: Text(StatitikLocale.of(context).read('O_B1'))
                      ),
                    ),
                  ]
                  ),
                )),

                GridView.count(crossAxisCount: 3,
                  children: buttons,
                  primary: false,
                  shrinkWrap: true,
                ),
              ],
            )
          )
        )
    );
  }
}
