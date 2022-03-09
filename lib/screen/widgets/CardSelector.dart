import 'package:flutter/material.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/PokeSpace.dart';
import 'package:statitikcard/services/models/ProductDraw.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

abstract class GenericCardSelector {

  GenericCardSelector();

  SubExtension         subExtension();
  PokemonCardExtension cardExtension();
  CodeDraw             codeDraw();

  void increase(int idSet);
  void decrease(int idSet);
  void setOnly(int idSet);

  Widget? advancedWidget(BuildContext context, Function refresh);

  Color backgroundColor();
  Widget cardWidget();

  void toggle();
}

class CardSelectorBoosterDraw extends GenericCardSelector {
  final BoosterDraw          boosterDraw;
  final PokemonCardExtension card;
  final CodeDraw             counter;
  late List<int>             idCard;

  CardSelectorBoosterDraw(this.boosterDraw, this.card, this.counter): super()
  {
    idCard = boosterDraw.subExtension!.seCards.computeIdCard(card);
  }

  @override
  CodeDraw codeDraw(){
    return counter;
  }

  @override
  SubExtension subExtension() {
    return boosterDraw.subExtension!;
  }

  @override
  PokemonCardExtension cardExtension() {
    return card;
  }

  @override
  void increase(int idSet)
  {
    boosterDraw.increase(counter, idSet);
  }

  @override
  void decrease(int idSet)
  {
    boosterDraw.decrease(counter, idSet);
  }

  @override
  void setOnly(int idSet)
  {
    boosterDraw.setOtherRendering(counter, idSet);
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return null;
  }

  @override
  void toggle() {
    boosterDraw.toggle(counter, 0);
  }

  @override
  Color backgroundColor() {
    return counter.color(card);
  }

  @override
  Widget cardWidget() {
    int nbCard = codeDraw().count();
    switch(idCard[0]) {
      case 0: return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            if(card.isValid())
              Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [card.imageType()] + card.imageRarity(subExtension().extension.language)),
            if(card.isValid()) SizedBox(height: 6.0),
            if( nbCard > 1)
              Text('${boosterDraw.nameCard(idCard[1])} ($nbCard)')
            else
              Text('${boosterDraw.nameCard(idCard[1])}')
          ]
        );
      case 1 : return getImageType(card.data.typeExtended ?? TypeCard.Unknown);
      default:
        throw StatitikException("No visual for this card");
    }
  }
}

class CardSelectorProductCard extends GenericCardSelector {
  final ProductCard card;
  late List<int> idCard;

  CardSelectorProductCard(this.card): super() {
    idCard = subExtension().seCards.computeIdCard(card.card);
  }

  @override
  CodeDraw codeDraw(){
    return card.counter;
  }

  @override
  SubExtension subExtension() {
    return card.subExtension;
  }

  @override
  PokemonCardExtension cardExtension() {
    return card.card;
  }

  @override
  void increase(int idSet)
  {
    if(card.counter.countBySet[idSet] < 256)
      card.counter.countBySet[idSet] += 1;
  }

  @override
  void decrease(int idSet)
  {
    if(card.counter.countBySet[idSet] > 0)
      card.counter.countBySet[idSet] -= 1;
  }

  @override
  void setOnly(int idSet)
  {
    card.counter.reset();
    card.counter.countBySet[idSet] = 1;
  }

