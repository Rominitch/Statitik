import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/screen/view.dart';
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
  List<Widget> regionsWidget           = [];
  void onRegionChanged(Region? value) {
    widget.result.filterRegion = value;
  }

  @override
  void initState() {
    super.initState();
    CardMarker.values.forEach((element) {
      if (element != CardMarker.Nothing && !longMarker.contains(element))
        widgetMarkers.add(ButtonCheck(widget.result.filter, element));
    });
    longMarker.forEach((element) {
      longMarkerWidget.add(Expanded(child: ButtonCheck(widget.result.filter, element)));
    });

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
          ],
        )
      )
    );
  }
}
