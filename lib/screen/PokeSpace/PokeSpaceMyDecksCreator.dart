import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/widgets/CardsSelection.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'package:statitikcard/services/models/Deck.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class PokeSpaceMyDecksCreator extends StatefulWidget {
  final Language  language;
  final Deck      deck;

  const PokeSpaceMyDecksCreator(this.language, this.deck, {Key? key}) : super(key: key);

  @override
  State<PokeSpaceMyDecksCreator> createState() => _PokeSpaceMyDecksCreatorState();
}

class _PokeSpaceMyDecksCreatorState extends State<PokeSpaceMyDecksCreator> with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TabController tabController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.deck.name);
    tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabHeader = [
      Text(StatitikLocale.of(context).read('PSMDC_B1'), style: Theme.of(context).textTheme.headline6),
      Text(StatitikLocale.of(context).read('PSMDC_B2'), style: Theme.of(context).textTheme.headline6),
    ];

    List<Widget> tabPages = [
      // Fill data

      // Stats
      SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Text(StatitikLocale.of(context).read('PSMDC_B0')),
                Expanded(
                  child: TextField(
                      controller: nameController,
                      onSubmitted: (String value) {
                        widget.deck.name = value;
                      }
                  ),
                )
              ]
            ),
            Card(
              child: Row(
                children: [
                  Card(
                    child: TextButton(
                      child: Text(StatitikLocale.of(context).read('PSMDC_B7')),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.language,
                            afterSelected: (BuildContext context, Language language, SubExtension subExtension) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CardsSelection(widget.language, subExtension)));
                            }, addMode: false))).then((value) {
                          if(value != null) {
                            // Added only new product and refresh
                            setState(() {
                              for(var cEx in value.cards) {
                                DeckCardInfo cardInfo = DeckCardInfo(value.subExtension, value.subExtension.seCards.computeIdCard(cEx), 1);
                                widget.deck.cards.add(cardInfo);
                              }
                            });
                          }
                        });
                      },
                    )
                  ),
                  Card(
                      child: TextButton(
                        child: Text(StatitikLocale.of(context).read('PSMDC_B8')),
                        onPressed: () {

                        },
                      )
                  )
                ],
              )
            ),
            Text(StatitikLocale.of(context).read('PSMDC_B3')),
            Text(StatitikLocale.of(context).read('PSMDC_B4')),
            Text(StatitikLocale.of(context).read('PSMDC_B5')),
            Text(StatitikLocale.of(context).read('PSMDC_B6')),
          ]
        ),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('PSMDC_T0'), style: Theme.of(context).textTheme.headline4),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                TabBar(
                    controller: tabController,
                    isScrollable: false,
                    indicatorPadding: const EdgeInsets.all(1),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                    ),
                    tabs: tabHeader
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: tabPages
                  )
                )
              ],
            )
        ),
      ),
    );
  }
}
