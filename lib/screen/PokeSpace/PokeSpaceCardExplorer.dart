import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';

import 'package:statitikcard/screen/widgets/CardSelector/CardSelectorPokeSpace.dart';
import 'package:statitikcard/screen/widgets/PokemonCard.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

enum _VisualizationMask {
  All,
  Mine,
  Missing
}
var _vMaskIcons = const[
  Icons.grid_on,
  Icons.grid_view,
  Icons.grid_off
];

class PokeSpaceCardExplorer extends StatefulWidget {
  final SubExtension subExtension;
  final PokeSpace    pokeSpace;

  const PokeSpaceCardExplorer(this.subExtension, this.pokeSpace);

  @override
  _PokeSpaceCardExplorerState createState() => _PokeSpaceCardExplorerState();
}

class _PokeSpaceCardExplorerState extends State<PokeSpaceCardExplorer> with SingleTickerProviderStateMixin {
  _VisualizationMask showMode = _VisualizationMask.All;
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
    var checkVisible = (notUser) {
      return showMode == _VisualizationMask.All ||
        (showMode == _VisualizationMask.Mine && !notUser) ||
        (showMode == _VisualizationMask.Missing && notUser);
    };

    var card = [];
    for(int id=0; id < widget.subExtension.seCards.cards.length; id +=1) {
      var notUser = widget.pokeSpace.cardCounter(widget.subExtension, CardIdentifier.from([0, id, 0])).count() == 0;
      if( checkVisible(notUser) )
        card.add(id);
    }
    cards.add(card);

    card = [];
    for(int id=0; id < widget.subExtension.seCards.energyCard.length; id +=1) {
      var notUser = widget.pokeSpace.cardCounter(widget.subExtension, CardIdentifier.from([1, id])).count() == 0;
      if( checkVisible(notUser) )
        card.add(id);
    }
    cards.add(card);

    card = [];
    for(int id=0; id < widget.subExtension.seCards.noNumberedCard.length; id +=1) {
      var notUser = widget.pokeSpace.cardCounter(widget.subExtension, CardIdentifier.from([2, id])).count() == 0;
      if( checkVisible(notUser) )
        card.add(id);
    }
    cards.add(card);
  }

  Future<bool> returnTo() async {
    Navigator.of(context).pop(edited);
    return true;
  }

  Widget menuBar(BuildContext context, String idText ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(StatitikLocale.of(context).read(idText)),
    );
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
              SizedBox(width: 5),
              widget.subExtension.image(wSize: 40, hSize: 40),
              SizedBox(width: 5),
              Text(widget.subExtension.name, style: Theme.of(context).textTheme.headline5?.copyWith(
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
                TabBar(
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
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    if(widget.subExtension.seCards.cards.isNotEmpty)
                      GridView.builder(
                        padding: EdgeInsets.all(1.0),
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
                        padding: EdgeInsets.all(1.0),
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
                        padding: EdgeInsets.all(1.0),
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