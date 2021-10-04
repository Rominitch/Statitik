import 'package:flutter/material.dart';

import 'package:statitikcard/services/models.dart';

class ButtonCheck<ValueType> extends StatefulWidget {
  final ValueType  value;
  final List     editableList;
  final Widget Function(BuildContext, ValueType) widgetBuilder;

  const ButtonCheck(this.editableList, this.value, this.widgetBuilder);

  @override
  _ButtonCheckState createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.editableList.contains(widget.value) ? Colors.green : Colors.grey[800],
      child: TextButton(
        child: widget.widgetBuilder(context, widget.value),
        onPressed: (){
          setState(() {
            if( widget.editableList.contains(widget.value) ) {
              widget.editableList.remove(widget.value);
            } else {
              widget.editableList.add(widget.value);
            }
          });
        },
      ),
    );
  }
}

class MarkerButtonCheck extends ButtonCheck<CardMarker> {
  MarkerButtonCheck(cardMarkers, value) : super(cardMarkers, value, (context, value) { return pokeMarker(context, value, height: 15); });
}

class TypeButtonCheck extends ButtonCheck<Type> {
  TypeButtonCheck(typesList, value) : super(typesList, value, (context, value) { return getImageType(value); });
}

class RarityButtonCheck extends ButtonCheck<Rarity> {
  RarityButtonCheck(raritiesList, value) : super(raritiesList, value, (context, value) { return Row( children: getImageRarity(value)); });
}