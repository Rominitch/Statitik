import 'package:flutter/material.dart';

import 'package:statitikcard/screen/commonPages/product_page.dart';
import 'package:statitikcard/screen/stats/stat_view.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/stats/stats_option_dialog.dart';
import 'package:statitikcard/screen/stats/user_report.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/tools.dart';

class StatsExtensionDraw extends StatefulWidget {
  final StatsConfiguration info;

  const StatsExtensionDraw(this.info, {Key? key}) : super(key: key);

  @override
  State<StatsExtensionDraw> createState() => _StatsExtensionDrawState();
}

class _StatsExtensionDrawState extends State<StatsExtensionDraw> {

  void afterSelectProduct(BuildContext context, Language language, ProductRequested? product, ProductCategory? category) {
    Navigator.pop(context);
    setState(() {
      widget.info.statsData.pr       = product;
      widget.info.statsData.category = category;

      widget.info.waitStats( () { setState(() {}); } );
    });
  }

  @override
  Widget build(BuildContext context) {
    var sData = widget.info.statsData;

    final String productButton = sData.pr == null
        ? (sData.category != null ? sData.category!.name.name(sData.language!) : StatitikLocale.of(context).read('S_B9') )
        : sData.pr!.product.name;

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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.userSelection, language: widget.info.statsData.language!, subExt: widget.info.statsData.subExt!, afterSelected: afterSelectProduct) ));
                  },
                ))
            ),
            Card(
              child: IconButton(
                  icon: const Icon(Icons.settings),
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
                    const Icon(Icons.account_circle),
                    const SizedBox(width: 5),
                    Text(StatitikLocale.of(context).read('S_B14'), style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserReport(data: sData)));
                }
              )
            )
        ] : [
          const SizedBox(height: 20.0),
          Center(child: Text(StatitikLocale.of(context).read('S_B1'), style: Theme.of(context).textTheme.displayLarge)),
          Center(child: Text(StatitikLocale.of(context).read('S_B8'))),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: drawImagePress(context, 'Arrozard', 250.0),
          ),
       ]
    );
  }
}
