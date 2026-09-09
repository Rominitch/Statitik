import 'package:flutter/material.dart';
import 'package:statitikcard/models/card/selector/poke_card_selector.dart';
import 'package:statitikcard/models/poke_set.dart';

class WidgetIconCard extends StatefulWidget {
  final PokeCardSelector cardSelector;
  final PokeSet       set;

  final Function?     refresh;
  final bool          readOnly;

  const WidgetIconCard(this.cardSelector, this.set, {super.key, required this.refresh, required this.readOnly});

  @override
  State<WidgetIconCard> createState() => _WidgetIconCardState();
}

class _WidgetIconCardState extends State<WidgetIconCard> {
  final Color? background = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    int count = widget.cardSelector.codeDraw().getCountFrom(widget.set);
    return Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              color: count > 0 ? widget.set.color() : background,
              child: TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                onPressed: widget.readOnly ? null : () {
                  widget.cardSelector.setOnly(widget.set);

                  Navigator.of(context).pop();
                  if(widget.refresh!=null) {
                    widget.refresh!();
                  }
                },
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [widget.set.imageWidget(width: 75.0),
                      const SizedBox(height: 6.0),
                      Text(widget.set.name(widget.cardSelector.language())),
                    ]
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                ElevatedButton(
                    onPressed: widget.readOnly ? null : () {
                      setState(() {
                        widget.cardSelector.increase(widget.set);
                      });
                      if(widget.refresh!=null) {
                        widget.refresh!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: background, // background
                    ),
                    child: const Text('+', style: TextStyle(fontSize: 20))
                ),
                Text('$count', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),),
                ElevatedButton(
                    onPressed: widget.readOnly ? null : () {
                      setState(() {
                        widget.cardSelector.decrease(widget.set);
                      });
                      if(widget.refresh!=null) {
                        widget.refresh!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: background, // background
                    ),
                    child: const Text('-', style: TextStyle(fontSize: 20))
                ),
              ],
            )
          ],
        )
    );
  }
}