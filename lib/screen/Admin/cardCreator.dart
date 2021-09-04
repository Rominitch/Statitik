import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Admin/cardEditor.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardCreator extends StatefulWidget {
  final Language              activeLanguage;
  final bool                  editor;
  final PokemonCardExtension  card;
  final Function(int?)?       onAppendCard;
  final List                  listRarity;

  CardCreator.editor(this.activeLanguage, this.card, bool isWorldCard): editor=true, onAppendCard=null, listRarity = (isWorldCard ? worldRarity : japanRarity);
  CardCreator.quick(this.activeLanguage,  this.card,  this.onAppendCard, bool isWorldCard): editor=false, listRarity = (isWorldCard ? worldRarity : japanRarity);

  @override
  _CardCreatorState createState() => _CardCreatorState();
}

class _CardCreatorState extends State<CardCreator> {
  late CustomRadioController typeController    = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController  = CustomRadioController(onChange: (value) { onRarityChanged(value); });

  List<Widget> typeCard = [];
  List<Widget> rarity   = [];
  List<Widget> marker   = [];
  List<Widget> longMarkerWidget = [];
  bool         _auto    = false;

  void onTypeChanged(value) {
    widget.card.data.type = value;
  }

  void onRarityChanged(value) {
    widget.card.rarity = value;
    if(_auto)
      widget.onAppendCard!(null);
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
        if (element != CardMarker.Nothing && !longMarker.contains(element))
          marker.add(ButtonCheck(widget.card.data.markers, element));
      });
      longMarker.forEach((element) {
        longMarkerWidget.add(Expanded(child: ButtonCheck(widget.card.data.markers, element)));
      });
    }

    // Set current value
    typeController.afterPress(widget.card.data.type);
    rarityController.afterPress(widget.card.rarity);
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
            crossAxisCount: 7,
            primary: false,
            shrinkWrap: true,
            children: rarity,
          ),

          if(widget.editor)
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: marker,
            ),
          if(widget.editor)
            Row(children: longMarkerWidget.sublist(0, 3)),
          if(widget.editor)
            Row(children: longMarkerWidget.sublist(3)),
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

class PokeCardNaming extends StatefulWidget {
  final PokemonCardExtension  card;
  final int                   idName;
  const PokeCardNaming(this.card, this.idName);

  Pokemon nameInfo() {
    return card.data.title[idName];
  }

  @override
  _PokeCardNamingState createState() => _PokeCardNamingState();
}

class _PokeCardNamingState extends State<PokeCardNaming> {
  late CustomRadioController specialController = CustomRadioController(onChange: (Forme value)  { onSpecialChanged(value); });
  late CustomRadioController regionController  = CustomRadioController(onChange: (Region value) { onRegionChanged(value); });

  void onRegionChanged(Region value) {
    widget.nameInfo().region = value;
  }

  void onSpecialChanged(Forme value) {
    widget.nameInfo().forme = value;
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.nameInfo();
    List<Widget> region   = [];
    List<Widget> special  = [];
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
    regionController.afterPress(name.region);
    specialController.afterPress(name.forme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Row(
            children: [
              Expanded(
                child: Card(
                    color: Colors.grey[700],
                    child: TextButton(
                      child: Text((name.name.isPokemon()) ? name.name.defaultName() : ""),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChooserCardName(Environment.instance.collection.pokemons.values.toList(), name)),
                        ).then((value) {
                          if(value != null) {
                            setState(() {
                              name.name = value;
                            });
                          }
                        });
                      },
                    )
                ),
              ),
              Expanded(
                child: Card(
                    color: Colors.grey[700],
                    child: TextButton(
                      child: Text((!name.name.isPokemon()) ? name.name.defaultName() : ""),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChooserCardName(Environment.instance.collection.otherNames.values.toList(), name)),
                        ).then((value) {
                          if(value != null) {
                            setState(() {
                              name.name = value;
                            });
                          }
                        });
                      },
                    )
                ),
              ),
            ],
          ),
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
            children: special,
          ),
      ],
    );
  }
}


class ButtonCheck extends StatefulWidget {
  final CardMarker  mark;
  final CardMarkers cardMarkers;

  const ButtonCheck(this.cardMarkers, this.mark);

  @override
  _ButtonCheckState createState() => _ButtonCheckState();
}

class _ButtonCheckState extends State<ButtonCheck> {
  @override
  Widget build(BuildContext context) {
    var cm = widget.cardMarkers.markers;
    return Card(
      color: cm.contains(widget.mark) ? Colors.green : Colors.grey[800],
      child: TextButton(
        child: pokeMarker(context, widget.mark, height: 15),
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