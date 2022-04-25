import 'package:flutter/material.dart';

import 'package:statitikcard/services/models/NewCardsReport.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class UserNewCardDraw extends StatelessWidget {
  final NewCardsReport report;
  const UserNewCardDraw(this.report, {Key? key}) : super(key: key);

  List<Widget> createCards(SubExtension subExtension, List<NewCardReport> reports) {
    var list = <Widget>[];

    reports.forEach((cardReport) {
      var card = subExtension.cardFromId(cardReport.idCard);
      var itSet = card.sets.iterator;
      cardReport.state.countBySet.forEach((element) {
        if(itSet.moveNext()) {
          if(element > 0) {
            list.add(Card(
              margin: EdgeInsets.all(2.0),
              color: itSet.current.color,
              child: Center(child: subExtension.cardInfo(cardReport.idCard)),
            ));
          }
        }
      });
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: report.result.keys.length,
      itemBuilder: (BuildContext context, int id) {
        var subExtension = report.result.keys.elementAt(id);
        List<Widget> cards = createCards(subExtension, report.result[subExtension]!);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: subExtension.name,
                  child: subExtension.image(wSize: 40, hSize: 40)
                ),
                GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  children: cards,
                ),
              ],
            ),
          )
        );
      }
    );
  }
}
