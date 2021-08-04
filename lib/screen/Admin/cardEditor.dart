import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardEditor extends StatefulWidget {
  final int       id;
  final ListCards cards;
  final PokeCard  card;
  final bool      isWorldCard;

  const CardEditor(this.card, this.isWorldCard, this.cards, this.id);

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  Function(int?) demo = (int? i){};

  @override
  Widget build(BuildContext context) {
    NamedInfo? name = widget.card.name;

    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(sprintf("%s: %d %s",
                [StatitikLocale.of(context).read('CE_T0'), widget.id+1, name != null ? name.defaultName() : ""]
              ),
              style: Theme.of(context).textTheme.headline6,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          actions: [
            if(widget.id+1 < widget.cards.cards.length)
              Card(
                  color: Colors.grey[800],
                  child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B6')),
                    onPressed: (){
                      int nextId = widget.id+1;
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => CardEditor(widget.cards.cards[nextId], widget.isWorldCard, widget.cards, nextId)),
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
            children: [
              CardCreator.editor(widget.card, widget.isWorldCard),
              Card(
                color: Colors.grey[700],
                child: TextButton(
                  child: Text((name != null && name.isPokemon()) ? name.defaultName() : ""),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChooserCardName(Environment.instance.collection.pokemons.values.toList(), name)),
                    ).then((value) {
                      if(value != null) {
                        setState(() {
                          widget.card.name = value;
                        });
                      }
                    });
                  },
                )
              ),
              Card(
                  color: Colors.grey[700],
                  child: TextButton(
                    child: Text((name != null && !name.isPokemon()) ? name.defaultName() : ""),
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChooserCardName(Environment.instance.collection.otherNames.values.toList(), name)),
                      ).then((value) {
                        if(value != null) {
                          setState(() {
                            widget.card.name = value;
                          });
                        }
                      });
                    },
                  )
              )
            ]
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