import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/services/environment.dart';

class WidgetExpansionButton extends StatefulWidget {
  final void Function()     press;
  final PokeExpansion       expansion;
  final ExpansionSelection  selection;

  const WidgetExpansionButton({required this.expansion, required this.selection, required this.press, super.key});

  @override
  State<WidgetExpansionButton> createState() => _WidgetExpansionButtonState();
}

class _WidgetExpansionButtonState extends State<WidgetExpansionButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.selection.expansion == widget.expansion
        ? Colors.green
        : Colors.grey[850],
      child: SizedBox(
        height: 40.0,
        child: TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0),
            minimumSize: const Size(30.0, 40.0)),
          onPressed: () {
            widget.press();
          },
          child: Environment.instance.showExtensionName
            ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [widget.expansion.image(widget.selection.language!, hSize: Environment.iconSize),
              Text(widget.expansion.label(widget.selection.language!)!, textAlign: TextAlign.center,)
            ]
          )
            : widget.expansion.image(widget.selection.language!),
        ),
      ),
    );
  }
}