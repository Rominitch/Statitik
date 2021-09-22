import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:statitikcard/screen/widgets/ListSelector.dart';
import 'package:statitikcard/services/CardEffect.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardEffectsPanel extends StatefulWidget {
  final Language             l;
  final PokemonCardExtension card;

  const CardEffectsPanel(this.card, this.l, {Key? key}) : super(key: key);

  @override
  _CardEffectsPanelState createState() => _CardEffectsPanelState();
}

class _CardEffectsPanelState extends State<CardEffectsPanel> {
  @override
  Widget build(BuildContext context) {
    List<Widget> effectsWidget = [];
    for(var effect in widget.card.data.effects) {
      String name= StatitikLocale.of(context).read('CA_B23');
      String description=StatitikLocale.of(context).read('CA_B24');
      double value1 = 0.0;
      double value2 = 0.0;
      if(effect.title != null) {
        name = Environment.instance.collection.effects[effect.title!].name(widget.l);
      }
      if(effect.description != null) {
        description = effect.description!.decrypted(Environment.instance.collection.descriptions, widget.l).finalString.join();
      }
      effectsWidget.add(Card(
          color: Colors.grey[800],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Effect
              Card(
                color: Colors.grey[600],
                child: TextButton(onPressed: (){
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ListSelector('CA_T3', widget.l, Environment.instance.collection.effects)),
                      ).then((value) {
                        setState(() {
                          if(value != null)
                            effect.title = value;
                        });
                      });
                    });
                  }, child: Text(name)),
              ),
              if(effect.title != null)
              Row(
                  children: [
                    Text(StatitikLocale.of(context).read('CA_B21')),
                    Expanded(
                      child:SpinBox(value: value2, max: 300,
                        onChanged: (value){
                          setState(() {
                            effect.power = value.toInt();
                          });
                        }),
                    )
                  ]
              ),
              //Description
              Card(
                color: Colors.grey[600],
                child: TextButton(onPressed: (){
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListSelector('CA_T4', widget.l, Environment.instance.collection.descriptions)),
                    ).then((value) {
                      setState(() {
                        if(value != null) {
                          if(effect.description == null) {
                            effect.description = CardDescription(value);
                          }
                          else effect.description!.idDescription = value;
                        }
                      });
                    });
                  });
                }, child: Text(description, softWrap: true)),
              ),
              // Value 1 int
              if(effect.description != null)
              Row(
                children: [
                  Text(StatitikLocale.of(context).read('CA_B19')),
                  Expanded(
                    child: SpinBox(value: value1, max: 300,
                    onChanged: (value){
                      setState(() {
                        if (effect.description!.parameters.isEmpty)
                          effect.description!.parameters.add(value.toInt());
                        else
                          effect.description!.parameters[0] = value.toInt();
                      });
                    }),
                  )
                ]
              ),
              // Value 2 int
              if(effect.description != null && effect.description!.parameters.length > 0)
              Row(
                children: [
                  Text(StatitikLocale.of(context).read('CA_B20')),
                  Expanded(
                    child:SpinBox(value: value2, max: 300,
                      onChanged: (value){
                        setState(() {
                          if(effect.description!.parameters.length == 1)
                            effect.description!.parameters.add(value.toInt());
                          else
                            effect.description!.parameters[1] = value.toInt();
                        });
                      }),
                    )
                  ]
              ),
            ]
          )
        )
      );
    }

    return Column(children: <Widget>[
      Card(
        color: Colors.grey[600],
        child: TextButton(
          child: Text( StatitikLocale.of(context).read('CA_B14') ),
          onPressed: (){
            setState(() {
              widget.card.data.effects.add(new CardEffect());
            });
          }
        )
      ),
    ] + effectsWidget,
    crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}
