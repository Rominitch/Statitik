import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/screen/view.dart';

class UserReport extends StatefulWidget {
  final StatsData data;

  UserReport({this.data});

  @override
  _UserReportState createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  @override
  Widget build(BuildContext context) {
    var translator = StatitikLocale.of(context);
    assert(translator != null);

    StatsData finalData = StatsData();
    finalData.stats    = widget.data.userStats;
    finalData.language = widget.data.language;
    finalData.product  = widget.data.product;
    finalData.category = widget.data.category;
    finalData.subExt   = widget.data.subExt;

    List<Widget> bestCards = [];

    if(finalData.stats != null) {
      for (int i = 0; i < finalData.stats.count.length; i += 1) {
        PokeCard card = finalData.subExt.cards[i];
        if (finalData.stats.count[i] > 0 &&
            card.rarity.index >= Rarity.HoloRare.index) {
          final cardName = finalData.subExt.nameCard(i);
          bestCards.add(Card(
            color: Colors.grey[600],
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [card.imageType()] + card.imageRarity()),
                  SizedBox(height: 6.0),
                  Text(cardName),
                ]),
          )
          );
        }
      }
      return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row( children: [
                  Text(Environment.instance.nameApp, style: Theme.of(context).textTheme.headline5),
                  Expanded(child: SizedBox(width: 1.0)),
                  Image(image: widget.data.language.create(), height: 30),
                  SizedBox(width: 6.0),
                  Text(widget.data.subExt.name, style: TextStyle( fontSize: (widget.data.subExt.name.length > 13) ? 10 : 12 )),
                  SizedBox(width: 6.0),
                  widget.data.subExt.image(hSize: 30)
                ]),
                buildStatsView(context, finalData, false, true),
                /*
              Card(
                  child: Column(
                      children: [
                        Text(translator.read('RE_B0'), style: Theme.of(context).textTheme.headline5),
                      ]
                  )
              ),
              */
                if(bestCards.isNotEmpty) Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(translator.read('RE_B0'), style: Theme.of(context).textTheme.headline5),
                          GridView.count(
                            crossAxisCount: 5,
                            shrinkWrap: true,
                            primary: false,
                            children: bestCards,
                          )
                        ]
                    )
                ),
              ],
            ),
          )
      );
    } else {
      return Text('No data');
    }
  }
}
