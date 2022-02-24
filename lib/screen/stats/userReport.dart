import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:screenshot/screenshot.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/widgets/screenPrint.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';
import 'package:statitikcard/services/models/product.dart';

class UserReport extends StatefulWidget {
  final StatsData data;

  UserReport({required this.data});

  @override
  _UserReportState createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  StatsData finalData = StatsData();
  ScreenPrint print = ScreenPrint();
  bool compute = true;
  List<Widget> bestCards = [];
  List<Widget> products  = [];

  DeviceOrientation current = DeviceOrientation.portraitUp;

  @override
  void initState() {
    super.initState();

    compute = true;
    finalData.stats    = widget.data.userStats;
    finalData.language = widget.data.language;
    finalData.pr  = widget.data.pr;
    finalData.category = widget.data.category;
    finalData.subExt   = widget.data.subExt;

    List<Map<int,PokemonCardExtension>> cardSort = List.generate(Environment.instance.collection.rarities.length, (id) => {});

    bestCards.clear();

    if(finalData.stats != null) {
      final Language l = finalData.subExt!.extension.language;
      // Just keep best card for report
      for (int idCardNumber = 0; idCardNumber < finalData.stats!.count.length; idCardNumber += 1) {
        for (int idCard = 0; idCard < finalData.stats!.count[idCardNumber].length; idCard += 1) {
          var card = finalData.subExt!.seCards.cards[idCardNumber][idCard];
          if (finalData.stats!.count[idCardNumber][idCard] > 0 && card.isForReport() ) {
            cardSort[card.rarity.id][idCardNumber] = card;
          }
        }
      }

      cardSort.reversed.forEach((cards) {
        for(var c in cards.entries) {
          if (bestCards.length > 14)
            break;

          if(finalData.subExt!.seCards.cards.isNotEmpty) {
            String realName = c.value.data.titleOfCard(l);
            Widget? markerInfo = c.value.showImportantMarker(l, height: 15);
            bestCards.add(Card(
              color: Colors.grey[600],
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                    [
                      Container(child: Text(finalData.subExt!.seCards.numberOfCard(c.key)), width: 40),
                      Container(child: Row(children: [c.value.imageType()] +
                          c.value.imageRarity(l)), width: 80),
                      SizedBox(width: 6.0),
                      Flexible(child: Text(realName, style: TextStyle(fontSize: realName.length > 10 ? 10 : 13))),
                      if(markerInfo != null) markerInfo,
                    ]),
              ),
            )
            );
          } else
            bestCards.add(Card(
              color: Colors.grey[600],
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [c.value.imageType()] + c.value.imageRarity(l)),
                    SizedBox(height: 6.0),
                    Text(c.key.toString()),
                  ]),
            )
            );
        }
      });

      products.clear();
      if (finalData.pr != null) {
        products.add(ProductCard(finalData.pr!, true));
        compute=false;
      } else { // All products or cat
        readProductsForUser(finalData.language!, finalData.subExt!, finalData.category).then((aps) {
          for (final ps in aps) {
            for (ProductRequested pr in ps) {
              if( products.length < 5 && pr.count > 0)
                products.add(ProductCard(pr, true));
            }
          }
          setState(() {compute=false;});
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(finalData.stats != null);
    var translator = StatitikLocale.of(context);

    SystemChrome.setPreferredOrientations([current]);

    StatsViewOptions options = StatsViewOptions();
    options.print = true;
    options.showOption = OptionShowState.RealCount;

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double width = MediaQuery.of(context).size.width - 10;

    return Scaffold(
        appBar: AppBar(
          title: Text(
              translator.read('S_B14'), style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.screen_rotation),
                onPressed: (){
                  setState(() {
                    current = (current == DeviceOrientation.portraitUp)
                        ? DeviceOrientation.landscapeLeft
                        : DeviceOrientation.portraitUp;
                  });
                }
            ),
            if(!compute) IconButton(
                icon: Icon(Icons.share_outlined),
                onPressed: () {
                  print.shareReport(context, finalData.subExt!.seCode);
                }
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        body: (compute)
          ? drawLoading(context)
          : SingleChildScrollView(
          child: Screenshot(
            controller: print.screenshotController,
            child: Container(
              padding: EdgeInsets.all(5.0),
              color: Colors.grey[850],
              child: isPortrait
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row( children: [
                        Text(Environment.instance.nameApp, style: Theme.of(context).textTheme.headline5),
                        Expanded(child: SizedBox(width: 1.0)),
                        Image(image: widget.data.language!.create(), height: 30),
                        SizedBox(width: 6.0),
                        Text(widget.data.subExt!.name, style: TextStyle( fontSize: (widget.data.subExt!.name.length > 13) ? 10 : 12 )),
                        SizedBox(width: 6.0),
                        widget.data.subExt!.image(hSize: 30)
                      ]),
                      StatsView(data: finalData, options: options),
                      if(bestCards.isNotEmpty) buildBestCards(translator, 5),
                      if(products.isNotEmpty)  buildProducts(translator, 3),
                    ],
                  )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row( children: [
                        Text(Environment.instance.nameApp, style: Theme.of(context).textTheme.headline5),
                        SizedBox(width: 30.0),
                        Image(image: widget.data.language!.create(), height: 30),
                        SizedBox(width: 6.0),
                        Text(widget.data.subExt!.name, style: TextStyle( fontSize: (widget.data.subExt!.name.length > 13) ? 10 : 12 )),
                        SizedBox(width: 6.0),
                        widget.data.subExt!.image(hSize: 30),
                      ]
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: width / 3, child: StatsView(data: finalData, options: options)),
                        if(bestCards.isNotEmpty) Container(width: width / 3, child: buildBestCards(translator, 3)),
                        if(products.isNotEmpty)  Container(width: width / 3, child: buildProducts(translator, 2)),
                      ],
                      )
                  ],
              ),
            ),
          )
        )
    );
  }

  Widget buildBestCards(translator, limit) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(translator.read('RE_B0'), style: Theme.of(context).textTheme.headline5),
          ListView(
            shrinkWrap: true,
            primary: false,
            children: bestCards,
          )
        ]
      )
    );
  }

  Widget buildProducts(translator, limit) {
    return Card(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(translator.read('TP_T0'), style: Theme.of(context).textTheme.headline5),
              GridView.count(
                crossAxisCount: limit,
                shrinkWrap: true,
                primary: false,
                children: products,
              )
            ]
        )
    );
  }
}
