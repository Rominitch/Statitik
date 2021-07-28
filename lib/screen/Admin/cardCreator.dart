import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardData {
  Type     type   = Type.Plante;
  Rarity   rarity = Rarity.Commune;
  CardInfo info   = CardInfo(PokeRegion.Nothing, PokeSpecial.Nothing, []);
}

class CardCreator extends StatefulWidget {
  final CardData       data;
  final int?           positionId;
  final Function(int?) onAddCard;
  final List           listRarity;

  CardCreator(this.data,  this.onAddCard, bool isWorldCard, [this.positionId]) : listRarity = (isWorldCard ? worldRarity : japanRarity);

  @override
  _CardCreatorState createState() => _CardCreatorState();
}

class _CardCreatorState extends State<CardCreator> {
  late CustomRadioController energyController = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController = CustomRadioController(onChange: (value) { onRarityChanged(value); });
  late CustomRadioController regionController = CustomRadioController(onChange: (value) { onRegionChanged(value); });

  List<Widget> typeCard = [];
  List<Widget> rarity   = [];
  List<Widget> region   = [];
  List<Widget> marker   = [];
  bool         _auto    = false;

  void onTypeChanged(value) {
    widget.data.type = value;
  }

  void onRarityChanged(value) {
    widget.data.rarity = value;
    if(_auto)
      widget.onAddCard(widget.positionId);
  }

  void onRegionChanged(value) {
    widget.data.info.region = value;
  }

  @override
  void initState() {
    super.initState();

    Type.values.forEach((element) {
      if( element != Type.Unknown)
        typeCard.add(CustomRadio(value: element, controller: energyController, widget: getImageType(element)));
    });

    widget.listRarity.forEach((element) {
    if( element != Rarity.Unknown)
      rarity.add(CustomRadio(value: element, controller: rarityController,
        widget: Row(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: getImageRarity(element))
        )
      );
    });

    regionNames.forEach((element) {
        region.add(CustomRadio(value: element, controller: regionController,
          widget: Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(element)])
         )
        );
    });

    CardMarker.values.forEach((element) {
      marker.add(CustomRadio(value: element, controller: regionController,
          widget: Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [pokeMarker(element, height: 15)])
      )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 8,
            primary: false,
            shrinkWrap: true,
            children: typeCard,
          ),
          GridView.count(
            crossAxisCount: 6,
            primary: false,
            shrinkWrap: true,
            children: rarity,
          ),
          if(widget.positionId != null)
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: region,
            ),
          if(widget.positionId != null)
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: marker,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Card(
              color: Colors.grey[800],
              child: TextButton(
              child: Text(StatitikLocale.of(context).read('NCE_B0')),
                onPressed: (){
                  widget.onAddCard(null);
                },
              )
            ),
            Card(
              color: _auto ? Colors.green : Colors.grey[800],
              child: TextButton(
                child: Text(StatitikLocale.of(context).read('NCE_B2')),
                onPressed: () {
                  setState((){
                    _auto = !_auto;
                  });
                }
              )
            )
          ])
      ]),
    );
  }
}