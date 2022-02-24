import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

import 'package:statitikcard/services/models/models.dart';

class CustomButtonCheckController {
  List<ButtonCheck> _radios = [];
  final Function    afterPress;

  CustomButtonCheckController(this.afterPress);

  void register(ButtonCheck cr) {
    _radios.add(cr);
  }

  void unregister(ButtonCheck cr) {
    _radios.remove(cr);
  }

  void refresh() {
    _radios.forEach((element) { element.refresh(); });
  }
}

abstract class ButtonCheck<ValueType> extends StatefulWidget {
  final CustomButtonCheckController? _controller;
  final ValueType  value;
  final dynamic    editableList;

  final StreamController<dynamic> afterChange = StreamController<dynamic>();

  ButtonCheck(this.editableList, this.value, this._controller);

  Widget makeWidget(BuildContext context);

  void refresh()
  {
    afterChange.add(true);
  }

  @override
  _ButtonCheckState createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck> {
  @override
  void initState() {
    widget.afterChange.stream.listen((valid) {
      setState(() {
      });
    });
    if( widget._controller != null) {
      widget._controller!.register(widget);
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.afterChange.close();
    if( widget._controller != null) {
      widget._controller!.unregister(widget);
    }
    super.dispose();
  }

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
            if( widget._controller != null )
              widget._controller!.afterPress();
          });
        },
      ),
    );
  }
}

class MarkerButtonCheck extends ButtonCheck<CardMarker> {
  final Language l;
  MarkerButtonCheck(this.l, cardMarkers, value, {controller}) : super(cardMarkers, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return pokeMarker(this.l, value, height: 15);
  }
}

class TypeButtonCheck extends ButtonCheck<TypeCard> {
  TypeButtonCheck(typesList, value, {controller}) : super(typesList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return getImageType(value);
  }
}

class RarityButtonCheck extends ButtonCheck<Rarity> {
  final Language l;
  RarityButtonCheck(this.l, raritiesList, value, {controller}) : super(raritiesList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: getImageRarity(value, l, fontSize: 8.0, generate: true));
  }
}

class DescriptionEffectButtonCheck extends ButtonCheck<DescriptionEffect> {
  DescriptionEffectButtonCheck(effectList, value, {controller}) : super(effectList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Tooltip(message: labelDescriptionEffect(context, value),
        child: getDescriptionEffectWidget(value)
    );
  }
}

class SerieTypeButtonCheck extends ButtonCheck<SerieType> {
  SerieTypeButtonCheck(seList, value, {controller}) : super(seList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Text(StatitikLocale.of(context).read(seTypeString[value.index]));
  }
}

class CardSetButtonCheck extends ButtonCheck<CardSet> {
  final Language l;
  CardSetButtonCheck(this.l, seList, value, {controller}) : super(seList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Text(value.names.name(l));
  }
}