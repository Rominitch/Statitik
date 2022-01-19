import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Admin/cardEffectPanel.dart';
import 'package:statitikcard/screen/Admin/searchExtensionCardId.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/ButtonCheck.dart';
import 'package:statitikcard/screen/widgets/CardImage.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/screen/widgets/EnergySlider.dart';
import 'package:statitikcard/screen/widgets/ListSelector.dart';
import 'package:statitikcard/screen/widgets/SliderWithText.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardCreator extends StatefulWidget {
  final Language              activeLanguage;
  final bool                  editor;
  final SubExtension          se;
  final PokemonCardExtension  card;
  final int                   idCard;
  final Function(int?)?       onAppendCard;
  final List                  listRarity;
  final String                title;

  CardCreator.editor(this.activeLanguage, this.se, this.card, this.idCard, this.title, bool isWorldCard): editor=true, onAppendCard=null, listRarity = (isWorldCard ? worldRarity : japanRarity);
  CardCreator.quick(this.activeLanguage,  this.se, this.card, this.idCard, this.onAppendCard, bool isWorldCard): editor=false, listRarity = (isWorldCard ? worldRarity : japanRarity), title="";

  @override
  _CardCreatorState createState() => _CardCreatorState();
}

class _CardCreatorState extends State<CardCreator> {
  late CustomRadioController typeController       = CustomRadioController(onChange: (value) { onTypeChanged(value); });
  late CustomRadioController rarityController     = CustomRadioController(onChange: (value) { onRarityChanged(value); });
  late CustomRadioController typeExtController    = CustomRadioController(onChange: (value) { onTypeExtChanged(value); });
  late CustomRadioController levelController      = CustomRadioController(onChange: (value) { onLevel(value); });

  late CustomRadioController listChooserController = CustomRadioController(onChange: (value) { onChangeList(value); });
  final imageController  = TextEditingController();
  final jpCodeController = TextEditingController();
  final specialIDController = TextEditingController();

  List<Widget> typeCard = [];
  List<Widget> typeExtCard = [];
  List<Widget> rarity   = [];
  List<Widget> marker   = [];
  List<Widget> level   = [];
  List<Widget> longMarkerWidget = [];
  bool         _auto    = false;

  void onChangeList(value) {

  }

  void onTypeChanged(value) {
    widget.card.data.type = value;
  }
  void onLevel(value) {
    widget.card.data.level = value;
  }
  void onTypeExtChanged(value) {
    if(value == Type.Unknown)
      widget.card.data.typeExtended = null;
    else
      widget.card.data.typeExtended = value;
  }

  void onRarityChanged(value) {
    widget.card.rarity = value;
    if(_auto)
      widget.onAppendCard!(null);
  }

  void computeJPCardID() {
    try {
      int idFind = 0;
      var ancestorCard = widget.se.seCards.cards.sublist(0, widget.idCard).reversed.firstWhere((element) {
        idFind+=1;
        return (element[0].jpDBId != 0);
      });
      // Zero propagation or next number
      if(ancestorCard[0].jpDBId != 0)
        widget.card.jpDBId = ancestorCard[0].jpDBId + idFind;
    } catch(e) {
      // Nothing found !
    }
  }

  @override
  void initState() {
    super.initState();

    // Auto fill (only for japanese card)
    if(widget.activeLanguage.isJapanese() && widget.card.jpDBId == 0) {
      computeJPCardID();
    }

    Type.values.forEach((element) {
        typeCard.add(CustomRadio(value: element, controller: typeController, widget: getImageType(element)));
    });

    widget.listRarity.forEach((element) {
      if( element != Rarity.Unknown )
        rarity.add(CustomRadio(value: element, controller: rarityController,
            widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getImageRarity(element, fontSize: 8.0, generate: true))
        )
        );
    });

    if( widget.editor ) {
      typeExtCard.add(CustomRadio(value: Type.Unknown, controller: typeExtController, widget: getImageType(Type.Unknown)));
      energies.forEach((element) {
        typeExtCard.add(CustomRadio(value: element, controller: typeExtController, widget: getImageType(element)));
      });
    }

    if( widget.card.data.weakness == null ) {
      widget.card.data.weakness = EnergyValue(Type.Unknown, 0);
    }
    if( widget.card.data.resistance == null ) {
      widget.card.data.resistance = EnergyValue(Type.Unknown, 0);
    }

