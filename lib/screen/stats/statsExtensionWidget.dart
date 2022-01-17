import 'package:flutter/material.dart';
import 'package:statitikcard/screen/stats/statView.dart';

import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/stats/userReport.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';

class StatsExtensionWidget extends StatefulWidget {

  final StatsConfiguration info;

  const StatsExtensionWidget(this.info);

  @override
  _StatsExtensionWidgetState createState() => _StatsExtensionWidgetState();
}

class _StatsExtensionWidgetState extends State<StatsExtensionWidget> {

  List<Widget> showDrawPage(BuildContext context) {

    var sData = widget.info.statsData;
    List<Widget> finalWidget = [];
    final String productButton = sData.product == null
        ? categoryName(context, sData.category)
        : sData.product!.name;

    if(sData.stats != null) {
      if(sData.stats!.nbBoosters > 0) {
        finalWidget.add(StatsView(data: sData, options: widget.info.options));
      } else {
        finalWidget = [
          SizedBox(height: 20.0),
          Container( child: Center(child: Text(StatitikLocale.of(context).read('S_B1'), style: Theme.of(context).textTheme.headline1),)),
          Center(child: Text(StatitikLocale.of(context).read('S_B8'))),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: drawImagePress(context, 'Arrozard', 250.0),
          )
        ];
      }
      /*
      if(widget.d.subExt!.seCards.isValid)
        finalWidget.add(
            Card(
              color: Colors.grey[700],
              child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart_rounded),
                      Text(StatitikLocale.of(context).read('S_B7'), style: Theme.of(context).textTheme.headline6)
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ));
                  }
              ),
            ));
      */
      if(sData.userStats != null)
        finalWidget.add(
            Card(
              color: Colors.grey[800],
              child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle),
                      SizedBox(width: 5),
                      Text(StatitikLocale.of(context).read('S_B14'), style: Theme.of(context).textTheme.headline5),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserReport(data: sData)));
                  }
              ),
            ));
    } else {
      if( sData.subExt != null) {
        finalWidget = [
          drawLoading(context)
        ];
      }
    }
    return finalWidget;
  }

  @override
  Widget build(BuildContext context) {
    var sData = widget.info.statsData;
    List<Widget> page = [];
    switch( widget.info.state ) {
      case StateStatsExtension.Draw:
        page = showDrawPage(context);
        break;
      case StateStatsExtension.Cards:
        page = showDrawPage(context);
        break;
      case StateStatsExtension.GlobalStats:
        page = [StatsExtensionsPage(stats: sData.stats!, data: sData)];
        break;
      default :
        page = [];
    }

    return Column(
      children : page
    );
  }
}
