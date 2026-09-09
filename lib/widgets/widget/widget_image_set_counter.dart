import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_rendering.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {

    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}

class WidgetImageSetCounter extends StatefulWidget {
  final PokeRendering           rendering;
  final PokeCardSelector        cardSelector;
  final PokeCardImageIdentifier imageId;

  final Function?     refresh;
  final bool          readOnly;

  const WidgetImageSetCounter(this.rendering, this.cardSelector, this.imageId, {required this.refresh, required this.readOnly, super.key});

  @override
  State<WidgetImageSetCounter> createState() => _WidgetImageSetCounterState();
}

class _WidgetImageSetCounterState extends State<WidgetImageSetCounter> {
  late PokeCardImageIdentifier designId;
  late TextEditingController textController;

  @override
  void initState() {
    var card = widget.cardSelector.card();
    designId = widget.imageId;
    /*card.images[widget.imageId.idSet].isEmpty
        ? PokeCardImageIdentifier(0, 0) // Show always first valid image
        : PokeCardImageIdentifier(widget.imageId.set, widget.imageId.idImage);
     */
    var count = widget.cardSelector.codeDraw().getCountFrom(widget.imageId.set, widget.imageId.idImage);
    textController = TextEditingController(text: count.toString());
    super.initState();
  }

  int countCard() {
    return widget.cardSelector.codeDraw().getCountFrom(widget.imageId.set, widget.imageId.idImage);
  }

  @override
  Widget build(BuildContext context) {
    const splashRadius = 14.0;
    const iconPadding  = 2.0;
    const iconSize  = 20.0;
    var card  = widget.cardSelector.card();
    var count = countCard();
    final viewerId = PokeCardViewerIdentifier(widget.cardSelector.expansion(), widget.cardSelector.cardIdentifier(),
        idImage: widget.imageId, specificLanguage: widget.cardSelector.language());

    return SizedBox(
      width: 100.0,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.rendering.iconFullDesign(card.tryGetImage(designId)!, width: iconSize, height: iconSize)
                ]
            ),
            const SizedBox(height: 3.0),
            widget.rendering.genericCardWidget( viewerId, height: 110, language: widget.cardSelector.language() ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    padding: const EdgeInsets.all(iconPadding),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: (){
                      widget.cardSelector.decrease(widget.imageId.set, widget.imageId.idImage);
                      textController.text = countCard().toString();
                    },
                    splashRadius: splashRadius,
                  ),
                  Expanded(child:
                  TextField(
                    controller: textController,
                    inputFormatters: [
                      NumericalRangeFormatter(min: 0, max: 255),
                    ],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 3,
                    onSubmitted: (String value) {
                      var finalValue = max(0, min(int.parse(value.isEmpty ? "0" : value), 255));
                      widget.cardSelector.codeDraw().setCount(finalValue, widget.imageId.set, widget.imageId.idImage);
                    },
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                        color: count > 0 ? Colors.green.shade300 : Colors.white
                    ),
                    decoration: const InputDecoration(border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      counterText: "",
                    ),
                  )
                  ),
                  IconButton(icon: const Icon(Icons.add_circle_outline),
                    padding: const EdgeInsets.all(iconPadding),
                    constraints: const BoxConstraints(),
                    onPressed: (){
                      widget.cardSelector.increase(widget.imageId.set, widget.imageId.idImage);
                      textController.text = countCard().toString();
                    },
                    splashRadius: splashRadius,
                  )
                ]
            ),
          ]
      ),
    );
  }
}