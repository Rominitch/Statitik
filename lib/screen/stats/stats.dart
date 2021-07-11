import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/stats/statsOptionDialog.dart';
import 'package:statitikcard/screen/stats/userReport.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class StatsPage extends StatefulWidget {
  final StatsData d = StatsData();
  final List<SubExtension> _se = [];

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsViewOptions options = StatsViewOptions();
  PageController _pageController = PageController(keepPage: false);

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      // Set old filter
      widget.d.category = -1;
      widget.d.product  = null;
      // Change selection
      widget.d.language = language;
      widget.d.subExt   = subExt;

      widget._se.clear();
      for(Extension e in Environment.instance.collection.getExtensions(language)) {
        for(SubExtension se in Environment.instance.collection.getSubExtensions(e)) {
          widget._se.insert(0, se);
        }
      }

      var idPage = widget._se.indexOf(subExt);
      //printOutput("Page after extension: $idPage");
      //_pageController = widget._se.isNotEmpty ? PageController(initialPage: idPage) : PageController();
      _pageController.jumpToPage(idPage);

      //Launch compute stats
      waitStats();
    });
  }

  Future<void> waitStats() async {
    // Clean old result
    widget.d.userStats = null;
    widget.d.stats     = null;

    // Get data from DB
    Environment env = Environment.instance;
    env.getStats(widget.d.subExt!, widget.d.product, widget.d.category).then( (stats) {
      widget.d.stats = stats;
      // Get user info after
      if(env.user != null) {
        env.getStats(widget.d.subExt!, widget.d.product, widget.d.category, env.user!.idDB).then( (ustats) {
          if(ustats.nbBoosters > 0) {
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
           child: drawImagePress(context, 'Arrozard', 250.0),
         )
        ];
     }
     if(widget.d.subExt!.info().validCard)
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
                 Navigator.push(context, MaterialPageRoute(builder: (context) => StatsExtensionsPage(stats: widget.d.stats!, data: widget.d)));
               }
           ),
         ));
      if(widget.d.userStats != null)
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
                   Navigator.push(context, MaterialPageRoute(builder: (context) => UserReport(data: widget.d)));
                 }
             ),
         ));
    } else {
      if( widget.d.subExt != null) {
        finalWidget = [
          drawLoading(context)
        ];
      } else {
        finalWidget = [
          Container( child: Row( children: [
              SizedBox(width: 40.0),
              Image(image: AssetImage('assets/arrow.png'), height: 30.0,),
              SizedBox(width: 25.0),
              Flexible(child: Text(StatitikLocale.of(context).read('S_B2'), style: Theme.of(context).textTheme.headline5)),
              ],)
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: drawImagePress(context, 'PikaNoResult', 250.0),
          )
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
            if(widget._se.isNotEmpty)
              TextButton(
                  child: Icon(Icons.settings),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return createOptionDialog(context, options);
                      }
                    ).then( (result) { setState((){}); } );
                  }
              ),
          ],
        ),
        body: PageView.builder(
            controller: _pageController,
            itemCount: max(1, widget._se.length),
            pageSnapping: true,
            onPageChanged: (position) {
              //printOutput("Page after change: $position");
              setState(() {
                var se = position < widget._se.length ? widget._se[position] : null;
                if(se != widget.d.subExt) {
                  widget.d.subExt = se;
                  waitStats();
                }
              });
            },
            itemBuilder: (context, position) {
              //printOutput("Page to redraw: $position");
            return SingleChildScrollView(
                child:Column(
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
                            Image(image: widget.d.language!.create(), height: 30),
                            SizedBox(width: 8.0),
                            Tooltip(message: widget.d.subExt!.name,
                                    child:widget.d.subExt!.image(hSize: 30)),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.MultiSelection, language: widget.d.language!, subExt: widget.d.subExt!, afterSelected: afterSelectProduct) ));
                            },
                          )
                    ),
                   ),
                ]),
              ] + finalWidget
                )
            );
            }
       ),
    );
  }

  void afterSelectProduct(BuildContext context, Language language, Product? product, int category) {
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
