import 'dart:async';

import 'package:flutter/material.dart';

import 'package:statitikcard/services/CardSet.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/CardDesign.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/Rarity.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

class CustomButtonCheckController {
  final List<ButtonCheck> _radios = [];
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

  ButtonCheck(this.editableList, this.value, this._controller, {Key? key}) : super(key: key);

  Widget makeWidget(BuildContext context);

  void refresh()
  {
    afterChange.add(true);
  }

  @override
  State<ButtonCheck> createState() => _ButtonCheckState();
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
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(2.0),
            minimumSize: const Size(0.0, 40.0)),
        onPressed: (){
          setState(() {
            if( widget.editableList.contains(widget.value) ) {
              widget.editableList.remove(widget.value);
            } else {
              widget.editableList.add(widget.value);
            }
            if( widget._controller != null ) {
              widget._controller!.afterPress();
            }
          });
        },
        child: widget.makeWidget(context),
      ),
    );
  }
}

class MarkerButtonCheck extends ButtonCheck<CardMarker> {
  final Language l;
  MarkerButtonCheck(this.l, cardMarkers, value, {CustomButtonCheckController? controller, Key? key}) : super(key: key, cardMarkers, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return pokeMarker(l, value, height: 15);
  }
}

class TypeButtonCheck extends ButtonCheck<TypeCard> {
  TypeButtonCheck(typesList, value, {CustomButtonCheckController? controller, Key? key}) : super(key: key, typesList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return getImageType(value);
  }
}

class RarityButtonCheck extends ButtonCheck<Rarity> {
  final Language l;
  RarityButtonCheck(this.l, raritiesList, value, {CustomButtonCheckController? controller, Key? key}) : super(key: key, raritiesList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: getImageRarity(value, l, fontSize: 8.0, generate: true));
  }
}

class DescriptionEffectButtonCheck extends ButtonCheck<DescriptionEffect> {
  DescriptionEffectButtonCheck(effectList, value, {controller, Key? key}) : super(key: key, effectList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Tooltip(message: labelDescriptionEffect(context, value),
        child: getDescriptionEffectWidget(value)
    );
  }
}

class SerieTypeButtonCheck extends ButtonCheck<SerieType> {
  SerieTypeButtonCheck(seList, value, {controller, Key? key}) : super(seList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return Text(StatitikLocale.of(context).read(seTypeString[value.index]));
  }
}

class CardSetButtonCheck extends ButtonCheck<CardSet> {
  final Language l;
  CardSetButtonCheck(this.l, seList, value, {controller, Key? key}) : super(seList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return Text(value.names.name(l));
  }
}

class DesignButtonCheck extends ButtonCheck<CardDesign> {
  final Language l;
  final double iconSize;
  DesignButtonCheck(this.l, designsList, value, {controller, this.iconSize=30.0, Key? key}) : super(designsList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return value.icon(height: iconSize);
  }
}

class ArtButtonCheck extends ButtonCheck<ArtFormat> {
  final Language l;
  final double iconSize;
  ArtButtonCheck(this.l, artsList, value, {controller, this.iconSize=30.0, Key? key}) : super(artsList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return iconArt(value, iconSize, iconSize);
  }
}