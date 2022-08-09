import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/button_check.dart';
import 'package:statitikcard/screen/widgets/custom_radio.dart';
import 'package:statitikcard/screen/widgets/slider_with_text.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/card_design.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';

class CardFilterSelector extends StatefulWidget {
  final CardResults result;
  final Language    language;

  const CardFilterSelector(this.language, this.result, {Key? key}) : super(key: key);

  @override
  State<CardFilterSelector> createState() => _CardFilterSelectorState();
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
  List<Widget> designWidget     = [];
  List<Widget> artsWidget       = [];

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
    for (var element in Environment.instance.collection.markers.values) {
      if (!Environment.instance.collection.longMarkers.contains(element)) {
        widgetMarkers.add(MarkerButtonCheck(widget.language, widget.result.filter, element, refreshController));
      }
    }
    for (var element in Environment.instance.collection.longMarkers) {
      longMarkerWidget.add(Expanded(child: MarkerButtonCheck(widget.language, widget.result.filter, element, refreshController)));
    }

    for (var type in orderedType) {
      if( type != TypeCard.unknown ) {
        typesWidget.add(TypeButtonCheck(widget.result.types, type, refreshController));
      }
    }

    var rarities = widget.language.isWorld() ? Environment.instance.collection.worldRarity : Environment.instance.collection.japanRarity;
    for (var rarity in rarities) {
      raritiesWidget.add(RarityButtonCheck(widget.language, widget.result.rarities, rarity, refreshController));
    }

    for (var element in energies) {
      weaknessTypeWidget.add(CustomRadio(value: element, controller: weaknessController, widget: getImageType(element), widthBox: typeSize,));
      resistanceTypeWidget.add(CustomRadio(value: element, controller: resistanceController, widget: getImageType(element), widthBox: typeSize));
      attackTypeEnergyWidget.add(CustomRadio(value: element, controller: energyAttackController, widget: getImageType(element), widthBox: typeSize));
    }

    for (var design in Environment.instance.collection.validDesigns) {
      designWidget.add(DesignButtonCheck(widget.language, widget.result.designs, design, controller: refreshController));
    }
    for (var art in ArtFormat.values) {
      artsWidget.add(ArtButtonCheck(widget.language, widget.result.arts, art, controller: refreshController));
    }

    for (var effect in DescriptionEffect.values) {
      if( effect != DescriptionEffect.unknown) {
        effectsAttackWidget.add(DescriptionEffectButtonCheck(widget.result.effects, effect, descriptionController));
      }
    }

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
                            SizedBox(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B0'), style: Theme.of(context).textTheme.headline6)),
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
                            SizedBox(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B3'), style: Theme.of(context).textTheme.headline6)),
                            Expanded(child: SizedBox(height: typeSize, child: ListView(scrollDirection: Axis.horizontal, primary: false, children: weaknessTypeWidget)))
                          ],
                        ),

                        Row(
                          children: [
                            SizedBox(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B2'), style: Theme.of(context).textTheme.headline6)),
                            Expanded(child: SizedBox(height: typeSize, child: ListView(scrollDirection: Axis.horizontal, primary: false, children: resistanceTypeWidget)))
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
                                SizedBox(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B7'), style: Theme.of(context).textTheme.headline6)),
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
                                SizedBox(width: labelWidth, child: Text(StatitikLocale.of(context).read('CAVIEW_B8'), style: Theme.of(context).textTheme.headline6)),
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
                            SizedBox(height: typeSize, child: ListView(scrollDirection: Axis.horizontal, primary: false, children: effectsAttackWidget)),
                            Text(StatitikLocale.of(context).read('CAVIEW_B10'), style: Theme.of(context).textTheme.headline6),
                            SizedBox(height: typeSize, child: ListView(scrollDirection: Axis.horizontal, primary: false, children: attackTypeEnergyWidget)),
                          ]
                      ),
                    )
                ),
                ExpansionPanelRadio(
                  backgroundColor: widget.result.hasDesignFilter() ? selectFilter : normalFilter,
                  value: 5,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return createHeader(context, 'TUTO_CAPTION_T0', () {
                      widget.result.clearDesignFilter();
                      refreshController.refresh();
                    });
                  },
                  body: Column(
                    children: [
                      Text(StatitikLocale.of(context).read('TUTO_CAPTION_T1'), style: Theme.of(context).textTheme.headline6),
                      GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 3.0,
                        primary: false,
                        shrinkWrap: true,
                        children: artsWidget,
                      ),
                      Text(StatitikLocale.of(context).read('TUTO_CAPTION_T2'), style: Theme.of(context).textTheme.headline6),
                      GridView.count(
                        crossAxisCount: 5,
                        primary: false,
                        shrinkWrap: true,
                        children: designWidget,
                      ),
                    ],
                  ),
                ),
              ]
            ),
          ],
        )
      )
    );
  }
}
