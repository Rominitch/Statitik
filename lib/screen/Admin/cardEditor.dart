import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardEditor extends StatefulWidget {
  final PokeCard  card;
  final bool      isWorldCard;

  const CardEditor(this.card, this.isWorldCard);

  @override
  _CardEditorState createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  Function(int?) demo = (int? i){};

  @override
  Widget build(BuildContext context) {
    dynamic name = widget.card.name;

    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(StatitikLocale.of(context).read('CE_T0')),
          ),
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
                  child: Text((name != null && name.isPokemon()) ? name.names[0] : ""),
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
                    child: Text((name != null && !name.isPokemon()) ? name.names[0] : ""),
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
                  child: Text(info.names[0])
                )
            );
          },
          itemCount: names.length,
        )
    );
  }
}