import 'package:flutter/material.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/widgets/widget/widget_creator_card_image.dart';

class WidgetButtonPokeDesign extends StatefulWidget {
  final PokeNavAdmin             _navAdmin;
  final PokeCardViewerIdentifier _cardId;
  final Function                 refresh;

  const WidgetButtonPokeDesign(this._navAdmin, this._cardId, this.refresh, {super.key});

  @override
  State<WidgetButtonPokeDesign> createState() => _WidgetButtonPokeDesignState();
}

class _WidgetButtonPokeDesignState extends State<WidgetButtonPokeDesign> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
        child: widget._navAdmin.rendering.iconFullDesign( widget._cardId.cardDesign(), height: PokeRendering.designIconSize),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) =>
                WidgetCreatorCardImage(
                  widget._navAdmin, widget._cardId
                )
            ),
          ).then((value) {
            setState(() {
              widget.refresh();
            });
          }
          );
        },
        onLongPress: () {
          widget._cardId.cardInExp().removeImage(widget._cardId.idImage!);
          widget.refresh();
        },
      )
    );
  }
}