    listChooserController.currentValue = 0;

    selectCard();
  }

  void selectCard() {
    marker = [];
    longMarkerWidget = [];

    if( widget.editor ) {
      CardMarker.values.forEach((element) {
        if (element != CardMarker.Nothing && !longMarker.contains(element))
          marker.add(MarkerButtonCheck(widget.card.data.markers, element));
      });
      longMarker.forEach((element) {
        longMarkerWidget.add(Expanded(child: MarkerButtonCheck(widget.card.data.markers, element)));
      });

      typeExtController.afterPress(widget.card.data.typeExtended != null ? widget.card.data.typeExtended! : Type.Unknown);
    }

    // Set current value
    typeController.afterPress(widget.card.data.type);
    rarityController.afterPress(widget.card.rarity);
    imageController.text     = widget.card.image;
    jpCodeController.text    = widget.card.jpDBId.toString();
    specialIDController.text = widget.card.specialID;
  }

  Widget createImageFieldWidget() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(StatitikLocale.of(context).read('CA_B34'), style: TextStyle(fontSize: 12)),
          TextField(
              controller: imageController,
              decoration: InputDecoration(
                  hintText: CardImage.computeJPPokemonName(widget.se, widget.card)
              ),
              onChanged: (data) {
                  widget.card.image = data;
              }
          ),
          if(widget.activeLanguage.isJapanese()) TextField(
              keyboardType: TextInputType.number,
              controller: jpCodeController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.upgrade),
                    onPressed: () {
                      setState(() {
                        computeJPCardID();
                      });
                    },
                  )
              ),
              onChanged: (data) {
                setState(() {
                  if(data.isNotEmpty)
                    widget.card.jpDBId = int.parse(data);
                  else
                    widget.card.jpDBId = 0;
                });
              }),
          Column(
            children: [
              Text(StatitikLocale.of(context).read('CA_B38')),
              TextField(
                  controller: specialIDController,
                  decoration: InputDecoration(hintText: StatitikLocale.of(context).read('CA_B38') ),
                  onChanged: (data) {
                    widget.card.specialID = data;
                  }
              ),
            ]
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> others = [];
    if(widget.editor) {
      int id=0;
      List<Widget> namedWidgets = [];
      widget.card.data.title.forEach((element) {
        namedWidgets.add(PokeCardNaming(widget.activeLanguage, widget.card, id));
        id+=1;
      });

      level = [];
      Level.values.forEach((element) {
        level.add(Expanded(child: CustomRadio(value: element, controller: levelController, widget: Text( getLevelText(context, element) ))));
      });
      levelController.afterPress(widget.card.data.level);

      int? databaseCardId = Environment.instance.collection.pokemonCards.containsValue(widget.card.data)
                          ? Environment.instance.collection.rPokemonCards[widget.card.data]
                          : null;

      var codeDB = databaseCardId != null
                 ? databaseCardId.toString()
                 : StatitikLocale.of(context).read('CA_B29');



      others = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
            CardImage(widget.se, widget.card, widget.idCard, height: 100),
            SizedBox(width:8),
            Expanded(child: Text(StatitikLocale.of(context).read('CA_B30')+ " " + codeDB, style: Theme.of(context).textTheme.headline5)),
            Card (
              color: Colors.grey[500],
              child: TextButton(
                child: Text(StatitikLocale.of(context).read('CA_B32')),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchExtensionsCardId(widget.card.data.type,
                      widget.card.data.title.isNotEmpty ? widget.card.data.title[0].name : null, widget.title, databaseCardId ?? 0)),
                  ).then((idCard) {
                    if(idCard != null) {
                      setState(() {
                        // Change object
                        widget.card.data = Environment.instance.collection.pokemonCards[idCard];
                        // Recompute default value
                        selectCard();
                      });
                    }
                  });
                }
              )
            )
          ]),
        ),
        ExpansionPanelList.radio(
          expandedHeaderPadding: EdgeInsets.zero,
          children: [
            ExpansionPanelRadio(
                canTapOnHeader: true,
                headerBuilder: (context, isOpen) { return ListTile(
                title: Text(StatitikLocale.of(context).read('CA_B22'), style: TextStyle(fontSize: 12))); },
                backgroundColor: Colors.blueGrey[800],
                value: 0,
                body: Column(
                  children: namedWidgets + [
                    Card(child: TextButton(
                    child: Text(StatitikLocale.of(context).read('NCE_B7')),
                    onPressed: () {
                      setState(() {
                        widget.card.data.title.add(Pokemon(Environment.instance.collection.pokemons[1]));
                      });
                    },
                  ))
                  ]
                )
            ),
            if(isPokemonType(widget.card.data.type))
              ExpansionPanelRadio(
                canTapOnHeader: true,
                headerBuilder: (context, isOpen) { return ListTile(
                    title:Text(StatitikLocale.of(context).read('CA_B18'), style: TextStyle(fontSize: 12))); },
                value: 1,
                backgroundColor: Colors.blueGrey[800],
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row( children: level),
                      Row(children: [
                        Container(width: 60, child: Text(StatitikLocale.of(context).read('CA_B25'), style: TextStyle(fontSize: 12))),
                        Expanded(
                          child: SliderInfo( SliderInfoController(() {
                              return widget.card.data.life.toDouble();
                            },
                            (double value){
                              widget.card.data.life = value.round().toInt();
                            }),
                            minLife, maxLife,
                            division: 40),
                        ),
                      ]),
                      // Retreat
                      Row(children: [
                        Container(width: 60, child: Text(StatitikLocale.of(context).read('CA_B26'), style: TextStyle(fontSize: 12))),
                        Expanded(
                          child: SliderInfo( SliderInfoController(() {
                              return widget.card.data.retreat.toDouble();
                            },
                            (double value){
                              widget.card.data.retreat = value.round().toInt();
                            }),
                            minRetreat, maxRetreat,
                            division: 5),
                        ),
                      ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(StatitikLocale.of(context).read('CA_B28'), style: TextStyle(fontSize: 12)),
                          EnergySlider(widget.card.data.weakness!, 2, minWeakness, maxWeakness, division: 5)
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(StatitikLocale.of(context).read('CA_B27'), style: TextStyle(fontSize: 12)),
                          EnergySlider(widget.card.data.resistance!, 30, minResistance, maxResistance, division: 6)
                        ],
                      )
                    ],
                  ),
                )
            ),
          ExpansionPanelRadio(
            canTapOnHeader: true,
            headerBuilder: (context, isOpen) { return ListTile(
            title:Text(StatitikLocale.of(context).read('CA_B37'), style: TextStyle(fontSize: 12))); },
            value: 2,
            backgroundColor: Colors.blueGrey[800],
            body: createImageFieldWidget()
            ),
          ExpansionPanelRadio(
            value: 3,
            canTapOnHeader: true,
            headerBuilder: (context, isOpen) { return ListTile(
                title:Text(StatitikLocale.of(context).read('CA_B16'), style: TextStyle(fontSize: 12))); },
            backgroundColor: Colors.blueGrey[800],
            body: Column( children: [
              GridView.count(
                crossAxisCount: 6,
                primary: false,
                shrinkWrap: true,
                children: marker,
                childAspectRatio: 1.2,
              ),
              Row(children: longMarkerWidget.sublist(0, 3)),
              Row(children: longMarkerWidget.sublist(3)),
            ]),
          ),
          ExpansionPanelRadio(
            value: 4,
            canTapOnHeader: true,
            headerBuilder: (context, isOpen) { return ListTile(
                title:Text(StatitikLocale.of(context).read('CA_B17'), style: TextStyle(fontSize: 12))); },
            backgroundColor: Colors.blueGrey[800],
            body: CardEffectsPanel(widget.card, widget.activeLanguage)
          ),
          ExpansionPanelRadio(
            value: 5,
            canTapOnHeader: true,
            headerBuilder: (context, isOpen) { return ListTile(
                title: Text(StatitikLocale.of(context).read('CA_B15'), style: TextStyle(fontSize: 12))); },
            backgroundColor: Colors.blueGrey[800],
            body: Column( children: [
              GridView.count(
                crossAxisCount: 7,
                primary: false,
                shrinkWrap: true,
                children: rarity,
              ),
              GridView.count(
                crossAxisCount: 8,
                primary: false,
                shrinkWrap: true,
                children: typeCard,
              ),
              GridView.count(
                crossAxisCount: 8,
                primary: false,
                shrinkWrap: true,
                children: typeExtCard,
              ),
            ])
          ),
        ])
      ];
    } else {
      others = [
        GridView.count(
          crossAxisCount: 8,
          primary: false,
          shrinkWrap: true,
          children: typeCard,
          childAspectRatio: 1.1,
        ),
        GridView.count(
          crossAxisCount: 7,
          primary: false,
          shrinkWrap: true,
          children: rarity,
          childAspectRatio: 1.3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRadio(value: 0, controller: listChooserController, widget: Text("Normal")),
            CustomRadio(value: 1, controller: listChooserController, widget: Text("Energie")),
            CustomRadio(value: 2, controller: listChooserController, widget: Text("Special")),
            Expanded(child: SizedBox(width: 1)),
            Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('NCE_B0')),
                  onPressed: (){
                    widget.onAppendCard!(null);
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
            ),
          ]
        ),
      ];
    }
    return Card( child: Column(children: others) );
  }
}

