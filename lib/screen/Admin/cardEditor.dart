import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardEditor extends StatefulWidget {
  final int          id;
  final SubExtension se;
  final PokeCard     card;
  final bool         isWorldCard;

  CardEditor(this.card, this.isWorldCard, this.se, this.id) {
    // Add minimal name (can be empty)
    if(card.names.isEmpty) {
      card.names.add(CardName());
    }
  }

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  Function(int?) demo = (int? i){};

  @override
  Widget build(BuildContext context) {
    List<Widget> namedWidgets = [];
    int id=0;
    widget.card.names.forEach((element) {
      namedWidgets.add(PokeCardNaming(widget.card, id));
      id+=1;
    });
    namedWidgets.add(
        Card(child: TextButton(
          child: Text(StatitikLocale.of(context).read('NCE_B7')),
            onPressed: () {
              setState(() {
                widget.card.names.add(CardName());
              });
            },
          )
        )
    );

    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(sprintf("%s: %s %s",
                [StatitikLocale.of(context).read('CE_T0'), widget.se.numberOfCard(widget.id), widget.se.info().getName(Language(id: 1, image: ""), widget.id)]
              ),
              style: Theme.of(context).textTheme.headline6,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          actions: [
            if(widget.id+1 < widget.se.info().cards.length)
              Card(
                  color: Colors.grey[800],
                  child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B6')),
                    onPressed: (){
                      int nextId = widget.id+1;
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => CardEditor(widget.se.info().cards[nextId], widget.isWorldCard, widget.se, nextId)),
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
              CardCreator.editor(widget.card, widget.isWorldCard),
            ] + namedWidgets
          )
        )
    );
  }
}

class ChooserCardName extends StatelessWidget {
  final List    names;
  final dynamic selected;
  ChooserCardName(this.names, this.selected);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(StatitikLocale.of(context).read('CE_T0')),
          ),
        ),
        body: ListView.builder(

          itemBuilder: (context, id){
            var info = names[id];
            return Card(
                color: info == selected ? Colors.green : Colors.grey[700],
                child: TextButton(
                  onPressed: (){
                    Navigator.pop(context, info);
                  },
                  child: Text(info.defaultName())
                )
            );
          },
          itemCount: names.length,
        )
    );
  }
}