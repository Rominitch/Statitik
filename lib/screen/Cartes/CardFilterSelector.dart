import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/ButtonCheck.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardFilterSelector extends StatefulWidget {
  final CardResults result;
  final Language    language;

  CardFilterSelector(this.language, this.result);

  @override
  _CardFilterSelectorState createState() => _CardFilterSelectorState();
}

class _CardFilterSelectorState extends State<CardFilterSelector> {
  late CustomRadioController regionController  = CustomRadioController(onChange: (Region? value) { onRegionChanged(value); });

  List<Widget> widgetMarkers    = [];
  List<Widget> longMarkerWidget = [];
  List<Widget> regionsWidget    = [];
  List<Widget> typesWidget      = [];
  List<Widget> raritiesWidget   = [];

  void onRegionChanged(Region? value) {
    widget.result.filterRegion = value;
  }

  @override
  void initState() {
    super.initState();

    // Build static card marker
    CardMarker.values.forEach((element) {
      if (element != CardMarker.Nothing && !longMarker.contains(element))
        widgetMarkers.add(MarkerButtonCheck(widget.result.filter, element));
    });
    longMarker.forEach((element) {
      longMarkerWidget.add(Expanded(child: MarkerButtonCheck(widget.result.filter, element)));
    });

    orderedType.forEach((type) {
      typesWidget.add(TypeButtonCheck(widget.result.types, type));
    });

    var rarities = widget.language.isWorld() ? worldRarity : japanRarity;
    rarities.forEach((rarity) {
      raritiesWidget.add(RarityButtonCheck(widget.result.rarities, rarity));
    });

    // Set default value
    regionController.currentValue = widget.result.filterRegion;
  }

  @override
  Widget build(BuildContext context) {
    if( regionsWidget.isEmpty ) {
      regionsWidget = createRegionsWidget(context, regionController, widget.language);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read('CA_T2'), style: Theme.of(context).textTheme.headline3, ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Column(
                children: [
                  Text( StatitikLocale.of(context).read('CA_B13'), style: Theme.of(context).textTheme.headline5),
                  GridView.count(
                    crossAxisCount: 7,
                    primary: false,
                    shrinkWrap: true,
                    children: regionsWidget,
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  Text( StatitikLocale.of(context).read('CA_B12'), style: Theme.of(context).textTheme.headline5),
                  GridView.count(
                    crossAxisCount: 6,
                    primary: false,
                    shrinkWrap: true,
                    children: widgetMarkers,
                  ),
                  Row(children: longMarkerWidget.sublist(0,3)),
                  Row(children: longMarkerWidget.sublist(3)),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 6,
                    primary: false,
                    shrinkWrap: true,
                    children: typesWidget,
                  ),
                  GridView.count(
                    crossAxisCount: 6,
                    primary: false,
                    shrinkWrap: true,
                    children: raritiesWidget,
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  RangeSlider(
                    values: widget.result.life,
                    onChanged: (life){ widget.result.life = life;},
                    min: minLife.toDouble(),
                    max: maxLife.toDouble(),
                  )
                ]
              )
            ),
          ],
        )
      )
    );
  }
}
