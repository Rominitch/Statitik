import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/ButtonCheck.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/screen/widgets/SliderWithText.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class CardFilterSelector extends StatefulWidget {
  final CardResults result;
  final Language    language;

  CardFilterSelector(this.language, this.result);

  @override
  _CardFilterSelectorState createState() => _CardFilterSelectorState();
}

class _CardFilterSelectorState extends State<CardFilterSelector> {
  static const double typeSize = 40.0;
  static const double labelWidth = 100.0;

  late CustomButtonCheckController refreshController = CustomButtonCheckController(refresh);
  late CustomButtonCheckController descriptionController = CustomButtonCheckController(refresh);
  late CustomRadioController regionController        = CustomRadioController(onChange: (Region? value) { onRegionChanged(value); });
  late CustomRadioController weaknessController      = CustomRadioController(onChange: (value) { onWeaknessChanged(value); });
  late CustomRadioController resistanceController    = CustomRadioController(onChange: (value) { onResistanceChanged(value); });
  late CustomRadioController energyAttackController  = CustomRadioController(onChange: (value) { onEnergyAttackChanged(value); });


  List<Widget> widgetMarkers    = [];
  List<Widget> longMarkerWidget = [];
  List<Widget> regionsWidget    = [];
  List<Widget> typesWidget      = [];
  List<Widget> raritiesWidget   = [];

  List<Widget> weaknessTypeWidget     = [];
  List<Widget> resistanceTypeWidget   = [];
  List<Widget> attackTypeEnergyWidget = [];
  List<Widget> effectsAttackWidget    = [];

  void onRegionChanged(Region? value) {
    setState(() {
      widget.result.filterRegion = value;
    });
  }

  void onWeaknessChanged(value) {
    setState(() {
      widget.result.weaknessType = value;
    });
  }

  void onResistanceChanged(value) {
    setState(() {
      widget.result.resistanceType = value;
    });
  }

  void onEnergyAttackChanged(value) {
    setState(() {
      widget.result.attackType = value;
    });
  }

  void refresh() {
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();

    // Build static card marker
    Environment.instance.collection.markers.values.forEach((element) {
      if (!Environment.instance.collection.longMarkers.contains(element))
        widgetMarkers.add(MarkerButtonCheck(widget.language, widget.result.filter, element, controller: refreshController));
    });
    Environment.instance.collection.longMarkers.forEach((element) {
      longMarkerWidget.add(Expanded(child: MarkerButtonCheck(widget.language, widget.result.filter, element, controller: refreshController)));
    });

    orderedType.forEach((type) {
      if( type != TypeCard.Unknown )
        typesWidget.add(TypeButtonCheck(widget.result.types, type, controller: refreshController));
    });

    var rarities = widget.language.isWorld() ? Environment.instance.collection.worldRarity : Environment.instance.collection.japanRarity;
    rarities.forEach((rarity) {
      raritiesWidget.add(RarityButtonCheck(widget.language, widget.result.rarities, rarity, controller: refreshController));
    });

    energies.forEach((element) {
      weaknessTypeWidget.add(CustomRadio(value: element, controller: weaknessController, widget: getImageType(element), widthBox: typeSize,));
      resistanceTypeWidget.add(CustomRadio(value: element, controller: resistanceController, widget: getImageType(element), widthBox: typeSize));
      attackTypeEnergyWidget.add(CustomRadio(value: element, controller: energyAttackController, widget: getImageType(element), widthBox: typeSize));
    });

    DescriptionEffect.values.forEach((effect) {
      if( effect != DescriptionEffect.Unknown)
        effectsAttackWidget.add(DescriptionEffectButtonCheck(widget.result.effects, effect, controller: descriptionController));
    });

    // Set default value
    regionController.currentValue       = widget.result.filterRegion;
    weaknessController.currentValue     = widget.result.weaknessType;
    resistanceController.currentValue   = widget.result.resistanceType;
    energyAttackController.currentValue = widget.result.attackType;
  }

