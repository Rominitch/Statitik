import 'package:flutter/material.dart';
import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

abstract class EnergyButtonController {
  void setValue(TypeCard type);

  TypeCard value();
}

class EBEffectController extends EnergyButtonController {
  CardEffect effect;
  int id;

  EBEffectController(this.effect, this.id);

  @override
  void setValue(TypeCard type) {
    effect.attack[id] = type;
  }

  @override
  TypeCard value() {
    return effect.attack[id];
  }
}

class EBEnergyValueController extends EnergyButtonController {
  EnergyValue energyValue;
  int         autoValue;
  dynamic     afterEdit;

  EBEnergyValueController(this.energyValue, this.autoValue, this.afterEdit);

  @override
  void setValue(TypeCard type) {
    if(energyValue.energy == TypeCard.unknown && energyValue.value == 0) {
      energyValue.value = autoValue;
    }
    energyValue.energy = type;
    afterEdit();
  }

  @override
  TypeCard value() {
    return energyValue.energy;
  }
}

class EnergyButton extends StatefulWidget {
  final EnergyButtonController controller;

  const EnergyButton(this.controller, {Key? key}) : super(key: key);

  @override
  State<EnergyButton> createState() => _EnergyButtonState();
}

class _EnergyButtonState extends State<EnergyButton> {
  final List types = List.unmodifiable([TypeCard.unknown] + energies);

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
        showDialog<TypeCard>(
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
