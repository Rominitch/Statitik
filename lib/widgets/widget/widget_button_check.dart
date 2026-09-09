import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/poke_set.dart';

import 'package:statitikcard/services/models/card_set.dart';
import 'package:statitikcard/services/models/card_design.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/marker.dart';
import 'package:statitikcard/services/models/serie_type.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/models/type_card.dart';

class WidgetCustomButtonCheckController {
  final List<WidgetButtonCheck> _radios = [];
  final Function    afterPress;

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
  final WidgetCustomButtonCheckController? _controller;
  final ValueType  value;
  final dynamic    editableList;

  final StreamController<dynamic> afterChange = StreamController<dynamic>();

  WidgetButtonCheck(this.editableList, this.value, this._controller, {super.key});

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

/*
class WidgetMarkerButtonCheck extends WidgetButtonCheck<CardMarker> {
  final PokeLanguage l;
  WidgetMarkerButtonCheck(this.l, cardMarkers, value, WidgetCustomButtonCheckController? controller, {Key? key}) : super(cardMarkers, value, controller, key: key);

  @override
  Widget makeWidget(BuildContext context) {
    return pokeMarker(l, value, height: 15);
  }
}
*/

class WidgetTypeButtonCheck extends WidgetButtonCheck<TypeCard> {
  WidgetTypeButtonCheck(super.typesList, super.value, super.controller, {super.key});

  @override
  Widget makeWidget(BuildContext context) {
    return getImageType(value);
  }
}

class WidgetRarityButtonCheck extends WidgetButtonCheck<PokeRarity> {
  final PokeRendering rendering;
  WidgetRarityButtonCheck(this.rendering, raritiesList, value, WidgetCustomButtonCheckController? controller, {Key? key}) : super(raritiesList, value, controller, key: key);

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
  WidgetCardSetButtonCheck(seList, value, {controller, Key? key}) : super(seList, value, controller, key: key);

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