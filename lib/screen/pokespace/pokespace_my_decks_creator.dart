import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/extension_page.dart';
import 'package:statitikcard/screen/widgets/CardSelector/card_selector_deck.dart';
import 'package:statitikcard/screen/widgets/cards_selection.dart';
import 'package:statitikcard/screen/widgets/deck_widget.dart';
import 'package:statitikcard/screen/widgets/pokemon_card.dart';
import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'package:statitikcard/services/models/deck.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';

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

  List<List<DeckCardInfo>> myFilteredCards = List.generate(4, (index) => []);
  bool nameEdition = false;

  void computeFilteredCards() {
    myFilteredCards = List.generate(4, (index) => []);

    for(var cardDeck in widget.deck.cards) {
      var card = cardDeck.se.cardFromId(cardDeck.idCard);
      int code = 0;
      if(card.data.type.index <= TypeCard.incolore.index) {
        code = 0;
      } else if(card.data.type == TypeCard.supporter) {
        code = 1;
      } else if(card.data.type == TypeCard.energy) {
        code = 2;
      } else {
        code = 3;
      }

      myFilteredCards[code].add(cardDeck);
    }
  }


  @override
  void initState() {
    nameController = TextEditingController(text: widget.deck.name);
    tabController = TabController(length: 2, vsync: this);

    computeFilteredCards();

    super.initState();
  }

  List<Widget> showCards(int code, String codeName) {
    List<Widget> list = [];
    if(myFilteredCards[code].isNotEmpty)
    {
      list.add(Text(StatitikLocale.of(context).read(codeName), style: Theme.of(context).textTheme.titleLarge));
      list.add(const SizedBox(height: 4.0));
      list.add(GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 0.6),
          itemCount: myFilteredCards[code].length,
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var cardInfo = myFilteredCards[code][index];
            var selector = CardSelectorDeck(cardInfo);
            return PokemonCard(selector, readOnly: false, singlePress: true, refresh: (){
              // Update stats
              widget.deck.computeStats();
              // Check if data need to remove
              if( cardInfo.count.count() == 0 ) {
                // Remove card if not used anymore
                widget.deck.cards.remove(cardInfo);
                // Refresh full parent GUI
                setState((){
                  computeFilteredCards();
                });
              }
              //
            });
          }
        )
      );
      list.add(const SizedBox(height: 4.0));
    }
    return list;
  }

  Future<bool> returnTo() async {
    Navigator.of(context).pop(true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabHeader = [
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Environment.heightTabHeader),
        child: Text(StatitikLocale.of(context).read('PSMDC_B1'), style: Theme.of(context).textTheme.titleLarge),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Environment.heightTabHeader),
        child: Text(StatitikLocale.of(context).read('PSMDC_B2'), style: Theme.of(context).textTheme.titleLarge),
      ),
    ];

    List<Widget> tabPages = [
      // Deck data
      SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(child: Text(StatitikLocale.of(context).read('PSMDC_B0'))),
                    Card(
                      color: Colors.grey,
                      child: TextButton(
                        child: Column(
                          children: [
                            const Icon(Icons.add_circle_outline),
                            const SizedBox(height: 4.0),
                            Text(StatitikLocale.of(context).read('PSMDC_B7')),
                          ]
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.language,
                              afterSelected: (BuildContext context, Language language, SubExtension subExtension) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CardsSelection(widget.language, subExtension)));
                              }, addMode: false))).then((value) {
                            if(value != null) {
                              // Added only new product and refresh
                              setState(() {
                                // Insert new card
                                for(var cEx in value.cards) {
                                  var count = CodeDraw.fromPokeCardExtension(value.subExtension.cardFromId(cEx));
                                  count.setCount(1, 0);
                                  DeckCardInfo deckCardInfo = DeckCardInfo(value.subExtension, cEx, count);
                                  widget.deck.cards.add(deckCardInfo);
                                }
                                // Update stats
                                widget.deck.computeStats();

                                computeFilteredCards();
                              });
                            }
                          });
                        },
                      )
                    ),
                  ],
                ),
              )
            )
          ]
          + showCards(2, 'PSMDC_B3')
          + showCards(0, 'PSMDC_B4')
          + showCards(1, 'PSMDC_B5')
          + showCards(3, 'PSMDC_B6')
        )
      ),
      // Stats
      DeckStatisticWidget(widget.deck)
    ];

    return WillPopScope(
      onWillPop: returnTo,
      child:Scaffold(
        appBar: AppBar(
          title:
          (nameEdition) ? TextField(
              controller: nameController,
              onSubmitted: (String value) {
                setState(() {
                  widget.deck.name = value;
                  nameEdition = false;
                });
              }
          )
          : Text(widget.deck.name, style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            IconButton(onPressed: () {
                setState(()
                {
                  nameEdition=true;
                });
              },
              icon: const Icon(Icons.edit)
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(6.0),
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
                      physics: const NeverScrollableScrollPhysics(),
                      children: tabPages
                    )
                  )
                ],
              )
          )
        )
      )
    );
  }
}
