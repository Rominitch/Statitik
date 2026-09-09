import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/widgets/image/image_with_decoration.dart';

enum PokeCardVisualization {
  name,
  image,
}

class CardsSelection {
  final PokeLanguage       language;
  final PokeExpansion      expansion;
  List<PokeCardIdentifier> selectedCards = [];

  CardsSelection(this.language, this.expansion);
}

class WidgetSelectorCardInExpansion extends StatefulWidget {
  final PokeLanguage  _language;
  final PokeExpansion _expansion;
  const WidgetSelectorCardInExpansion(this._language, this._expansion, {super.key});

  @override
  State<WidgetSelectorCardInExpansion> createState() => _WidgetSelectorCardInExpansionState();
}

class _WidgetSelectorCardInExpansionState extends State<WidgetSelectorCardInExpansion> with TickerProviderStateMixin {
  late TabController     _tabController;

  late CardsSelection      _selection;
  PokeCardVisualization    _modeVisu = PokeCardVisualization.name;

  @override
  void initState() {
    _selection = CardsSelection(widget._language, widget._expansion);

    int count = widget._expansion.cards.countNbLists();
    _tabController = TabController(
        length: count,
        vsync: this,
        animationDuration: Duration.zero);

    super.initState();
  }

  Widget createCardButton(PokeCardInExpansion card, PokeCardIdentifier cardId, PokeCardImageIdentifier imageId) {
    return Card(
        color: _selection.selectedCards.contains(cardId) ? Colors.green : Colors.grey.shade700,
        margin: const EdgeInsets.all(1.5),
        child: TextButton(
          child: _modeVisu == PokeCardVisualization.name ?
          cardId.listId == 1 ?
          Row(
              children: [
                card.imageType(),
                const SizedBox(width: 4.0),
                widget._expansion.cards.cardInfo(cardId),
              ])
              : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                card.imageType(),
                Text(card.card.titleOfCard(widget._language), style: Theme.of(context).textTheme.bodySmall),
                widget._expansion.cards.cardInfo(cardId),
              ]
          )
              : ImageWithDecoration(widget._expansion, card, cardId, imageId, language: widget._language),
          onPressed: (){
            setState(() {
              if(_selection.selectedCards.contains(cardId)) {
                _selection.selectedCards.remove(cardId);
              } else {
                _selection.selectedCards.add(cardId);
              }
            });
          },
        )
    );
  }

  Widget createGridCard(List listCard, int idList) {
    return LayoutBuilder(
      builder: (context, box) {
        final count = _modeVisu == PokeCardVisualization.name
          ? (box.maxWidth / 150.0).ceil()
          : (box.maxWidth / PokeRendering.bestCardWidth).ceil();
        return GridView.builder(
          padding: const EdgeInsets.all(1.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count, crossAxisSpacing: 1, mainAxisSpacing: 1,
            childAspectRatio: _modeVisu == PokeCardVisualization.name ? 1.0 : PokeRendering.bestCardRatio),
          itemCount: listCard.length,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (context, id) {
            var cardListId = [idList, id];
            if(idList == 0) {
              cardListId.add(0);
            }
            var cardId = PokeCardIdentifier.from(cardListId);
            final cardInExp = widget._expansion.cards.cardFromId(cardId);
            return createCardButton(cardInExp, cardId, PokeCardImageIdentifier(cardInExp.setInfo.keys.first));
          },
        );
      }
    );
  }

  Widget menuBar(BuildContext context, String text ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget._expansion.cards;
    final expansionName = widget._expansion.label(widget._language)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
            children: [
              widget._language.barIcon(),
              const SizedBox(width: 5),
              widget._expansion.image(widget._language, hSize: 25.0),
              const SizedBox(width: 5),
              Text(expansionName, softWrap: true, style: TextStyle(fontSize: expansionName.length > 8 ? 10 : 12)),
            ]
        ),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              if(_modeVisu == PokeCardVisualization.name) {
                _modeVisu = PokeCardVisualization.image;
              } else {
                _modeVisu = PokeCardVisualization.name;
              }
            });
          },
              icon: Icon((_modeVisu == PokeCardVisualization.name)
                  ? Icons.text_snippet_outlined : Icons.image_outlined)
          ),
          if( _selection.selectedCards.isNotEmpty )
            Card(
                color: Colors.green,
                child: TextButton(onPressed: () {
                  Navigator.of(context).pop(_selection);
                }, child: Text(AppLocalizations.of(context)!.send))
            )
        ],
      ),
      body:SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorPadding: const EdgeInsets.all(1),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
              ),
              tabs: [
                if(cards.cards.isNotEmpty)
                  menuBar(context, AppLocalizations.of(context)!.s_serie_0),
                if(cards.energyCard.isNotEmpty)
                  menuBar(context, AppLocalizations.of(context)!.s_serie_1),
                if(cards.noNumberedCard.isNotEmpty)
                  menuBar(context, AppLocalizations.of(context)!.s_serie_2),
              ]
            ),
            Expanded(
              child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children:[
                    if(cards.cards.isNotEmpty)
                      createGridCard(cards.cards, 0),
                    if(cards.energyCard.isNotEmpty)
                      createGridCard(cards.energyCard, 1),
                    if(cards.noNumberedCard.isNotEmpty)
                      createGridCard(cards.noNumberedCard, 2),
                  ]
              )
            )
          ]
        )
      )
    );
  }
}
