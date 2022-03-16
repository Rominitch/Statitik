import 'package:flutter/material.dart';
import 'package:statitikcard/screen/PokeSpace/PokeSpaceProductsExplorer.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';


class PokeSpaceMyProducts extends StatefulWidget {
  const PokeSpaceMyProducts({Key? key}) : super(key: key);

  @override
  State<PokeSpaceMyProducts> createState() => _PokeSpaceMyProductsState();
}

class _PokeSpaceMyProductsState extends State<PokeSpaceMyProducts> with SingleTickerProviderStateMixin {
  late TabController langueController;
  List<Language?>    languages = [];

  void configureTabController(int index) {
    var mySpace = Environment.instance.user!.pokeSpace;
    languages = mySpace.myLanguagesProduct();
    if(mySpace.mySideProducts.isNotEmpty)
      languages.add(null); // Null product == side product
    langueController = TabController(length: languages.length,
      animationDuration: Duration.zero,
      initialIndex: index,
      vsync: this);
  }

  void afterUpdateProducts() {

  }

  @override
  void initState() {
    configureTabController(0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> productTab = [];
    List<Widget> langueWidgets = [];
    languages.forEach( (language){
      if(language != null) {
        langueWidgets.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: language.barIcon(),
        ));
      } else {
        langueWidgets.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.public),
        ));
      }
      productTab.add(PokeSpaceProductsExplorer(language, afterUpdateProducts));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('DC_B17'), style: Theme.of(context).textTheme.headline3),
        actions: [
          FloatingActionButton(
            child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white,),
            backgroundColor: Colors.deepOrange,
            onPressed: (){
            },
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
                          Spacer(),
                          Text(StatitikLocale.of(context).read('PSMP_B0'), style: Theme.of(context).textTheme.headline6),
                          SizedBox(width: 5.0),
                          Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                          SizedBox(width: 15.0),
                        ]
                      ),
                      SizedBox(height: 40),
                      drawNothing(context, 'PSMP_B1')
                    ]
                ),
              )
            )
        : Column(
          children: [
            TabBar(
              controller: langueController,
              //isScrollable: false,
              indicatorPadding: const EdgeInsets.all(1),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green,
              ),
              tabs: langueWidgets
            ),
            Expanded(
              child: TabBarView(
                controller: langueController,
                physics: NeverScrollableScrollPhysics(),
                children: productTab,
              )
            )
          ]
        ),
      ),
    );
  }
}
