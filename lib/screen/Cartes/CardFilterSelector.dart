import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardFilterSelector extends StatefulWidget {
  final CardInfo filter;

  CardFilterSelector(this.filter);

  @override
  _CardFilterSelectorState createState() => _CardFilterSelectorState();
}

class _CardFilterSelectorState extends State<CardFilterSelector> {
  late CustomRadioController regionController  = CustomRadioController(onChange: (PokeRegion value) { onRegionChanged(value); });

  List<Widget> widgetMarkers = [];
  List<Widget> region        = [];
  void onRegionChanged(PokeRegion value) {
    widget.filter.region = value;
  }

  @override
  void initState() {
    CardMarker.values.forEach((element) {
      if (element != CardMarker.Nothing)
        widgetMarkers.add(ButtonCheck(widget.filter, element));
    });

    regionController.currentValue = widget.filter.region;

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
          ],
        )
      )
    );
  }
}
