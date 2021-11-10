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

    return Column(children: effectsWidget + <Widget>[
      Card(
        color: Colors.greenAccent,
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
    ],
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

  static const double maxParam = 1000.0;

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
    int nbParameters = 0;
    if(widget.effect.title != null) {
      name = Environment.instance.collection.effects[widget.effect.title!].name(widget.parent.l);
    }

    List<Widget> parameterWidgets = [];
    if(widget.effect.description != null) {
      description = widget.effect.description!.decrypted(Environment.instance.collection.descriptions, widget.parent.l).finalString.join();
      RegExp re = RegExp(r"{.*}");
      nbParameters = re.allMatches(description).length;
      //value1 = widget.effect.description!.parameters.isNotEmpty ? widget.effect.description!.parameters[0].toDouble() : 0.0;
      //value2 = widget.effect.description!.parameters.length > 1 ? widget.effect.description!.parameters[1].toDouble() : 0.0;
      //value3 = widget.effect.description!.parameters.length > 2 ? widget.effect.description!.parameters[1].toDouble() : 0.0;
      int id = 0;
      while( id < nbParameters) {
        // Create parameter if needed
        if( id >= widget.effect.description!.parameters.length)
          widget.effect.description!.parameters.add(0);

        int localId = id;
        parameterWidgets.add(
          Row(
            children: [
              Text(StatitikLocale.of(context).read('CA_B19')),
              Expanded(
                child: SpinBox(value: widget.effect.description!.parameters[localId].toDouble(), max: maxParam,
                    onChanged: (value){
                      setState(() {
                        if (widget.effect.description!.parameters.isEmpty)
                          widget.effect.description!.parameters.add(value.toInt());
                        else
                          widget.effect.description!.parameters[localId] = value.toInt();
                      });
                    }),
              )
            ]
          )
        );
        id += 1;
      }
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
                  Map finalEffectList = {};
                  for(var effect in Environment.instance.collection.descriptions.entries) {

                    var d = CardDescription(effect.key);
                    finalEffectList[effect.key] = MultiLanguageString(
                        [
                          d.decrypted(Environment.instance.collection.descriptions, Environment.instance.collection.languages[1]).finalString.join(),
                          d.decrypted(Environment.instance.collection.descriptions, Environment.instance.collection.languages[2]).finalString.join(),
                          d.decrypted(Environment.instance.collection.descriptions, Environment.instance.collection.languages[3]).finalString.join(),
                        ]);
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListSelector('CA_T4', widget.parent.l, finalEffectList)),
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
          ] + parameterWidgets
      )
    );
  }
}

