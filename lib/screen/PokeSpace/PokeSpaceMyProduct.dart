import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/PokeSpace/PokeSpaceProductsExplorer.dart';
import 'package:statitikcard/screen/widgets/ProductSelector.dart';
import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';


class PokeSpaceMyProducts extends StatefulWidget {
  const PokeSpaceMyProducts({Key? key}) : super(key: key);

  @override
  State<PokeSpaceMyProducts> createState() => _PokeSpaceMyProductsState();
}

class _PokeSpaceMyProductsState extends State<PokeSpaceMyProducts> with TickerProviderStateMixin, WidgetsBindingObserver{
  late TabController langueController;
  List<int>          myProdLanguages = []; //Impossible to create a List<Language?> ???
  bool               needToSave=false;

  void configureTabController(int index) {
    myProdLanguages.clear();
    
    var mySpace = Environment.instance.user!.pokeSpace;
    mySpace.myLanguagesProduct().forEach((language) {
      myProdLanguages.add(language.id);
    });

    if(mySpace.mySideProducts.isNotEmpty) {
      myProdLanguages.add(-1); // Null product == side product
    }
    langueController = TabController(length: myProdLanguages.length,
      animationDuration: Duration.zero,
      initialIndex: index,
      vsync: this);
  }

  void afterUpdateProducts() {
    setState(() {
      needToSave = true;
      // Configure again tab
      configureTabController(langueController.previousIndex);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    configureTabController(0);

    super.initState();
  }

  void savePokeSpace() {
    if(needToSave) {
      printOutput("Save Pokespace");
      // Poke Space Save
      var pokeSpace = Environment.instance.user!.pokeSpace;
      Environment.instance.savePokeSpace(context, pokeSpace);
      needToSave = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused) {
      // Poke Space Save
      savePokeSpace();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> productTab      = [];
    List<Widget> languageWidgets = [];
    myProdLanguages.forEach( (idLanguage){
      var language;
      if(idLanguage >= 0) {
        language = Environment.instance.collection.languages[idLanguage];
        languageWidgets.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: language.barIcon(),
        ));
      } else {
        languageWidgets.add(const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.public),
        ));
      }
      productTab.add(PokeSpaceProductsExplorer(language, (){ needToSave = true; }));
    });

    return WillPopScope(
      onWillPop: () async {
        savePokeSpace();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(StatitikLocale.of(context).read('DC_B17'), style: Theme.of(context).textTheme.headline3),
          actions: [
            FloatingActionButton.small(
              backgroundColor: productMenuColor,
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder:
                  (context) => LanguageSelector((BuildContext c, Language l)
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductSelector(l)));
                    })
                  )
                ).then((selection) {
                  if(selection != null) {
                    EasyLoading.show();

                    var pokeSpace = Environment.instance.user!.pokeSpace;
                    selection.products.forEach((product, counter) {
                      pokeSpace.insertProduct(product, counter, addCardAndMore: selection.withSubProducts);
                    });
                    selection.sideProducts.forEach((product, counter) {
                      pokeSpace.insertSideProduct(product, counter);
                    });

                    // Poke Space Save
                    Environment.instance.savePokeSpace(context, pokeSpace);

                    // Refresh
                    afterUpdateProducts();
                  }
                });
              },
              child: const Icon(Icons.add_shopping_cart, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: productTab.isEmpty
            ? SingleChildScrollView(
              child:Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          Text(StatitikLocale.of(context).read('PSMP_B0'), style: Theme.of(context).textTheme.headline6),
                          const SizedBox(width: 5.0),
                          const Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                          const SizedBox(width: 15.0),
                        ]
                      ),
                      const SizedBox(height: 40),
                      drawNothing(context, 'PSMP_B1')
                    ]
                ),
              )
            )
          : Column(
            children: [
              TabBar(
                controller: langueController,
                indicatorPadding: const EdgeInsets.all(1),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                tabs: languageWidgets
              ),
              Expanded(
                child: TabBarView(
                  controller: langueController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: productTab,
                )
              )
            ]
          ),
        ),
      ),
    );
  }
}