  Widget createHeader(BuildContext context, String title, clearMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Row(
        children: [
          Expanded(child: Text( StatitikLocale.of(context).read(title), style: Theme.of(context).textTheme.headline5)),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: () {
              setState(() { clearMethod(); });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color selectFilter = Colors.green[900]!;
    Color normalFilter = Colors.grey[700]!;

    if( regionsWidget.isEmpty ) {
      regionsWidget = createRegionsWidget(context, regionController, widget.language);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read('CA_T2'), style: Theme.of(context).textTheme.headline3 ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpansionPanelList.radio(
              expandedHeaderPadding: EdgeInsets.zero,
              children: [
                // Panel Region
                ExpansionPanelRadio(
                  backgroundColor: widget.result.hasRegionFilter() ? selectFilter : normalFilter,
                  value: 0,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return createHeader(context, 'CA_B13', () {
                      widget.result.clearRegionFilter();
                      regionController.afterPress(widget.result.filterRegion);
                     });
                  },
                  body: GridView.count(
                    crossAxisCount: 7,
                    primary: false,
                    shrinkWrap: true,
                    children: regionsWidget,
                  ),
                ),
                // Panel Marker
                ExpansionPanelRadio(
                  backgroundColor: widget.result.hasMarkersFilter() ? selectFilter : normalFilter,
                  value: 1,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return createHeader(context, 'CA_B16', () {
                      widget.result.clearMarkersFilter();
                      refreshController.refresh();
                    });
                  },
                  body: Column(
                    children: [
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
                ExpansionPanelRadio(
                  backgroundColor: widget.result.hasTypeRarityFilter() ? selectFilter : normalFilter,
                  value: 2,
                  canTapOnHeader: true,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return createHeader(context, 'CA_B15', () {
                      setState(() {
                        widget.result.clearTypeRarityFilter();
                        refreshController.refresh();
                      });
                    });
                  },
                  body: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 9,
                        primary: false,
                        shrinkWrap: true,
                        children: typesWidget,
                      ),
                      GridView.count(
                        crossAxisCount: 9,
                        primary: false,
                        shrinkWrap: true,
                        children: raritiesWidget,
                      ),
                    ],
                  ),
                ),
                ExpansionPanelRadio(
                  backgroundColor: widget.result.hasGeneralityFilter() ? selectFilter : normalFilter,
                  value: 3,
                  canTapOnHeader: true,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return createHeader(context, 'CA_B35', () {
                      widget.result.clearGeneralityFilter();
                      resistanceController.afterPress(widget.result.resistanceType);
                      weaknessController.afterPress(widget.result.weaknessType);
                    });
                  },
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B0'), style: Theme.of(context).textTheme.headline6)),
                            Expanded(
                              child: RangeSlider(
                                values: widget.result.life,
                                onChanged: (life) {
                                  setState(() {
                                    widget.result.life = life;
                                  });
                                },
                                min: minLife.toDouble(),
                                max: maxLife.toDouble(),
                                divisions: (maxLife.toDouble()/10).round(),
                                labels: RangeLabels(
                                  widget.result.life.start.round().toString(),
                                  widget.result.life.end.round().toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B3'), style: Theme.of(context).textTheme.headline6)),
                            Expanded(child: Container(height: typeSize, child: ListView(children: weaknessTypeWidget, scrollDirection: Axis.horizontal, primary: false)))
                          ],
                        ),

                        Row(
                          children: [
                            Container(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B2'), style: Theme.of(context).textTheme.headline6)),
                            Expanded(child: Container(height: typeSize, child: ListView(children: resistanceTypeWidget, scrollDirection: Axis.horizontal, primary: false)))
                          ],
                        )
                      ]
                    ),
                  )
                ),
                 ExpansionPanelRadio(
                    backgroundColor: widget.result.hasAttackFilter() ? selectFilter : normalFilter,
                    value: 4,
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return createHeader(context, 'CA_B36', () {
                        setState(() {
                          widget.result.clearAttackFilter();
                          energyAttackController.afterPress(widget.result.attackType);
                          descriptionController.refresh();
                        });
                      });
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B7'), style: Theme.of(context).textTheme.headline6)),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      rangeThumbShape: RangeSliderWithTextThumb(
                                        thumbRadius: 15.0,
                                        sliderMinValue: widget.result.attackEnergy.start,
                                        sliderMaxValue: widget.result.attackEnergy.end,
                                      ),
                                    ),
                                    child: RangeSlider(
                                      values: widget.result.attackEnergy,
                                      onChanged: (power) {
                                        setState(() {
                                          widget.result.attackEnergy = power;
                                        });
                                      },
                                      min: minAttackEnergy.toDouble(),
                                      max: maxAttackEnergy.toDouble(),
                                      divisions: (maxAttackEnergy.toDouble()).round(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B8'), style: Theme.of(context).textTheme.headline6)),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      rangeThumbShape: RangeSliderWithTextThumb(
                                        thumbRadius: 15.0,
                                        sliderMinValue: widget.result.attackPower.start,
                                        sliderMaxValue: widget.result.attackPower.end,
                                      ),
                                    ),
                                    child: RangeSlider(
                                      values: widget.result.attackPower,
                                      onChanged: (power) {
                                        setState(() {
                                          widget.result.attackPower = power;
                                        });
                                      },
                                      min: minAttackPower.toDouble(),
                                      max: maxAttackPower.toDouble(),
                                      divisions: (maxAttackPower.toDouble()/10).round(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(StatitikLocale.of(context).read('CAVIEW_B9'), style: Theme.of(context).textTheme.headline6),
                            Container(height: typeSize, child: ListView(children: effectsAttackWidget, scrollDirection: Axis.horizontal, primary: false)),
                            Text(StatitikLocale.of(context).read('CAVIEW_B10'), style: Theme.of(context).textTheme.headline6),
                            Container(height: typeSize, child: ListView(children: attackTypeEnergyWidget, scrollDirection: Axis.horizontal, primary: false)),
                          ]
                      ),
                    )
                ),
              ]
            ),
          ],
        )
      )
    );
  }
}
