import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardEditor extends StatefulWidget {
  final int                  id;
  final int                  idAlternative = 0;
  final SubExtension         se;
  final PokemonCardExtension card;
  final bool                 isWorldCard;

  CardEditor(this.card, this.isWorldCard, this.se, this.id);

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  @override
  Widget build(BuildContext context) {
    String title = sprintf("%s %s",
        [ widget.se.seCards.numberOfCard(widget.id),
          widget.se.seCards.titleOfCard(Language(id: 1, image: ""), widget.id, widget.idAlternative)
        ]);

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
            if(widget.id+1 < widget.se.seCards.cards.length)
              Card(
                  color: Colors.grey[800],
                  child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B6')),
                    onPressed: (){
                      int nextId = widget.id+1;
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => CardEditor(widget.se.seCards.cards[nextId][0], widget.isWorldCard, widget.se, nextId)),
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