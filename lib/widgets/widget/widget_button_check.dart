import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statitikcard/models/card/poke_card_design.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_marker.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/services/models/card_design.dart';
import 'package:statitikcard/services/models/serie_type.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/type_card.dart';

class WidgetCustomButtonCheckController<ValueType> {
  final List<WidgetButtonCheck> _radios = [];
  final void Function()    afterPress;

  WidgetCustomButtonCheckController(this.afterPress);

  void register(WidgetButtonCheck cr) {
    _radios.add(cr);
  }

  void unregister(WidgetButtonCheck cr) {
    _radios.remove(cr);
  }

  void refresh() {
    for (var element in _radios) {
      element.refresh();
    }
  }
}

abstract class WidgetButtonCheck<ValueType> extends StatefulWidget {
  final WidgetCustomButtonCheckController<ValueType>? _controller;
  final ValueType  value;
  final dynamic    editableList;
  final dynamic    defaultValue; // Use for Map

  final StreamController<dynamic> afterChange = StreamController<dynamic>();

  WidgetButtonCheck(this.editableList, this.value, this._controller, {this.defaultValue, super.key});

  Widget makeWidget(BuildContext context);

  void refresh()
  {
    afterChange.add(true);
  }

  @override
  State<WidgetButtonCheck> createState() => _WidgetButtonCheckState();
}

class _WidgetButtonCheckState extends State<WidgetButtonCheck> {
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

  bool contains()
  {
    if( widget.editableList is List ) {
      return widget.editableList.contains(widget.value);
    } else if( widget.editableList is Map ) {
      return widget.editableList.containsKey(widget.value);
    }
    else {
      throw "Unknown container";
    }
  }

  void changeContainer()
  {
    if( widget.editableList is List ) {
      if( widget.editableList.contains(widget.value) ) {
        widget.editableList.remove(widget.value);
      } else {
        widget.editableList.add(widget.value);
      }
    } else if( widget.editableList is Map ) {
      if( widget.editableList.containsKey(widget.value) ) {
        widget.editableList.remove(widget.value);
      } else {
        widget.editableList[widget.value] = widget.defaultValue;
      }
    }
    else {
      throw "Unknown container";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(2.0),
      color: contains() ? Colors.green : Colors.grey[800],
      child: TextButton(
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(2.0),
            minimumSize: const Size(0.0, 40.0)),
        onPressed: (){
          setState(() {
            changeContainer();
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

class WidgetMarkerButtonCheck extends WidgetButtonCheck<PokeMarker> {
  final PokeLanguage l;
  final double? height;
  WidgetMarkerButtonCheck(this.l, cardMarkers, value, WidgetCustomButtonCheckController<PokeMarker>? controller, {this.height, super.key}) :
    super(cardMarkers, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(8.0),
      child: value.pokeMarker(l, height: height)!
    );
  }
}

class WidgetTypeButtonCheck extends WidgetButtonCheck<TypeCard> {
  WidgetTypeButtonCheck(super.typesList, super.value, super.controller, {super.key});

  @override
  Widget makeWidget(BuildContext context) {
    return getImageType(value);
  }
}

class WidgetRarityButtonCheck extends WidgetButtonCheck<PokeRarity> {
  final PokeRendering rendering;
  WidgetRarityButtonCheck(this.rendering, raritiesList, value, WidgetCustomButtonCheckController<PokeRarity>? controller, {super.key}) :
    super(raritiesList, value, controller);

  @override
  Widget makeWidget(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: rendering.imageRarity(value, fontSize: 8.0, generate: true));
  }
}

class DescriptionEffectButtonCheck extends WidgetButtonCheck<DescriptionEffect> {
  DescriptionEffectButtonCheck(super.effectList, super.value, super.controller, {super.key});

  @override
  Widget makeWidget(BuildContext context) {
    return Tooltip(message: labelDescriptionEffect(context, value),
        child: getDescriptionEffectWidget(value)
    );
  }
}

class WidgetSerieTypeButtonCheck extends WidgetButtonCheck<SerieType> {
  WidgetSerieTypeButtonCheck(seList, value, {controller, Key? key}) : super(seList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return Text(serieType(context, value));
  }
}

class WidgetExpansionTypeButtonCheck extends WidgetButtonCheck<ExpansionType> {
  WidgetExpansionTypeButtonCheck(seList, value, {controller, Key? key}) : super(seList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return Text(expansionType(context, value));
  }
}

class WidgetCardSetButtonCheck extends WidgetButtonCheck<PokeSet> {
  WidgetCardSetButtonCheck(seList, value, {controller, required List<PokeCardDesign> defaultValue, super.key}) :
    super(seList, value, controller, defaultValue: defaultValue);

  @override
  Widget makeWidget(BuildContext context) {
    return value.imageWidget();
  }
}

class WidgetDesignButtonCheck extends WidgetButtonCheck<CardDesign> {
  final double iconSize;
  WidgetDesignButtonCheck(designsList, value, {controller, this.iconSize=30.0, Key? key}) : super(designsList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return value.icon(height: iconSize);
  }
}

class WidgetArtButtonCheck extends WidgetButtonCheck<ArtFormat> {
  final double iconSize;
  WidgetArtButtonCheck(artsList, value, {controller, this.iconSize=30.0, Key? key}) : super(artsList, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return iconArt(value, iconSize, iconSize);
  }
}

class WidgetLanguageCheck extends WidgetButtonCheck<PokeLanguage> {
  WidgetLanguageCheck(list, value, {controller, Key? key}) : super(list, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return value.barIcon();
  }
}