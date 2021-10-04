import 'package:flutter/material.dart';

import 'package:statitikcard/services/models.dart';

abstract class ButtonCheck<ValueType> extends StatefulWidget {
  final ValueType  value;
  final dynamic    editableList;

  const ButtonCheck(this.editableList, this.value);

  Widget makeWidget(BuildContext context);

  @override
  _ButtonCheckState createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(2.0),
      color: widget.editableList.contains(widget.value) ? Colors.green : Colors.grey[800],
      child: TextButton(
        child: widget.makeWidget(context),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(2.0),
            minimumSize: Size(0.0, 40.0)),
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
  MarkerButtonCheck(cardMarkers, value) : super(cardMarkers, value);

  @override
  Widget makeWidget(BuildContext context) {
    return pokeMarker(context, value, height: 15);
  }
}

class TypeButtonCheck extends ButtonCheck<Type> {
  TypeButtonCheck(typesList, value) : super(typesList, value);

  @override
  Widget makeWidget(BuildContext context) {
    return getImageType(value);
  }
}

class RarityButtonCheck extends ButtonCheck<Rarity> {
  RarityButtonCheck(raritiesList, value) : super(raritiesList, value);

  @override
  Widget makeWidget(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: getImageRarity(value, fontSize: 8.0, generate: true));
  }
}