  @override
  Widget? advancedWidget(BuildContext context, Function refresh) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            children:[
              Expanded(
                child: Card(
                    color: card.jumbo ? Colors.green : Colors.grey,
                    child: TextButton(
                      child: Text(StatitikLocale.of(context).read('CS_B0'), style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        card.jumbo = !card.jumbo;
                        refresh();
                      },
                    )
                ),
              ),
              Expanded(
                child: Card(
                    color: card.isRandom ? Colors.green : Colors.grey,
                    child: TextButton(
                      child: Text(StatitikLocale.of(context).read('CS_B1'), style: Theme.of(context).textTheme.headline5),
                      onPressed: () {
                        card.isRandom = !card.isRandom;
                        refresh();
                      },
                    )
                ),
              )
            ]
        )
      ]
    );
  }

  @override
  Color backgroundColor() {
    return Colors.deepOrange.shade300;
  }

  @override
  Widget cardWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              subExtension().image(hSize: 30),
              card.card.imageType(),
            ]
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(subExtension().seCards.numberOfCard(idCard[1])),
              card.isRandom ? Text("R") : Text(card.counter.countBySet.join(" | "))
            ]
        ),
      ],
    );
  }

  @override
  void toggle() {
    if(card.counter.count() == 0)
      card.counter.countBySet[0] = 1;
    else
      card.counter.reset();
  }
}

class CardSelector extends StatefulWidget {
  final GenericCardSelector cardSelector;

  final Function? refresh;
  final bool     readOnly;

  CardSelector(this.cardSelector, {this.refresh, this.readOnly=false});

  @override
  _CardSelectorState createState() => _CardSelectorState();
}

class _CardSelectorState extends State<CardSelector> {
  List<Widget> cardModes = [];

  @override
  void initState() {
    // Create for all set each widget
    int idSet=0;
    cardModes.clear();
    widget.cardSelector.cardExtension().sets.forEach((set) {
      cardModes.add(IconCard(widget.cardSelector, idSet, set, refresh: widget.refresh, readOnly: widget.readOnly));
      idSet += 1;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget? advanced = widget.cardSelector.advancedWidget(context, () {setState(() {})} );
    return SimpleDialog(
      title: Text(StatitikLocale.of(context).read('V_B4')),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: cardModes
        ),
        if(advanced != null) advanced
      ]
    );
  }
}

class IconCard extends StatefulWidget {
  final GenericCardSelector cardSelector;
  final int           setId;
  final CardSet       set;

  final Function?     refresh;
  final bool          readOnly;

  IconCard(this.cardSelector, this.setId, this.set, {required this.refresh, required this.readOnly});

  @override
  _IconCardState createState() => _IconCardState();
}

class _IconCardState extends State<IconCard> {
  final Color? background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.cardSelector.codeDraw().getCountFrom(widget.setId);
    return  Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: count > 0 ? widget.set.color : background,
                child: TextButton(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Image(image: AssetImage('assets/carte/${widget.set.image}.png'), width: 75.0),
                        SizedBox(height: 6.0),
                        Text(widget.set.names.name(widget.cardSelector.subExtension().extension.language)),
                      ]),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                  onPressed: widget.readOnly ? null : () {
                    widget.cardSelector.setOnly(widget.setId);

                    Navigator.of(context).pop();
                    if(widget.refresh!=null)
                      widget.refresh!();
                  },
                ),
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: widget.readOnly ? null : () {
                        setState(() {
                          widget.cardSelector.increase(widget.setId);
                        });
                        if(widget.refresh!=null)
                          widget.refresh!();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: background, // background
                      ),
                      child: Container(
                        child: Text('+', style: TextStyle(fontSize: 20)),
                      )
                  ),
                  Container(
                      child: Text('$count', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),)
                  ),
                  ElevatedButton(
                      onPressed: widget.readOnly ? null : () {
                        setState(() {
                          widget.cardSelector.decrease(widget.setId);
                          /*
                          if(widget.boosterDraw != null)
                            widget.boosterDraw!.decrease(widget.code, widget.setId);
                          else if(widget.code.countBySet[widget.setId] > 0)
                            widget.code.countBySet[widget.setId] -= 1;

                           */
                        });
                        if(widget.refresh!=null)
                          widget.refresh!();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: background, // background
                      ),
                      child: Container(
                        child: Text('-', style: TextStyle(fontSize: 20)),
                      )
                  ),
                ],
              )
            ],
          )
      );
  }
}
