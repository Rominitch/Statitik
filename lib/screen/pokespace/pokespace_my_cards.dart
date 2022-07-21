import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:statitikcard/screen/commonPages/language_page.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_card_explorer.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/tools.dart';

class PokeSpaceMyCards extends StatefulWidget {
  const PokeSpaceMyCards({Key? key}) : super(key: key);

  @override
  State<PokeSpaceMyCards> createState() => _PokeSpaceMyCardsState();
}

class _PokeSpaceMyCardsState extends State<PokeSpaceMyCards> with TickerProviderStateMixin {
  late TabController tabController;

  static const double ratioGrid = 4.5;

  void computeTabLanguage([int id=0]) {
    var mySpace = Environment.instance.user!.pokeSpace;
    tabController = TabController(length: mySpace.myLanguagesCard().length,
      initialIndex: id, vsync: this);
  }

  void onLanguageChanged(value) {
    setState(() {});
  }

  void goToCardSelector(SubExtension subExtension) {
    var mySpace = Environment.instance.user!.pokeSpace;

    Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceCardExplorer(subExtension, mySpace))).then(
      (value) {
        setState(() {
          if(value!) {
            Environment.instance.savePokeSpace(context, mySpace);

            computeTabLanguage(tabController.index);
          }
        });
      });
  }

  Widget buildLine(String name, Color color, int myCard, int maxCard, [double size = 10.0]) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: TextStyle(
                fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
                fontSize: size-1)
              ),
              if(myCard == maxCard)
                const SizedBox(width: 4),
              if(myCard == maxCard)
                Icon(Icons.stars_rounded, color: Colors.amber.shade400, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          LinearPercentIndicator(
            lineHeight: size,
            percent: (myCard.toDouble()/maxCard.toDouble()).clamp(0.0, 1.0),
            progressColor: color,
            backgroundColor: Colors.black,
            center: Text("$myCard / $maxCard", style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size-2.0)),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    computeTabLanguage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mySpace = Environment.instance.user!.pokeSpace;

    List<Widget> tabHeaders = [];
    List<Widget> tabPages   = [];
    mySpace.myLanguagesCard().forEach((language) {
      tabHeaders.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: language.barIcon(),
      ));

      var myCards = mySpace.getBy(language);
      var orderedSubExt = myCards.keys.toList(growable: false);
      orderedSubExt.sort((a, b) => b.out.compareTo(a.out));

      tabPages.add(
        myCards.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Text(StatitikLocale.of(context).read('PSMC_B4'), style: Theme.of(context).textTheme.headline6),
                    const SizedBox(width: 5.0),
                    const Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                    const SizedBox(width: 15.0),
                  ]
                ),
                const SizedBox(height: 40),
                drawNothing(context, 'PSMC_B3')
              ]
            ),
          )
       : ListView.builder(
        itemCount: orderedSubExt.length,
        itemBuilder: (BuildContext context, int id) {
          var subExtension = orderedSubExt[id];
          var counter      = myCards[subExtension]!;
          List<Widget> global = [
            buildLine(StatitikLocale.of(context).read('PSMC_B1'), Colors.lightGreen.shade900, counter.statsCards.countOfficial, subExtension.seCards.cards.length-subExtension.stats.countSecret),
            if(subExtension.stats.countSecret > 0)
              buildLine(StatitikLocale.of(context).read('PSMC_B2'), Colors.yellowAccent, counter.statsCards.countSecret, subExtension.stats.countSecret),
          ];
          var validSets = subExtension.stats.allSets;
          validSets.removeWhere((element) => element.isSystem);

          return Card(
              margin: const EdgeInsets.all(2.0),
              child: TextButton(
                  child: Row(children: <Widget>[
                    Tooltip(message: subExtension.name, child: subExtension.image(hSize: 40, wSize: 40)),
                    Expanded(
                      child: Column(
                        children: [
                          Card(
                            color: Colors.grey.shade600,
                            child: GridView.count(crossAxisCount: global.length,
                              primary: false,
                              shrinkWrap: true,
                              childAspectRatio: global.length == 1 ? 9.0 : ratioGrid,
                              children: global,
                            ),
                          ),
                          Card(
                            color: Colors.grey.shade600,
                            child: GridView.builder(
                              primary: false,
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: ratioGrid),
                              itemCount: validSets.length,
                              itemBuilder: (context, id) {
                                var set = validSets[id];
                                assert(subExtension.stats.countBySet[set] != null);
                                return buildLine(set.names.name(subExtension.extension.language), set.color, counter.statsCards.countBySet[set] ?? 0, subExtension.stats.countBySet[set]!);
                              }
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                  onPressed: () {goToCardSelector(subExtension);}
              )
          );
        }
        )
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('DC_B16'), style: Theme.of(context).textTheme.headline3),
        actions: [
          FloatingActionButton.small(
            backgroundColor: cardMenuColor,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder:
                (context) => LanguagePage(afterSelected: (BuildContext c, Language l, SubExtension s)
                {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(s);
                }, addMode: false)))
              .then((subExtension) {
                if(subExtension != null) {
                  setState(() {
                    mySpace.insertSubExtension(subExtension);
                    goToCardSelector(subExtension);
                  });
                }
              });
            },
            child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white,),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: [
              TabBar(
                controller: tabController,
                indicatorPadding: const EdgeInsets.all(1),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                tabs: tabHeaders
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: tabPages
                )
              )
            ],
          )
        ),
      ),
    );
  }
}
