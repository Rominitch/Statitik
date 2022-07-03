import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/CardDesign.dart';
import 'package:statitikcard/services/models/Language.dart';

class TutorialCaption extends StatelessWidget {
  final Language l;
  const TutorialCaption(this.l, {Key? key}) : super(key: key);

  Widget createIconDescribe(String text, Widget icon) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row( children: [
          icon,
          SizedBox(width: 5.0),
          Flexible(child: Text(text, style: TextStyle(fontSize: text.length > 10  ? 12.0 : 14.0)))
        ]
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    const iconSize = 50.0;
    var designWidget = <Widget>[];
    Environment.instance.collection.validDesigns.forEach((element) {

      designWidget.add( createIconDescribe(element.name(l), element.icon(height: iconSize)));
    });

    var artWidgets = <Widget>[];
    ArtFormat.values.forEach((art) {
      if(art != ArtFormat.Unknown)
        artWidgets.add( createIconDescribe(StatitikLocale.of(context).read(codeArt(art)), iconArt(art, iconSize, iconSize)));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('S_TOOL_T4'), style: Theme.of(context).textTheme.headline4),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children:[
              Card(
                color: Colors.grey.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children:[
                      Text(StatitikLocale.of(context).read('TUTO_CAPTION_T0'), style: Theme.of(context).textTheme.headline4),
                      Column(children: [
                        Card(
                          color: Colors.black12,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                children:[
                                  Text(StatitikLocale.of(context).read('TUTO_CAPTION_T1'), style: Theme.of(context).textTheme.headline5),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    childAspectRatio: 4.0,
                                    children: artWidgets,
                                    primary: false,
                                    shrinkWrap: true,
                                  )
                                ]
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.black12,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children:[
                                Center(child: Text(StatitikLocale.of(context).read('TUTO_CAPTION_T2'), style: Theme.of(context).textTheme.headline5)),
                                GridView.count(
                                  crossAxisCount: 2,
                                  childAspectRatio: 4.0,
                                  children: designWidget,
                                  primary: false,
                                  shrinkWrap: true,
                                )
                              ]
                            ),
                          ),
                        )
                      ])
                    ]
                  ),
                ),
              )
            ]
          ),
        )
      )
    );
  }
}
