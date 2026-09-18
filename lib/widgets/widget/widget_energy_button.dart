import 'package:flutter/material.dart';
import 'package:statitikcard/models/card/poke_card_effect.dart';
import 'package:statitikcard/models/card/poke_card_energy_value.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/card/poke_card_energy_value.dart';

abstract class WidgetEnergyButtonController {
  void setValue(PokeCardType type);

  PokeCardType value();
}

class WidgetEnergyButtonEffectController extends WidgetEnergyButtonController {
  PokeCardEffect effect;
  int id;

  WidgetEnergyButtonEffectController(this.effect, this.id);

  @override
  void setValue(PokeCardType type) {
    effect.attack[id] = type;
  }

  @override
  PokeCardType value() {
    return effect.attack[id];
  }
}

class WidgetEnergyButtonEnergyValueController extends WidgetEnergyButtonController {
  PokeEnergyValue energyValue;
  int         autoValue;
  dynamic     afterEdit;

  WidgetEnergyButtonEnergyValueController(this.energyValue, this.autoValue, this.afterEdit);

  @override
  void setValue(PokeCardType type) {
    if(energyValue.energy == PokeCardType.unknown && energyValue.value == 0) {
      energyValue.value = autoValue;
    }
    energyValue.energy = type;
    afterEdit();
  }

  @override
  PokeCardType value() {
    return energyValue.energy;
  }
}

class WidgetEnergyButton extends StatefulWidget {
  final WidgetEnergyButtonController controller;

  const WidgetEnergyButton(this.controller, {super.key});

  @override
  State<WidgetEnergyButton> createState() => _WidgetEnergyButtonState();
}

class _WidgetEnergyButtonState extends State<WidgetEnergyButton> {
  final List types = List.unmodifiable([PokeCardType.unknown] + energies);

  SimpleDialog energyPadDialog(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0),
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
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
        showDialog<PokeCardType>(
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
