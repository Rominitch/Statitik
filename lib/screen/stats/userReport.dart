import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:screenshot/screenshot.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/widgets/screenPrint.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/product.dart';

class FullCard {
  String   name;
  PokeCard card;
  String   realName;

  FullCard(this.name, this.card, this.realName);
}

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
    finalData.product  = widget.data.product;
    finalData.category = widget.data.category;
    finalData.subExt   = widget.data.subExt;

    List<List<FullCard>> cardSort = List.generate(Rarity.values.length, (id) => []);

    bestCards.clear();

    if(finalData.stats != null) {
      for (int i = 0; i < finalData.stats!.count.length; i += 1) {
        PokeCard card = finalData.subExt!.info().cards[i];
        if (finalData.stats!.count[i] > 0 &&
            card.rarity.index >= Rarity.HoloRare.index) {
          String rname = finalData.subExt!.info().getName(finalData.language!, i);
          cardSort[card.rarity.index].add(FullCard(finalData.subExt!.nameCard(i), card, rname));
        }
      }

      for (final cards in cardSort.reversed) {
        for (final c in cards) {
          if (bestCards.length > 14)
            break;

          final cardName = c.name;
          if(finalData.subExt!.info().pokemons.isNotEmpty)
            bestCards.add(Card(
              color: Colors.grey[600],
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                    [
                      Container(child: Text( c.name ), width: 40),
                      Container(child:Row(children: [c.card.imageType()] + c.card.imageRarity()), width:80),
                      SizedBox(width: 6.0),
                      Flexible(child:Text( c.realName, style: TextStyle(fontSize: c.realName.length > 10 ? 10 : 13) )),
                    ]),
              ),
              )
            );
          else
            bestCards.add(Card(
              color: Colors.grey[600],
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                  [
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [c.card.imageType()] + c.card.imageRarity()),
                    SizedBox(height: 6.0),
                    Text(cardName),
                  ]),
            )
            );
        }
      }

      products.clear();
      if (finalData.product != null) {
        products.add(ProductCard(finalData.product!, true));
        compute=false;
      } else { // All products or cat
        readProductsForUser(finalData.language!, finalData.subExt!, finalData.category).then((aps) {
          for (final ps in aps) {
            for (Product p in ps) {
              if( products.length < 5 && p.countProduct() > 0)
                products.add(ProductCard(p, true));
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
                  print.shareReport(context, finalData.subExt!.icon);
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
    if(finalData.subExt!.info().pokemons.isNotEmpty)
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
    else
      return Card(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(translator.read('RE_B0'), style: Theme.of(context).textTheme.headline5),
                GridView.count(
                  crossAxisCount: limit,
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
