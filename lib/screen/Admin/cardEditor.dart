import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

class CardEditorOptions {
  int tabIndex = 0;

  CardEditorOptions();
}

class CardEditor extends StatefulWidget {
  final CardIdentifier       id;
  final SubExtension         se;
  final PokemonCardExtension card;
  final CardEditorOptions    options;

  CardEditor(this.se, this.id, this.options, {Key? key}) :
    card = se.cardFromId(id), super(key: key);

  String titleCard() {
    var cardId = id.numberId;
    var l = Language(id: 1, image: "");
    if( id.listId == 0 ) {
      return "${se.seCards.numberOfCard(cardId)} - ${se.seCards.titleOfCard(l, cardId, id.alternativeId)}";
    } else {
      return "${card.numberOfCard(cardId)} - ${card.data.titleOfCard(l)}";
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
          title: Row(
            children:
            [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.headline6, softWrap: true, maxLines: 2)),
              getImageType(widget.card.data.type),
            ] + getImageRarity(widget.card.rarity, widget.se.extension.language)
          ),
          actions: [
            if(nextCardId != null)
              Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('NCE_B6')),
                  onPressed: (){
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => CardEditor(widget.se, nextCardId, widget.options)),
                    );
                  },
                )
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardCreator.editor(widget.se.extension.language, widget.se, widget.card, widget.id, title, widget.options),
        )
      )
    );
  }
}