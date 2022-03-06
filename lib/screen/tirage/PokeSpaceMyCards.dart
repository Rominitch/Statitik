import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';

class PokeSpaceMyCards extends StatefulWidget {
  const PokeSpaceMyCards({Key? key}) : super(key: key);

  @override
  State<PokeSpaceMyCards> createState() => _PokeSpaceMyCardsState();
}

class _PokeSpaceMyCardsState extends State<PokeSpaceMyCards> {

  late CustomRadioController langueController = CustomRadioController(onChange: (Language value) { onLanguageChanged(value); });

  static const double ratioGrid = 4.5;

  void onLanguageChanged(value) {
    setState(() {});
  }

  void goToCardSelector(SubExtension subExtension) {

  }

  Widget buildLine(String name, Color color, int myCard, int maxCard, [double size = 10.0]) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Text(name, style: TextStyle(
            fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
            fontSize: size-1)
          ),
          SizedBox(height: 2),
          LinearPercentIndicator(
            lineHeight: size,
            percent: (myCard.toDouble()/maxCard.toDouble()).clamp(0.0, 1.0),
            progressColor: color,
            backgroundColor: Colors.black,
            center: new Text("$myCard / $maxCard", style: TextStyle(
                //fontFamily: Theme.of(context).textTheme.headline1!.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: size-2.0)),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    var mySpace = Environment.instance.user!.pokeSpace;
    if( mySpace.myCards.isNotEmpty )
      langueController.currentValue = mySpace.myLanguagesCard().first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mySpace = Environment.instance.user!.pokeSpace;

    List<Widget> languages = [];
    mySpace.myLanguagesCard().forEach((element) {
      languages.add(CustomRadio(value: element, controller: langueController, widget: element.barIcon()));
    });

    var myCards = mySpace.getBy(langueController.currentValue);
    var orderedSubExt = myCards.keys.toList(growable: false);
    orderedSubExt.sort((a, b) => b.out.compareTo(a.out));

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('DC_B16'), style: Theme.of(context).textTheme.headline3),
        actions: [
          FloatingActionButton(
            //label: Text(StatitikLocale.of(context).read('PSMC_B0')),
            child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white,),
            backgroundColor: Colors.blueAccent.shade200,
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
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: SingleChildScrollView(
            child: myCards.isEmpty
            ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Text(StatitikLocale.of(context).read('PSMC_B4'), style: Theme.of(context).textTheme.headline6),
                        SizedBox(width: 5.0),
                        Image(image: AssetImage('assets/arrowR.png'), height: 20.0,),
                        SizedBox(width: 15.0),
                      ]
                    ),
                    SizedBox(height: 40),
                    drawNothing(context, 'PSMC_B3')
                  ]
              ),
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: languages),
                ListView.builder(
                  itemCount: orderedSubExt.length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int id) {
                    var subExtension = orderedSubExt[id];
                    var counter      = myCards[subExtension]!;
                    List<Widget> global = [
                      buildLine(StatitikLocale.of(context).read('PSMC_B1'), Colors.lightGreen.shade900, counter.statsCards.countOfficial, subExtension.seCards.cards.length-subExtension.stats.countSecret),
                      if(subExtension.stats.countSecret > 0)
                        buildLine(StatitikLocale.of(context).read('PSMC_B2'), Colors.yellowAccent, counter.statsCards.countSecret, subExtension.stats.countSecret),
                    ];
                    return Card(
                      margin: EdgeInsets.all(2.0),
                      child: TextButton(
                      child: Row(children: <Widget>[
                        Tooltip(message: subExtension.name, child: subExtension.image(hSize: 40, wSize: 40)),
                        Expanded(
                          child: Column(
                            children: [
                              Card(
                                color: Colors.grey.shade600,
                                child: GridView.count(crossAxisCount: global.length,
                                  children: global,
                                  primary: false,
                                  shrinkWrap: true,
                                  childAspectRatio: global.length == 1 ? 9.0 : ratioGrid,
                                ),
                              ),
                              Card(
                                color: Colors.grey.shade600,
                                child: GridView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: ratioGrid),
                                    itemCount: subExtension.stats.allSets.length,
                                    itemBuilder: (context, id) {
                                      var set = subExtension.stats.allSets[id];
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
                    ));
                  }
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
