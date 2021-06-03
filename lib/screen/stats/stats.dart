import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/stats/userReport.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class StatsPage extends StatefulWidget {
  final StatsData d = StatsData();

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsViewOptions options = StatsViewOptions();

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      // Set old filter
      widget.d.category = -1;
      widget.d.product  = null;
      // Change selection
      widget.d.language = language;
      widget.d.subExt   = subExt;
    });

    //Launch compute stats
    waitStats();
  }

  Future<void> waitStats() async {
    // Clean old result
    widget.d.userStats = null;
    widget.d.stats     = null;

    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(widget.d.subExt, widget.d.product!, widget.d.category).then( (stats) {
      widget.d.stats = stats;
      // Get user info after
      if(env.user != null) {
        env.getStats(widget.d.subExt, widget.d.product!, widget.d.category, env.user!.idDB).then( (ustats) {
          if(ustats != null && ustats.nbBoosters > 0) {
            widget.d.userStats = ustats;
            setState(() {});
          }
        });
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> finalWidget = [];
    final String productButton = widget.d.product == null
        ? categoryName(context, widget.d.category)
        : widget.d.product!.name;

    if(widget.d.stats != null) {
     if(widget.d.stats!.nbBoosters > 0) {
       finalWidget.add(StatsView(data: widget.d, options: options));
     } else {
       finalWidget = [
         SizedBox(height: 20.0),
         Container( child: Center(child: Text(StatitikLocale.of(context).read('S_B1'), style: Theme.of(context).textTheme.headline1),)),
         Center(child: Text(StatitikLocale.of(context).read('S_B8'))),
         SizedBox(height: 20.0),
         Padding(
           padding: const EdgeInsets.all(16.0),
           child: drawImagePress(context, "PikaNoResult.png", 250.0),
         )
        ];
     }
     if(widget.d.subExt.info().validCard)
       finalWidget.add(
         Card(
           color: Colors.grey[800],
           child: TextButton(
               child: Text(StatitikLocale.of(context).read('S_B7')),
               onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => StatsExtensionsPage(stats: widget.d.stats!)));
               }
           ),
         ));
      if(widget.d.userStats != null)
       finalWidget.add(
           Card(
             color: Colors.grey[800],
             child: TextButton(
                 child: Text(StatitikLocale.of(context).read('S_B14')),
                 onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => UserReport(data: widget.d)));
                 }
             ),
         ));
    } else {
      if( widget.d.subExt != null) {
        finalWidget = [
          Text(StatitikLocale.of(context).read('loading')),
          SizedBox(height: 20.0),
          drawImagePress(context, 'Arrozard.png', 350.0),
        ];
      } else {
        finalWidget = [
          Container( child: Row( children: [
              SizedBox(width: 40.0),
              Image(image: AssetImage('assets/arrow.png'), height: 30.0,),
              SizedBox(width: 25.0),
              Flexible(child: Text(StatitikLocale.of(context).read('S_B2'), style: Theme.of(context).textTheme.headline5,)),
              ],)
          ),
          SizedBox(height: 20.0),
          drawImagePress(context, 'Arrozard.png', 350.0),
        ];
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              StatitikLocale.of(context).read('H_T1'), style: Theme.of(context).textTheme.headline3,
            ),
          ),
          actions: [
            if(widget.d.userStats != null)
              TextButton(
                  child: Icon(Icons.settings),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context)
                      {
                        return StatefulBuilder(
                          builder: (context, setState) { return AlertDialog(
                            title: Text(StatitikLocale.of(context).read('H_T2')),
                            content: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CheckboxListTile(
                                    title: Text(StatitikLocale.of(context).read('S_B10')),
                                    value: options.delta,
                                    onChanged: (newValue) {
                                      setState(() {
                                        options.delta = newValue!;
                                      });
                                    },
                                  ),
                                ]
                              ),
                            ),
                          );
                          }
                      );
                     }).then( (result) { setState((){}); } );
                  }
              ),
            /*
            if(widget.d.userStats != null)
              FlatButton(
                child: Icon(Icons.share_outlined),
                onPressed: () {
                  _shareReport();
                  //report.needUpdate.add(_shareReport);
                }
              ),
             */
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                 Card(
                    child: TextButton(
                      child: widget.d.language != null ? Row(
                        children: [
                          Text(StatitikLocale.of(context).read('S_B0')),
                          SizedBox(width: 8.0),
                          Image(image: widget.d.language.create(), height: 30),
                          SizedBox(width: 8.0),
                          widget.d.subExt.image(hSize: 30),
                      ]) : Text(StatitikLocale.of(context).read('S_B0')),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                      },
                    )
                  ),
                  if( widget.d.language != null && widget.d.subExt != null )
                    Expanded(
                      child: Card( child: TextButton(
                          child: Text(productButton, softWrap: true, style: TextStyle(fontSize: (productButton.length > 20) ? 10 : 14),),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.MultiSelection, language: widget.d.language, subExt: widget.d.subExt, afterSelected: afterSelectProduct) ));
                          },
                        )
                  ),
                 ),
              ]),
            ] + finalWidget
          ),
        )
    );
  }

  void afterSelectProduct(BuildContext context, Language language, Product product, int category) {
    Navigator.pop(context);
    setState(() {
      if(product != null) {
        widget.d.product  = product;
        widget.d.category = -1;
      } else if( category != -1 ) {
        widget.d.product  = null;
        widget.d.category = category;
      } else { // All products
        widget.d.product  = null;
        widget.d.category = -1;
      }
      waitStats();
    });
  }
}
