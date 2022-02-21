import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/EnergyButton.dart';
import 'package:statitikcard/screen/widgets/SliderWithText.dart';

import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class EnergySlider extends StatefulWidget {
  final EnergyValue energyValue;
  final int         defaultValue;
  final dynamic minValue;
  final dynamic maxValue;
  final int?    division;
  const EnergySlider(this.energyValue, this.defaultValue, this.minValue, this.maxValue, {this.division});

  @override
  _EnergySliderState createState() => _EnergySliderState();
}

class _EnergySliderState extends State<EnergySlider> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EnergyButton(EBEnergyValueController(widget.energyValue, widget.defaultValue, (){ setState(() {});})),
        if(widget.energyValue.energy != Type.Unknown )
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
