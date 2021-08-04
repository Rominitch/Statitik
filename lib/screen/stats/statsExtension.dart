import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:statitikcard/screen/stats/pieChart.dart';
import 'package:statitikcard/screen/widgets/screenPrint.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class StatsExtensionsPage extends StatefulWidget {
  final Stats stats;
  final StatsData data;

  StatsExtensionsPage({required this.stats, required this.data});

  @override
  _StatsExtensionsPageState createState() => _StatsExtensionsPageState();
}

class _StatsExtensionsPageState extends State<StatsExtensionsPage> {
  late StatsExtension statsExtension;
  static const bool isCard=false;

  @override
  void initState() {
    statsExtension = StatsExtension(subExt: widget.stats.subExt);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    int id=0;
    final double ratio   = 100.0 / widget.stats.totalCards;
    final double uniform = 100.0 / widget.stats.count.length;
    ScreenPrint print = ScreenPrint();

    for(int count in widget.stats.count) {
      PokeCard pc = widget.stats.subExt.info().cards[id];
      double percent = widget.stats.totalCards > 0 ? count * ratio : 0;
      Color col = percent == 0.0
                ? Colors.red
                : percent < uniform * 0.01
                ? Colors.yellow
                : percent < uniform * 0.1
                ? Colors.purple
                : percent < uniform
                ? Colors.blue
                : Colors.green;
      String label = percent == 0.0
                   ? '-'
                   : "$count (${percent.toStringAsPrecision(2)}%)";
      String realCardName = widget.stats.subExt.info().getName(widget.data.language!, id);
      final cardName = widget.stats.subExt.nameCard(id);
      cards.add(Card(
        color: Colors.grey[800],
        child: isCard ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cardName, style: cardName.length > 4 ? TextStyle(fontSize: 10.0) : TextStyle(fontSize: 12.0)),
                  SizedBox(width: 5.0),
                  pc.imageType(),
                  SizedBox(width: 5.0)]
                  +pc.imageRarity()
              ),
              Center(
                  child: Text(realCardName, maxLines: 3, softWrap: true, style: TextStyle(fontSize: 9.0))
              ),
              Center(child: Text(label, style: TextStyle(color: col, fontWeight: FontWeight.bold))),
        ]) : Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Container(width: 25, child: Text(cardName, style: cardName.length > 4 ? TextStyle(fontSize: 10.0) : TextStyle(fontSize: 12.0))),
              SizedBox(width: 5.0),
              Container(width: 70,
                child: Row(
                  children: [
                    pc.imageType(),
                    SizedBox(width: 5.0)
                  ] + pc.imageRarity()
                )
              ),
              Expanded(child: Text(realCardName, maxLines: 3, softWrap: true, style: TextStyle(fontSize: 9.0))),
              Container(width: 55, child: Text(label, style: TextStyle(fontSize: 11.0, color: col, fontWeight: FontWeight.bold)))
            ]
          ),
        ),
      ));
      id += 1;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            StatitikLocale.of(context).read('SE_T'), style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            if(Environment.instance.user != null && Environment.instance.user!.admin) IconButton(
                icon: Icon(Icons.share_outlined),
                onPressed: () {
                  print.shareReport(context, widget.stats.subExt.icon);
                }
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        body: SafeArea(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: print.screenshotController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image(image: widget.data.language!.create(), height: 30),
                            SizedBox(width: 8.0),
                            widget.data.subExt!.image(hSize: 30),
                            SizedBox(width: 8.0),
                            Text(widget.data.subExt!.name, style: Theme.of(context).textTheme.headline6),
                          ]
                        )
                      )
                    ),
                    Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(StatitikLocale.of(context).read('SE_B0'), style: Theme.of(context).textTheme.headline5),
                                Text(StatitikLocale.of(context).read('SE_B2')+' '+widget.stats.count.length.toString(), style: Theme.of(context).textTheme.bodyText2),
                                PieExtension(stats: statsExtension, visu: Visualize.Type),
                                SizedBox(height: 10.0,),
                                PieExtension(stats: statsExtension, visu: Visualize.Rarity),
                              ]
                          ),
                        )
                    ),
                    SizedBox(height: 10.0,),
                    Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(StatitikLocale.of(context).read('SE_B1'), style: Theme.of(context).textTheme.headline5),
                                isCard ? GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  primary: false,
                                  children: cards,
                                ) : ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  primary: false,
                                  children: cards
                                ),
                              ]
                          ),
                        )
                    ),
                  ]
                ),
              ),
            )
        )
    );
  }
}
