import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class CardEditor extends StatefulWidget {
  final List<int>            id;
  final int                  idAlternative = 0;
  final SubExtension         se;
  final PokemonCardExtension card;
  final bool                 isWorldCard;

  CardEditor(this.card, this.isWorldCard, this.se, this.id);

  dynamic listOfCard() {
    if( id[0] == 1)
      return se.seCards.energyCard;
    else if( id[0] == 2)
      return se.seCards.noNumberedCard;
    else
      return se.seCards.cards;
  }

  String titleCard() {
    var cardId = id[1];
    var l = Language(id: 1, image: "");
    if( id[0] == 0 )
      return sprintf("%s %s",
          [ se.seCards.numberOfCard(cardId),
            se.seCards.titleOfCard(l, cardId, idAlternative)
          ]);
    else {
      return sprintf("%s %s",
          [ card.numberOfCard(cardId),
            card.data.titleOfCard(l)
          ]);
    }
  }

  PokemonCardExtension nextCard(int nextId) {
    var cardInfo = listOfCard()[nextId];
    return id[0] == 0 ? cardInfo[0] : cardInfo;
  }

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  @override
  Widget build(BuildContext context) {
    String title = widget.titleCard();

    int nextCardId = widget.id[1]+1;
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(sprintf("%s: %s", [ StatitikLocale.of(context).read('CE_T0'), title]),
              style: Theme.of(context).textTheme.headline6,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          actions: [
            if(nextCardId < widget.listOfCard().length)
              Card(
                  color: Colors.grey[800],
                  child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B6')),
                    onPressed: (){
                      var nextId = List<int>.from(widget.id, growable: false);
                      nextId[1] = nextCardId;
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => CardEditor(widget.nextCard(nextId[1]), widget.isWorldCard, widget.se, nextId)),
                      );
                    },
                  )
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CardCreator.editor(widget.se.extension.language, widget.se, widget.card, widget.id, title, widget.isWorldCard),
            ]
          )
        )
    );
  }
}