import 'package:flutter/material.dart';
import 'package:statitikcard/models/card/poke_card_energy_value.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/widgets/widget/widget_energy_button.dart';
import 'package:statitikcard/widgets/widget/widget_slider_info.dart';

class WidgetEnergySlider extends StatefulWidget {
  final PokeEnergyValue? energyValue;
  final int         defaultValue;
  final dynamic minValue;
  final dynamic maxValue;
  final int?    division;
  final Function(PokeEnergyValue?) updateValue;
  const WidgetEnergySlider(this.energyValue, this.defaultValue, this.minValue, this.maxValue, {this.division, required this.updateValue, super.key});

  @override
  State<WidgetEnergySlider> createState() => _WidgetEnergySliderState();
}

class _WidgetEnergySliderState extends State<WidgetEnergySlider> {
  PokeEnergyValue editValue = PokeEnergyValue(PokeCardType.unknown, 0);

  @override
  void initState() {
    if( widget.energyValue != null) {
      editValue.energy = widget.energyValue!.energy;
      editValue.value  = widget.energyValue!.value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WidgetEnergyButton(WidgetEnergyButtonEnergyValueController(editValue, widget.defaultValue, (){ setState(() {
          widget.updateValue( editValue.energy != PokeCardType.unknown ? editValue : null);
        });})),
        if( editValue.energy != PokeCardType.unknown )
          Expanded(
            child: WidgetSliderInfo(
              WidgetSliderInfoController(() {
                return editValue.value.toDouble();
              },
              (double value) {
                editValue.value = value.round().toInt();
                widget.updateValue( editValue.energy != PokeCardType.unknown ? editValue : null);
              }),
              widget.minValue, widget.maxValue,
              division: widget.division),
          ),
      ]
    );
  }
}
