import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/stats/statView.dart';

import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/stats/statsOptionDialog.dart';
import 'package:statitikcard/screen/stats/userReport.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class StatsExtensionDraw extends StatefulWidget {
  final StatsConfiguration info;

  const StatsExtensionDraw(this.info) : super();

  @override
  _StatsExtensionDrawState createState() => _StatsExtensionDrawState();
}

class _StatsExtensionDrawState extends State<StatsExtensionDraw> {

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

    final String productButton = sData.product == null
        ? categoryName(context, sData.category)
        : sData.product!.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
        (sData.stats != null && sData.stats!.nbBoosters > 0) ?
        [
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
          StatsView(data: sData, options: widget.info.options),
          StatsCompletionBooster(sData),
          if(sData.userStats != null)
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
              )
            )
        ] : [
          SizedBox(height: 20.0),
          Container( child: Center(child: Text(StatitikLocale.of(context).read('S_B1'), style: Theme.of(context).textTheme.headline1),)),
          Center(child: Text(StatitikLocale.of(context).read('S_B8'))),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: drawImagePress(context, 'Arrozard', 250.0),
          ),
       ]
    );
  }
}