class PokeCardNaming extends StatefulWidget {
  final Language              language;
  final PokemonCardExtension  card;
  final int                   idName;
  const PokeCardNaming(this.language, this.card, this.idName);

  Pokemon nameInfo() {
    return card.data.title[idName];
  }

  @override
  _PokeCardNamingState createState() => _PokeCardNamingState();
}

class _PokeCardNamingState extends State<PokeCardNaming> {
  late CustomRadioController specialController = CustomRadioController(onChange: (Forme?  value) { onSpecialChanged(value); });
  late CustomRadioController regionController  = CustomRadioController(onChange: (Region? value) { onRegionChanged(value); });

  void onRegionChanged(Region? value) {
    widget.nameInfo().region = value;
  }

  void onSpecialChanged(Forme? value) {
    widget.nameInfo().forme = value;
  }

  Future<int?> addNewDresseurObjectName(String newText, int idLangue) async {
    printOutput("Start add new value");
    return await Environment.instance.addNewDresseurObjectName(newText, idLangue);
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.nameInfo();
    List<Widget> regionsWidget = createRegionsWidget(context, regionController, widget.language);
    List<Widget> formeWidget   = [];

    Environment.instance.collection.formes.values.forEach((element) {
      formeWidget.add(CustomRadio(value: element, controller: specialController,
          widget: Row(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: Center(child: Text(
                  element.applyToPokemonName(widget.language),
                  style: TextStyle(fontSize: 8),)))
              ])
      )
      );
    });
    regionController.afterPress(name.region);
    specialController.afterPress(name.forme);

    // Show only good list based on Type
    Widget nameWidget = isPokemonCard(widget.card.data.type) ?
      Card(
        color: Colors.grey[700],
        child: TextButton(
          child: Text((name.name.isPokemon()) ? name.name.defaultName() : "", style: TextStyle(fontSize: 9.0)),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListSelector('CE_T0', widget.language, Environment.instance.collection.pokemons, multiLangue: true)),
            ).then((idDB) {
              if(idDB != null) {
                setState(() {
                  name.name = Environment.instance.collection.pokemons[idDB];
                });
              }
            });
          },
        )
      ) : Card(
        color: Colors.grey[700],
        child: TextButton(
          child: Text((!name.name.isPokemon()) ? name.name.defaultName() : "", style: TextStyle(fontSize: 9.0)),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListSelector('CE_T0', widget.language, Environment.instance.collection.otherNames, multiLangue:true,
                  addNewData: addNewDresseurObjectName)),
            ).then((idDB) {
              if(idDB != null) {
                setState(() {
                  name.name = Environment.instance.collection.otherNames[idDB];
                });
              }
            });
          },
        )
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Row(
            children: [
              Expanded(
                child: nameWidget
              ),
              IconButton(onPressed: (){
                  setState(() {
                    widget.card.data.title.remove(widget.nameInfo());
                  });
                },
                icon: Icon(Icons.delete)
              ),
            ],
          ),
          if( isPokemonType(widget.card.data.type) )
            GridView.count(
              crossAxisCount: 7,
              primary: false,
              shrinkWrap: true,
              children: regionsWidget,
            ),
          if( isPokemonType(widget.card.data.type) )
            GridView.count(
              crossAxisCount: 6,
              primary: false,
              shrinkWrap: true,
              children: formeWidget,
            ),
      ],
    );
  }
}