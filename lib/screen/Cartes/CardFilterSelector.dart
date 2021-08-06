import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardFilterSelector extends StatefulWidget {
  final CardResults result;

  CardFilterSelector(this.result);

  @override
  _CardFilterSelectorState createState() => _CardFilterSelectorState();
}

class _CardFilterSelectorState extends State<CardFilterSelector> {
  late CustomRadioController regionController  = CustomRadioController(onChange: (PokeRegion value) { onRegionChanged(value); });

  List<Widget> widgetMarkers    = [];
  List<Widget> longMarkerWidget = [];
  List<Widget> region           = [];
  void onRegionChanged(PokeRegion value) {
    widget.result.filterRegion = value;
  }

  @override
  void initState() {
    CardMarker.values.forEach((element) {
      if (element != CardMarker.Nothing && !longMarker.contains(element))
        widgetMarkers.add(ButtonCheck(widget.result.filter, element));
    });
    longMarker.forEach((element) {
      longMarkerWidget.add(ButtonCheck(widget.result.filter, element));
    });

    regionController.currentValue = widget.result.filterRegion;

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if( region.isEmpty ) {
      PokeRegion.values.forEach((element) {
        region.add(CustomRadio(value: element, controller: regionController,
            widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Center(child: Text(
                    regionName(context, element),
                    style: TextStyle(fontSize: 9),)))
                ])
        )
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
        child: Text( StatitikLocale.of(context).read('CA_T2'), style: Theme.of(context).textTheme.headline3, ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 7,
              primary: false,
              shrinkWrap: true,
              children: region,
            ),
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: widgetMarkers,
            ),
            Row(children: longMarkerWidget),
          ],
        )
      )
    );
  }
}
