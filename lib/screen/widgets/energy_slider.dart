import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/energy_button.dart';
import 'package:statitikcard/screen/widgets/slider_with_text.dart';

import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

class EnergySlider extends StatefulWidget {
  final EnergyValue energyValue;
  final int         defaultValue;
  final dynamic minValue;
  final dynamic maxValue;
  final int?    division;
  const EnergySlider(this.energyValue, this.defaultValue, this.minValue, this.maxValue, {this.division, Key? key}) : super(key: key);

  @override
  State<EnergySlider> createState() => _EnergySliderState();
}

class _EnergySliderState extends State<EnergySlider> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EnergyButton(EBEnergyValueController(widget.energyValue, widget.defaultValue, (){ setState(() {});})),
        if(widget.energyValue.energy != TypeCard.unknown )
          Expanded(
            child: SliderInfo( SliderInfoController(() {
              return widget.energyValue.value.toDouble();
            },
            (double value){
                widget.energyValue.value = value.round().toInt();
            }),
            widget.minValue, widget.maxValue,
            division: widget.division),
          ),
      ]
    );
  }
}
