import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/stats/statView.dart';

import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/stats/statsExtensionCards.dart';
import 'package:statitikcard/screen/stats/statsOptionDialog.dart';
import 'package:statitikcard/screen/stats/userReport.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

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
        finalWidget += <Widget>[
            Row( children: [
              Expanded(
                child: Card( child: TextButton(
                  child: Text(productButton, softWrap: true, style: TextStyle(fontSize: (productButton.length > 20) ? 10 : 14),),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.MultiSelection, language: widget.info.statsData.language!, subExt: widget.info.statsData.subExt!, afterSelected: afterSelectProduct) ));
                  },
                ))
              ),
              Card(
                child: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return createOptionDialog(context, widget.info.options);
                      }
                    ).then( (result) { setState((){}); } );
                  }
                ),
              ),
            ]),
            StatsView(data: sData, options: widget.info.options)
        ];
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
    }
    return finalWidget;
  }

  void afterSelectProduct(BuildContext context, Language language, Product? product, int category) {
    Navigator.pop(context);
    setState(() {
      if(product != null) {
        widget.info.statsData.product  = product;
        widget.info.statsData.category = -1;
      } else if( category != -1 ) {
        widget.info.statsData.product  = null;
        widget.info.statsData.category = category;
      } else { // All products
        widget.info.statsData.product  = null;
        widget.info.statsData.category = -1;
      }
      widget.info.waitStats( () { setState(() {}); } );
    });
  }

  @override
  Widget build(BuildContext context) {
    var sData = widget.info.statsData;

    if(sData.stats == null && sData.subExt != null) {
      return drawLoading(context);
    } else if(widget.info.statsData.subExt != null && !widget.info.statsData.subExt!.seCards.isValid) {
      return drawOut(context, widget.info.statsData.subExt!);
    } else {
      switch( widget.info.state ) {
        case StateStatsExtension.Draw:
          return Column(children : showDrawPage(context));
        case StateStatsExtension.Cards:
          return StatsExtensionCards(widget.info);
        case StateStatsExtension.GlobalStats:
          return StatsExtensionsPage(stats: sData.stats!, data: sData);
        default :
          throw Exception("Bad Id of panel");
      }
    }
  }
}
