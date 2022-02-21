import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardEditor extends StatefulWidget {
  final int                  id;
  final int                  idAlternative = 0;
  final SubExtension         se;
  final PokemonCardExtension card;
  final bool                 isWorldCard;
  final int                  listId;

  CardEditor(this.card, this.isWorldCard, this.se, this.id, this.listId);

  dynamic listOfCard() {
    if( listId == 1)
      return se.seCards.energyCard;
    else if( listId == 2)
      return se.seCards.noNumberedCard;
    else
      return se.seCards.cards;
  }

  String titleCard() {
    var l = Language(id: 1, image: "");
    if( listId == 0 )
      return sprintf("%s %s",
          [ se.seCards.numberOfCard(id),
            se.seCards.titleOfCard(l, id, idAlternative)
          ]);
    else {
      List<PokemonCardExtension> currentCards = listOfCard();
      return sprintf("%s %s",
          [ currentCards[id].numberOfCard(id),
            currentCards[id].data.titleOfCard(l)
          ]);
    }
  }

  PokemonCardExtension nextCard(int nextId) {
    var cardInfo = listOfCard()[nextId];
    return listId == 0 ? cardInfo[0] : cardInfo;
  }

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  @override
  Widget build(BuildContext context) {
    String title = widget.titleCard();

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
            if(widget.id+1 < widget.listOfCard().length)
              Card(
                  color: Colors.grey[800],
                  child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B6')),
                    onPressed: (){
                      int nextId = widget.id+1;
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => CardEditor(widget.nextCard(nextId), widget.isWorldCard, widget.se, nextId, widget.listId)),
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