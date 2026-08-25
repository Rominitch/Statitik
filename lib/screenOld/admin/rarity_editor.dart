import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/services/environment.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/rarity.dart';

class RarityEditor extends StatefulWidget {
  const RarityEditor({super.key});

  @override
  State<RarityEditor> createState() => _RarityEditorState();
}

class _RarityEditorState extends State<RarityEditor> {
  Language language = Environment.instance.collection.languages.values.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.admin_B8, style: Theme.of(context).textTheme.displaySmall),
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
                worldAsian.add(AppLocalizations.of(context)!.rare_b1);
              }
              if(Environment.instance.collection.japanRarity.contains(r)) {
                worldAsian.add(AppLocalizations.of(context)!.rare_b0);
              }

              return Card(
                child: SizedBox(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: r.color,
                        child: SizedBox(
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
                        SizedBox(
                          width: 80,
                          child: Text( worldAsian.join(" "),
                              textAlign: TextAlign.center
                          )
                        )
                      ),
                      Card(
                        color: Environment.instance.collection.otherThanReverse.contains(r) ? Colors.green : Colors.grey,
                        child: SizedBox(
                          width: 80,
                          child: Text( AppLocalizations.of(context)!.rare_b2, softWrap: true, textAlign: TextAlign.center)
                        )
                      ),
                      Card(
                        color: Environment.instance.collection.goodCard.contains(r) ? Colors.green : Colors.grey,
                        child: SizedBox(
                          width: 80,
                          child: Text( AppLocalizations.of(context)!.rare_b3, softWrap: true, textAlign: TextAlign.center)
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
