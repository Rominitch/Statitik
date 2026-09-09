import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/poke_admin.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product.dart';
import 'package:statitikcard/screenOld/Admin/extension_products_creator.dart';
import 'package:statitikcard/screenOld/Admin/rarity_editor.dart';
import 'package:statitikcard/screenOld/Admin/side_product_creator.dart';
import 'package:statitikcard/screenOld/Admin/new_card_extensions.dart';

import 'package:statitikcard/screenOld/commonPages/language_page.dart';
import 'package:statitikcard/screenOld/PokeSpace/draw_history.dart';
import 'package:statitikcard/screens/admin/page_admin_create_side_product.dart';
import 'package:statitikcard/screens/admin/page_admin_edit_expansion.dart';
import 'package:statitikcard/screens/admin/page_admin_edit_product.dart';
import 'package:statitikcard/screens/expansions/page_expansion_explorer.dart';
import 'package:statitikcard/screens/products/page_products_explorer.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/widgets/expansion/widget_expansions_selector.dart';

class PageAdminMenu extends StatefulWidget {
  final PokeCollection _collection;
  final PokeRendering  _rendering;
  final Database       _db;

  const PageAdminMenu(this._collection, this._rendering, this._db, {super.key});

  @override
  State<PageAdminMenu> createState() => _PageAdminMenuState();
}

enum AdminPage {
  menu,
  addProduct,
  editProduct,
  addSideProduct,
  editExpansion
}

class _PageAdminMenuState extends State<PageAdminMenu> {
  bool demanded = false;
  final PokeAdmin  _admin = PokeAdmin();

  AdminPage _page = AdminPage.menu;
  String _pageTitle = "";

  @override
  void initState() {
    /*
    Environment.instance.db.transactionR( (connection) async {
      String query = "SELECT `idDemande` FROM Demande;";
      var exts = await connection.query(query);
      demanded = exts.isNotEmpty;
    }
    ).then((value){
      setState(() {});
    });
    */
    super.initState();
  }

  void onReturn() {
    setState(() {
      _page = AdminPage.menu;
    });
  }

  void cleanOrphan() {
    var orphans = Environment.instance.collection.searchOrphanCard();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.warning),
            content: Column(
                children: [
                  Text( sprintf(AppLocalizations.of(context)!.ca_b33, [orphans.length]),
                      textAlign: TextAlign.justify),
                  if(orphans.isNotEmpty) Card(
                      color: Colors.red,
                      child: TextButton(
                          child: Text(AppLocalizations.of(context)!.yes),
                          onPressed: () {
                            try {
                              EasyLoading.show();
                              // Remove card
                              Environment.instance.removeOrphans(orphans).then((
                                  value) {
                                EasyLoading.dismiss();
                                if (value) {
                                  // Reload full database to have all real data
                                  Environment.instance.restoreAdminData().then((
                                      value) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              });
                            }
                            catch(e)
                            {
                              EasyLoading.dismiss();
                            }
                          }
                      )
                  )
                ]
            )
        )
    );
  }

  void goToExtensionProducts(BuildContext context, LanguageOld language, SubExtension subExt) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionProductsCreator(language, subExt) ));
  }

  void launchEditionCards() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(
        afterSelected: (BuildContext context, LanguageOld language, SubExtension subExtension) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewCardExtensions(language, subExtension) ));
        }, addMode: false)));
  }

  Widget createButton(String codeText, IconData icon, Color colorBox, AdminPage pageId) {
    return Card(
      color: colorBox,
      child: TextButton(
        onPressed: () {
          setState(() {
            _pageTitle = codeText;
            _page = pageId;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon,
              color: Colors.white,
              size: 50,
            ),
            Text(codeText),
          ],
        ),
      ),
    );
  }

  Widget menuPage() {
    List<Widget> buttons = [];
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B0, Icons.add_shopping_cart, Colors.lightGreen, AdminPage.addProduct ));
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B1, Icons.shopping_cart_outlined, Colors.green.shade700, AdminPage.editProduct));
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B6, Icons.shopping_bag_outlined, Colors.greenAccent.shade700, AdminPage.addSideProduct));
    //buttons.add(createButton(AppLocalizations.of(context)!.admin_B7, Icons.my_library_add_outlined, Colors.lightGreenAccent.shade700, AdminPage.editProductExpansion));

    buttons.add(createButton(AppLocalizations.of(context)!.admin_B2, Icons.post_add_outlined, Colors.deepOrange, AdminPage.editExpansion));
/*
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B2, Icons.post_add_outlined, Colors.deepOrange, () {
      launchEditionCards();
    }));
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B3, Icons.remove_red_eye_rounded, Colors.blueAccent, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawHistory(true)));
    }));
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B8, Icons.diamond_outlined, Colors.deepPurpleAccent, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RarityEditor()));
    }));
    buttons.add(createButton(AppLocalizations.of(context)!.admin_B4, Icons.delete_forever, Colors.orangeAccent, cleanOrphan));
*/
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text( AppLocalizations.of(context)!.h_t4, style: Theme.of(context).textTheme.displaySmall )),
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
                                    const Icon(Icons.warning_amber_rounded),
                                    Text(AppLocalizations.of(context)!.admin_B5, style: Theme.of(context).textTheme.headlineSmall)
                                  ]
                              )
                          )
                      ),
                    /*
              Card(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row( children: [
                  Text(AppLocalizations.of(context)!.o_b2),
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
                        child: Text(AppLocalizations.of(context)!.o_b1)
                    ),
                  ),
                ]
                ),
              )),
              */
                    Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final count = (constraints.maxWidth / 175).ceil();
                          return GridView.count(crossAxisCount: count,
                            children: buttons,
                          );
                        })
                    )
                  ],
                )
            )
        )
    );
  }
  PokeNavAdmin navAdmin(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l = widget._collection.language( Language.fromLocale(locale) );
    return PokeNavAdmin(widget._collection, widget._rendering, widget._db, l);
  }

  AppBar mainAppBar() {
    return AppBar(
        title: Text(_pageTitle, style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          onPressed: () {
            setState(() {
              _page = AdminPage.menu;
            });
          },
          icon: Icon(Icons.arrow_back),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_page == AdminPage.menu)
    {
      return menuPage();
    }

    Widget mainPage;
    switch( _page )
    {
      case AdminPage.menu: throw "Impossible";

      case AdminPage.editProduct:
        {
          mainPage = PageProductsExplorer(widget._collection, widget._rendering,
            (PokeNavLanguage nav, PokeProduct product, Function() onReturn) {
              return PageAdminEditProduct.edit(navAdmin(context), product);
            });
        }
    //Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage, addMode: true)));

      case AdminPage.addSideProduct:
        mainPage = PageAdminCreateSideProduct(navAdmin(context));
    //Navigator.push(context, MaterialPageRoute(builder: (context) => SideProductCreator(Environment.instance.collection.languages[1]!)));

      case AdminPage.addProduct:
        mainPage = menuPage();

      case AdminPage.editExpansion:
        {
          return PageExpansionExplorer(mainAppBar(), (selection) {
            return PageAdminEditExpansion(navAdmin(context), selection, onReturn );
          });
        }
    //Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToExtensionProducts, addMode: true)));
    }

    return Scaffold(
      appBar: mainAppBar(),
      body: mainPage,
    );
  }
}
