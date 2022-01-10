import 'package:flutter/material.dart';
import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/models.dart';

class EnergyButtonController {
  CardEffect effect;
  int id;

  EnergyButtonController(this.effect, this.id);

  void setValue(Type type) {
    effect.attack[id] = type;
  }

  Type value() {
    return effect.attack[id];
  }
}

class EnergyButton extends StatefulWidget {
  final EnergyButtonController controller;

  const EnergyButton(this.controller);

  @override
  _EnergyButtonState createState() => _EnergyButtonState();
}

class _EnergyButtonState extends State<EnergyButton> {
  final List types = List.unmodifiable([Type.Unknown] + energies);

  SimpleDialog energyPadDialog(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: 0),
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: GridView.builder(
            padding: EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 2, mainAxisSpacing: 2),
            itemCount: types.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, id) {
              return Card(
                child: IconButton(onPressed: (){
                  Navigator.pop(context, types[id]);
                }, icon: getImageType(types[id])),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IconButton(onPressed: (){
        showDialog<Type>(
          context: context,
          builder: (BuildContext context) {
              return energyPadDialog(context);
            }
          ).then((type) {
            // Update value
            if(type != null) {
              setState(() {
                widget.controller.setValue(type);
              });
            }
          });
        },
        icon: getImageType(widget.controller.value())),
    );
  }
}
