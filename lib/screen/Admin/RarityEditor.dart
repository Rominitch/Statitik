import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Rarity.dart';

class RarityEditor extends StatefulWidget {
  const RarityEditor({Key? key}) : super(key: key);

  @override
  State<RarityEditor> createState() => _RarityEditorState();
}

class _RarityEditorState extends State<RarityEditor> {
  Language language = Environment.instance.collection.languages.values.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(StatitikLocale.of(context).read('ADMIN_B8'), style: Theme.of(context).textTheme.headline3),
    ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListView.builder(
            itemCount: Environment.instance.collection.rarities.length,
            itemBuilder: (context, id) {
              var item = Environment.instance.collection.rarities.entries.elementAt(id);
              Rarity r = item.value;

              var worldAsian = [];
              if(Environment.instance.collection.worldRarity.contains(r)) {
                worldAsian.add(StatitikLocale.of(context).read( 'RARE_B1'));
              }
              if(Environment.instance.collection.japanRarity.contains(r)) {
                worldAsian.add(StatitikLocale.of(context).read( 'RARE_B0'));
              }

              return Card(
                child: Container(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: r.color,
                        child: Container(
                          width: 50,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: getImageRarity(r, language, generate: true)),
                        ),
                      ),
                      const Spacer(),
                      Card(
                        color: Colors.grey,
                        child:
                        Container(
                          width: 80,
                          child: Text( worldAsian.join(" "),
                              textAlign: TextAlign.center
                          )
                        )
                      ),
                      Card(
                        color: Environment.instance.collection.otherThanReverse.contains(r) ? Colors.green : Colors.grey,
                        child: Container(
                          width: 80,
                          child: Text( StatitikLocale.of(context).read('RARE_B2'), softWrap: true, textAlign: TextAlign.center)
                        )
                      ),
                      Card(
                        color: Environment.instance.collection.goodCard.contains(r) ? Colors.green : Colors.grey,
                        child: Container(
                          width: 80,
                          child: Text( StatitikLocale.of(context).read('RARE_B3'), softWrap: true, textAlign: TextAlign.center)
                        )
                      ),
                    ],
                  ),
                ),
              );
            }
          )
        )
      )
    );
  }
}
