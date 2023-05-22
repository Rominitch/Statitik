import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/card_identifier.dart';

import 'package:statitikcard/screen/widgets/CardSelector/card_selector_poke_space.dart';
import 'package:statitikcard/screen/widgets/pokemon_card.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/pokespace.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

enum _VisualizationMask {
  all,
  mine,
  missing
}
var _vMaskIcons = const[
  Icons.grid_on,
  Icons.grid_view,
  Icons.grid_off
];

class PokeSpaceCardExplorer extends StatefulWidget {
  final SubExtension subExtension;
  final PokeSpace    pokeSpace;

  const PokeSpaceCardExplorer(this.subExtension, this.pokeSpace, {Key? key}) : super(key: key);

  @override
  State<PokeSpaceCardExplorer> createState() => _PokeSpaceCardExplorerState();
}

class _PokeSpaceCardExplorerState extends State<PokeSpaceCardExplorer> with SingleTickerProviderStateMixin {
  _VisualizationMask showMode = _VisualizationMask.all;
  List         cards      = [];

  bool edited = false;
  late TabController tabController;

  @override
  void initState() {
    int count = widget.subExtension.seCards.countNbLists();
    tabController = TabController(
      length: count,
      vsync: this,
      animationDuration: Duration.zero);

    refresh();
    super.initState();
  }

  void afterLaunchEditor() {
    edited = true;
  }

  void refresh() {
    EasyLoading.show();

    cards.clear();
    computeList().then((value) {
      setState(() {
        EasyLoading.dismiss();
      });
    });
    setState((){});
  }

  Future<void> computeList() async {
    checkVisible(notUser) {
      return showMode == _VisualizationMask.all ||
        (showMode == _VisualizationMask.mine && !notUser) ||
        (showMode == _VisualizationMask.missing && notUser);
    }

    var card = [];
    for(int id=0; id < widget.subExtension.seCards.cards.length; id +=1) {
      var notUser = widget.pokeSpace.cardCounter(widget.subExtension, CardIdentifier.from([0, id, 0])).count() == 0;
      if( checkVisible(notUser) ) {
        card.add(id);
      }
    }
    cards.add(card);

    card = [];
    for(int id=0; id < widget.subExtension.seCards.energyCard.length; id +=1) {
      var notUser = widget.pokeSpace.cardCounter(widget.subExtension, CardIdentifier.from([1, id])).count() == 0;
      if( checkVisible(notUser) ) {
        card.add(id);
      }
    }
    cards.add(card);

    card = [];
    for(int id=0; id < widget.subExtension.seCards.noNumberedCard.length; id +=1) {
      var notUser = widget.pokeSpace.cardCounter(widget.subExtension, CardIdentifier.from([2, id])).count() == 0;
      if( checkVisible(notUser) ) {
        card.add(id);
      }
    }
    cards.add(card);
  }

  Future<bool> returnTo() async {
    Navigator.of(context).pop(edited);
    return true;
  }

  Widget menuBar(BuildContext context, String idText ) {
    return Text(StatitikLocale.of(context).read(idText));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: returnTo,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              widget.subExtension.extension.language.barIcon(),
              const SizedBox(width: 5),
              widget.subExtension.image(wSize: 40, hSize: 40),
              const SizedBox(width: 5),
              Text(widget.subExtension.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: widget.subExtension.name.length > 9 ? 10 : 7
              )),
            ]
          ),
          actions: [
            IconButton(icon: Icon( _vMaskIcons[showMode.index] ),
              onPressed: () {
                // Show next mode
                showMode = _VisualizationMask.values[(showMode.index + 1) % _VisualizationMask.values.length];
                refresh();
            })
          ],
        ),
        body: SafeArea(
          child: cards.isEmpty ? drawLoading(context)
            : Column(
              children: [
                SizedBox(
                  height: Environment.heightTabHeader,
                  child: TabBar(
                  controller: tabController,
                  isScrollable: false,
                  indicatorPadding: const EdgeInsets.all(1),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueAccent,
                  ),
                  tabs: [
                    if(widget.subExtension.seCards.cards.isNotEmpty)
                      menuBar(context, 'S_SERIE_0'),
                    if(widget.subExtension.seCards.energyCard.isNotEmpty)
                      menuBar(context, 'S_SERIE_1'),
                    if(widget.subExtension.seCards.noNumberedCard.isNotEmpty)
                      menuBar(context, 'S_SERIE_2'),
                  ]
              ),
                ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    if(widget.subExtension.seCards.cards.isNotEmpty)
                      GridView.builder(
                        padding: const EdgeInsets.all(1.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                            childAspectRatio: 0.7),
                        itemCount: cards[0].length,
                        itemBuilder: (context, id) {
                          var cardSelector = CardSelectorPokeSpace(widget.subExtension, widget.pokeSpace, CardIdentifier.from([0, cards[0][id], 0]));
                          return PokemonCard(cardSelector, refresh: refresh, readOnly: false, singlePress: true, afterOpenSelector: afterLaunchEditor);
                        },
                      ),
                    if(widget.subExtension.seCards.energyCard.isNotEmpty)
                      GridView.builder(
                        padding: const EdgeInsets.all(1.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                            childAspectRatio: 0.7),
                        itemCount: cards[1].length,
                        itemBuilder: (context, id) {
                          var cardSelector = CardSelectorPokeSpace( widget.subExtension, widget.pokeSpace, CardIdentifier.from([1, cards[1][id]]));
                          return PokemonCard(cardSelector, refresh: refresh, readOnly: false, singlePress: true, afterOpenSelector: afterLaunchEditor);
                        },
                      ),
                    if(widget.subExtension.seCards.noNumberedCard.isNotEmpty)
                      GridView.builder(
                        padding: const EdgeInsets.all(1.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
                            childAspectRatio: 0.7),
                        itemCount: cards[2].length,
                        itemBuilder: (context, id) {
                          var cardSelector = CardSelectorPokeSpace( widget.subExtension, widget.pokeSpace, CardIdentifier.from([2, cards[2][id]]));
                          return PokemonCard(cardSelector, refresh: refresh, readOnly: false, singlePress: true, afterOpenSelector: afterLaunchEditor);
                        },
                      ),
                  ],
                )
              )
            ]
          )
        )
      )
    );
  }
}