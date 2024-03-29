import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class CardEditorOptions {
  int tabIndex = 0;

  CardEditorOptions();
}

class CardEditor extends StatefulWidget {
  final CardIdentifier       id;
  final int                  idAlternative = 0;
  final SubExtension         se;
  final PokemonCardExtension card;
  final bool                 isWorldCard;
  final CardEditorOptions    options;

  CardEditor(this.isWorldCard, SubExtension se, CardIdentifier id, [options]) :
    this.se   = se,
    this.id   = id,
    this.card = se.cardFromId(id),
    this.options = options ?? CardEditorOptions();

  String titleCard() {
    var cardId = id.numberId;
    var l = Language(id: 1, image: "");
    if( id.listId == 0 )
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

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  @override
  Widget build(BuildContext context) {
    String title = widget.titleCard();

    var nextCardId = widget.se.seCards.nextId(widget.id);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child:Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(sprintf("%s: %s", [ StatitikLocale.of(context).read('CE_T0'), title]),
              style: Theme.of(context).textTheme.headline6,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          actions: [
            if(nextCardId != null)
              Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('NCE_B6')),
                  onPressed: (){
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => CardEditor(widget.isWorldCard, widget.se, nextCardId, widget.options)),
                    );
                  },
                )
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardCreator.editor(widget.se.extension.language, widget.se, widget.card, widget.id, title, widget.isWorldCard, widget.options),
        )
      )
    );
  }
}