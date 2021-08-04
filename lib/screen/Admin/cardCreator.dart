import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class CardCreator extends StatefulWidget {
  final bool            editor;
  final PokeCard        card;
  final Function(int?)? onAppendCard;
  final List            listRarity;

  CardCreator.editor(this.card, bool isWorldCard): editor=true, onAppendCard=null, listRarity = (isWorldCard ? worldRarity : japanRarity);
  CardCreator.quick(this.card,  this.onAppendCard, bool isWorldCard): editor=false, listRarity = (isWorldCard ? worldRarity : japanRarity);

  @override
  _CardCreatorState createState() => _CardCreatorState();
}

class _CardCreatorState extends State<CardCreator> {
  late CustomRadioController typeController    = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController  = CustomRadioController(onChange: (value) { onRarityChanged(value); });
  late CustomRadioController regionController  = CustomRadioController(onChange: (PokeRegion value) { onRegionChanged(value); });
  late CustomRadioController specialController = CustomRadioController(onChange: (PokeSpecial value) { onSpecialChanged(value); });

  List<Widget> typeCard = [];
  List<Widget> rarity   = [];
  List<Widget> marker   = [];
  bool         _auto    = false;

  void onTypeChanged(value) {
    widget.card.type = value;
  }

  void onRarityChanged(value) {
    widget.card.rarity = value;
    if(_auto)
      widget.onAppendCard!(null);
  }

  void onRegionChanged(PokeRegion value) {
    widget.card.info.region = value;
  }

  void onSpecialChanged(PokeSpecial value) {
    widget.card.info.special = value;
  }

  @override
  void initState() {
    super.initState();

    Type.values.forEach((element) {
      if( element != Type.Unknown)
        typeCard.add(CustomRadio(value: element, controller: typeController, widget: getImageType(element)));
    });

    widget.listRarity.forEach((element) {
    if( element != Rarity.Unknown)
      rarity.add(CustomRadio(value: element, controller: rarityController,
        widget: Row(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: getImageRarity(element, fontSize: 8.0, generate: true))
        )
      );
    });

    if(widget.editor) {
      CardMarker.values.forEach((element) {
        if (element != CardMarker.Nothing)
          marker.add(ButtonCheck(widget.card.info, element));
      });
    }

    // Set current value
    typeController.afterPress(widget.card.type);
    rarityController.afterPress(widget.card.rarity);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> region   = [];
    List<Widget> special  = [];
    if(widget.editor) {
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

      PokeSpecial.values.forEach((element) {
        special.add(CustomRadio(value: element, controller: specialController,
            widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Center(child: Text(
                    specialName(context, element),
                    style: TextStyle(fontSize: 9),)))
                ])
        )
        );
      });
      regionController.afterPress(widget.card.info.region);
      specialController.afterPress(widget.card.info.special);
    }

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
            crossAxisCount: 7,
            primary: false,
            shrinkWrap: true,
            children: rarity,
          ),
          if(widget.editor)
            GridView.count(
              crossAxisCount: 7,
              primary: false,
              shrinkWrap: true,
              children: region,
            ),
          if(widget.editor)
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: special,
            ),
          if(widget.editor)
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: marker,
            ),
          if( !widget.editor ) Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Card(
              color: Colors.grey[800],
              child: TextButton(
              child: Text(StatitikLocale.of(context).read('NCE_B0')),
                onPressed: (){
                  widget.onAppendCard!(null);
                },
              )
            ),
            if( !widget.editor ) Card(
              color: _auto ? Colors.green : Colors.grey[800],
              child: TextButton(
                child: Text(StatitikLocale.of(context).read('NCE_B2')),
                onPressed: () {
                  setState((){
                    _auto = !_auto;
                  });
                }
              )
            ),
          ])
      ]),
    );
  }
}

class ButtonCheck extends StatefulWidget {
  final CardMarker mark;
  final CardInfo   card;

  const ButtonCheck(this.card, this.mark);

  @override
  _ButtonCheckState createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck> {
  @override
  Widget build(BuildContext context) {
    var cm = widget.card.markers;
    return Card(
      color: cm.contains(widget.mark) ? Colors.green : Colors.grey[800],
      child: TextButton(
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [pokeMarker(widget.mark, height: 15)]),
        onPressed: (){
          setState(() {
            if( cm.contains(widget.mark) ) {
              cm.remove(widget.mark);
            } else {
              cm.add(widget.mark);
            }
          });
        },
      ),
    );
  }
}