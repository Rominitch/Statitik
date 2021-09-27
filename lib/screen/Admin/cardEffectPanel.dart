import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
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
  List<Widget> effectsWidget = [];

  @override
  void initState() {
    widget.card.data.cardEffects.effects.forEach((effect) {
      effectsWidget.add(CardEffectPanel(widget, effect));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(children: <Widget>[
      Card(
        color: Colors.grey[600],
        child: TextButton(
          child: Text( StatitikLocale.of(context).read('CA_B14') ),
          onPressed: (){
            setState(() {
              var newEffect = new CardEffect();
              widget.card.data.cardEffects.effects.add(newEffect);
              effectsWidget.add(CardEffectPanel(widget, newEffect));
            });
          }
        )
      ),
    ] + effectsWidget,
    crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}

class CardEffectPanel extends StatefulWidget {
  final CardEffect effect;
  final CardEffectsPanel parent;

  const CardEffectPanel(this.parent, this.effect, {Key? key}) : super(key: key);

  @override
  _CardEffectPanelState createState() => _CardEffectPanelState();
}

class _CardEffectPanelState extends State<CardEffectPanel> {
  List<CustomRadioController> powerControllers = [];
  List<List<Widget>> powersWidgets = [];
  double typeSize = 40.0;


  void onTypeChanged(id, effect, value) {
    effect.attack[id] = value;
  }

  @override
  void initState() {
    // Fill with 5 elements
    while(widget.effect.attack.length < 5) {
      widget.effect.attack.add(Type.Unknown);
    }

    int id=0;
    for(var element in widget.effect.attack) {
      var newList = <Widget>[];
      int localI = id;
      var typeController = CustomRadioController(onChange: (value) {  onTypeChanged(localI, widget.effect, value); });
      powerControllers.add( typeController );

      newList.add(CustomRadio(value: Type.Unknown, controller: typeController, widget: getImageType(Type.Unknown), widthBox: typeSize));
      energies.forEach((element) {
        newList.add(CustomRadio(value: element, controller: typeController, widget: getImageType(element), widthBox: typeSize));
      });
      typeController.afterPress(element);
      powersWidgets.add(newList);
      id += 1;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String name= StatitikLocale.of(context).read('CA_B23');
    String description=StatitikLocale.of(context).read('CA_B24');
    double value1 = 0.0;
    double value2 = 0.0;
    if(widget.effect.title != null) {
      name = Environment.instance.collection.effects[widget.effect.title!].name(widget.parent.l);
    }
    if(widget.effect.description != null) {
      description = widget.effect.description!.decrypted(Environment.instance.collection.descriptions, widget.parent.l).finalString.join();
      value1 = widget.effect.description!.parameters.isNotEmpty ? widget.effect.description!.parameters[0].toDouble() : 0.0;
      value2 = widget.effect.description!.parameters.length > 1 ? widget.effect.description!.parameters[1].toDouble() : 0.0;
    }

    return Card(
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
                    MaterialPageRoute(builder: (context) => ListSelector('CA_T3', widget.parent.l, Environment.instance.collection.effects)),
                  ).then((value) {
                    setState(() {
                      if(value != null)
                        widget.effect.title = value;
                    });
                  });
                });
              }, child: Text(name)),
            ),
            if(widget.effect.title != null)
              Row(
                  children: [
                    Text(StatitikLocale.of(context).read('CA_B21')),
                    Expanded(
                      child:SpinBox(value: widget.effect.power.toDouble(), max: 300,
                          onChanged: (value){
                            setState(() {
                              widget.effect.power = value.toInt();
                            });
                          }),
                    )
                  ]
              ),
            if(widget.effect.title != null)
            Container(height: typeSize, child: ListView(children: powersWidgets[0], scrollDirection: Axis.horizontal, primary: false)),
            if(widget.effect.title != null)
            Container(height: typeSize, child: ListView(children: powersWidgets[1], scrollDirection: Axis.horizontal, primary: false)),
            if(widget.effect.title != null)
            Container(height: typeSize, child: ListView(children: powersWidgets[2], scrollDirection: Axis.horizontal, primary: false)),
            if(widget.effect.title != null)
            Container(height: typeSize, child: ListView(children: powersWidgets[3], scrollDirection: Axis.horizontal, primary: false)),
            if(widget.effect.title != null)
            Container(height: typeSize, child: ListView(children: powersWidgets[4], scrollDirection: Axis.horizontal, primary: false)),
            //Description
            Card(
              color: Colors.grey[600],
              child: TextButton(onPressed: (){
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListSelector('CA_T4', widget.parent.l, Environment.instance.collection.descriptions)),
                  ).then((value) {
                    setState(() {
                      if(value != null) {
                        if(widget.effect.description == null) {
                          widget.effect.description = CardDescription(value);
                        }
                        else widget.effect.description!.idDescription = value;
                      }
                    });
                  });
                });
              }, child: Text(description, softWrap: true)),
            ),
            // Value 1 int
            if(widget.effect.description != null)
              Row(
                  children: [
                    Text(StatitikLocale.of(context).read('CA_B19')),
                    Expanded(
                      child: SpinBox(value: value1, max: 300,
                          onChanged: (value){
                            setState(() {
                              if (widget.effect.description!.parameters.isEmpty)
                                widget.effect.description!.parameters.add(value.toInt());
                              else
                                widget.effect.description!.parameters[0] = value.toInt();
                            });
                          }),
                    )
                  ]
              ),
            // Value 2 int
            if(widget.effect.description != null && widget.effect.description!.parameters.length > 0)
              Row(
                  children: [
                    Text(StatitikLocale.of(context).read('CA_B20')),
                    Expanded(
                      child:SpinBox(value: value2, max: 300,
                          onChanged: (value){
                            setState(() {
                              if(widget.effect.description!.parameters.length == 1)
                                widget.effect.description!.parameters.add(value.toInt());
                              else
                                widget.effect.description!.parameters[1] = value.toInt();
                            });
                          }),
                    )
                  ]
              ),
          ]
      )
    );
  }
}

