import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/screen/Admin/cardEditor.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class NewCardExtensions extends StatefulWidget {
  final Language     language;
  final SubExtension se;

  const NewCardExtensions(this.language, this.se, {Key? key}) : super(key: key);

  @override
  _NewCardExtensionsState createState() => _NewCardExtensionsState();
}

class _NewCardExtensionsState extends State<NewCardExtensions> {
  List<Widget>  _cardInfo         = [];
  List<Widget>  _cardEnergyInfo   = [];
  List<Widget>  _cardNoNumberInfo = [];
  bool _modify = false;
  PokemonCardExtension data = PokemonCardExtension.creation(PokemonCardData([], Level.Base, TypeCard.Plante, CardMarkers.from([])), Environment.instance.collection.unknownRarity!, Environment.instance.collection.sets);
  int idList = 0;
  bool _showQuickCreator = true;

  final List<int> secretRarities = const [21, 22, 23, 24, 25, 26, 36, 37];

  void onChangeList(int newIdList) {
   setState(() {
     idList = newIdList;
   });
  }

  void updateCardList(int listId) {
    if(listId == 1)
      _cardEnergyInfo   = _cardsEnergy();
    else if(listId == 2)
      _cardNoNumberInfo = _cardsNoNumber();
    else
      _cardInfo = _cards();
  }

  void onAddCard(int listId, int? pos) {
    setState((){
      _modify = true;

      // Remove default state
      if( !widget.se.seCards.isValid ) {
        widget.se.seCards.cards.clear();
        widget.se.seCards.isValid = true;
      }

      // Create new card
      var newItem = PokemonCardExtension.creation(PokemonCardData([], data.data.level, data.data.type, CardMarkers.from([])),
          data.rarity, Environment.instance.collection.sets);

      // Added
      if(listId == 1) {
        if( pos == null) {
          widget.se.seCards.energyCard.add(newItem);
        } else {
          widget.se.seCards.energyCard.insert(pos, newItem);
        }
      }
      else if(listId == 2) {
        if( pos == null) {
          widget.se.seCards.noNumberedCard.add(newItem);
        } else {
          widget.se.seCards.noNumberedCard.insert(pos, newItem);
        }
      } else {
        newItem.isSecret = secretRarities.contains(data.rarity.id);

        if( pos == null) {
          widget.se.seCards.cards.add([newItem]);
        } else {
          widget.se.seCards.cards.insert(pos, [newItem]);
        }
      }

      updateCardList(listId);
    });
  }

  void removeCard(int listId,int localId) {
    setState(() {
      var cardList;
      if(listId == 1)
        cardList = widget.se.seCards.energyCard;
      else if(listId == 2)
        cardList = widget.se.seCards.noNumberedCard;
      else
        cardList = widget.se.seCards.cards;

      _modify = true;
      cardList.removeAt(localId);

      updateCardList(listId);
    });
  }

  @override
  void initState() {
    updateCardList(0);
    updateCardList(1);
    updateCardList(2);

    super.initState();
  }

  Widget cardBuilder(PokemonCardExtension card, int id, int listId) {
    // Search if Jap Card link exist
    var colorCard = Color(0xFF5D9070);
    if( Environment.instance.collection.pokemonCards.containsValue(card.data) ) {
      var subEx = Environment.instance.collection
          .searchCardIntoAllSubExtension(card.data);
      int count = 0;
      for (var element in subEx) {
        if (element.se.extension.language.isJapanese()) {
          count += 1;
        }
      }

      if(widget.language.isJapanese()) {
        // Show multi link
        colorCard = count > 1 ? Colors.cyan : Colors.green[900]!;
      } else {
        // Show link with japan
        colorCard = count > 0 ? Colors.green[800]! : Colors.grey[900]!;
      }
    } else  {
      colorCard = Colors.grey[800]!;
    }

    int localId     = id;
    int localListId = listId;
    var idCard = CardIdentifier.from(localListId != 0 ? [localListId, localId] : [localListId, localId, 0]);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextButton(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [card.imageType()]+card.imageRarity(widget.language)),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.se.seCards.numberOfCard(localId)),
                  if(widget.language.isJapanese() && card.tryGetImage(CardImageIdentifier()).jpDBId == 0) Icon(Icons.broken_image, color: Colors.deepOrange, size: 11),
                  if(card.data.missingMainData())           Icon(Icons.text_format, color: Colors.red, size: 10),
                  if(card.data.cardEffects.effects.isEmpty) Icon(Icons.filter_vintage_outlined, color: Colors.red, size: 10),
              ])
            ]
        ),
        style: TextButton.styleFrom(
            backgroundColor: colorCard,
            padding: const EdgeInsets.all(2.0)
        ),
        onLongPress: () {
          setState(() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: Center(child: Text(StatitikLocale.of(context).read('NCE_B3'), style: Theme.of(context).textTheme.headline3)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    Card(
                      color: Colors.grey[700],
                      child: TextButton(
                        child: Text(StatitikLocale.of(context).read('NCE_B4')),
                        onPressed: () {
                          onAddCard(localListId, localId);
                          Navigator.of(context).pop();
                        },
                      )
                    ),
                    Card(
                      color: Colors.red,
                      child: TextButton(
                        child: Text(StatitikLocale.of(context).read('NCE_B5')),
                        onPressed: () {
                          removeCard(localListId, localId);
                          Navigator.of(context).pop();
                        },
                      )
                    ),
                  ]
                );
              }
            );
          });
        },
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardEditor(widget.language.isWorld(), widget.se, idCard)),
          ).then((value) {
            setState(() {
              updateCardList(localListId);
              _modify   = true;
            });
          });
        },
      ),
    );
  }

  List<Widget> _cards() {
    List<Widget> myCards = [];
    int id=0;
    int listId=0;
    if( widget.se.seCards.isValid ) {
      widget.se.seCards.cards.forEach((cardList) {
        // Select only first
        var card = cardList[0];
        myCards.add( cardBuilder(card, id, listId) );

        id += 1;
      });
    }
    return myCards;
  }

  List<Widget> _cardsEnergy() {
    List<Widget> myCards = [];
    int id=0;
    int listId=1;
    if( widget.se.seCards.isValid ) {
      widget.se.seCards.energyCard.forEach((cardList) {
        myCards.add( cardBuilder(cardList, id, listId) );

        id += 1;
      });
    }
    return myCards;
  }

  List<Widget> _cardsNoNumber() {
    List<Widget> myCards = [];
    int id=0;
    int listId=2;
    if( widget.se.seCards.isValid ) {
      widget.se.seCards.noNumberedCard.forEach((cardList) {
        // Select only first
        myCards.add( cardBuilder(cardList, id, listId) );

        id += 1;
      });
    }
    return myCards;
  }

  Future<bool> backAction(BuildContext context) async {
    if( !_modify ) {
      Navigator.of(context).pop(true);
    } else {
      widget.se.computeStats();
      var exit = await showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return showExit(context);
          });
      if (exit) {
        Navigator.of(context).pop(true);
      } else {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return backAction(context);
    },
    child: Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            children: [
              Image(image: widget.language.create(), height: 30),
              SizedBox(width: 4.0),
              widget.se.image(hSize: 30),
              SizedBox(width: 4.0),
              Flexible(
                child:Text(widget.se.name, softWrap: true,
                  style: Theme.of(context).textTheme.headline6?..copyWith(
                    fontSize: widget.se.name.length > 9 ? 7 : 10
                  )
                )
              ),
            ]
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            backAction(context);
          },
        ),
        actions: [if(_modify) Card(child: TextButton(
          child: Text(StatitikLocale.of(context).read('NCE_B1')),
          onPressed: () {
            EasyLoading.show();
            widget.se.computeStats();
            // Send database info
            Environment.instance.sendCardInfo(widget.se)
              .onError((error, stackTrace) {
                EasyLoading.showError('Error');
                return false;
              })
              .then( (isValid) {
                EasyLoading.dismiss();
                if(isValid)
                  Navigator.of(context).pop();
                else
                  EasyLoading.showError('Invalid');
            });
          },
        )) ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) {
                    return Row(children:[
                      Icon(Icons.add_box_outlined),
                      SizedBox(width: 4),
                      Text("Quick Creator")
                      ]
                    );
                  },
                  body: CardCreator.quick(widget.language, widget.se, data, CardIdentifier.from([0, 0, 0]), onAddCard, widget.language.isWorld(), onChangeList: onChangeList),
                  isExpanded: _showQuickCreator,
                )
              ],
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (i, isOpen) {
                setState(() {
                  _showQuickCreator = !isOpen;
                });
              },
              elevation: 0,
            ),
            if(widget.se.seCards.cards.isNotEmpty && idList == 0) GridView.count(
                primary: false,
                children: _cardInfo,
                shrinkWrap: true,
                childAspectRatio: 1.35,
                crossAxisCount: 5,
            ),
            if(widget.se.seCards.energyCard.isNotEmpty && idList == 1) GridView.count(
              primary: false,
              children: _cardEnergyInfo,
              shrinkWrap: true,
              childAspectRatio: 1.35,
              crossAxisCount: 5,
            ),
            if(widget.se.seCards.noNumberedCard.isNotEmpty && idList == 2) GridView.count(
              primary: false,
              children: _cardNoNumberInfo,
              shrinkWrap: true,
              childAspectRatio: 1.35,
              crossAxisCount: 5,
            ),
          ],
        )

      )
    )
    );
  }

  AlertDialog showExit(BuildContext context) {
    return AlertDialog(
      title: Text(StatitikLocale.of(context).read('warning')),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(StatitikLocale.of(context).read('NCE_B8')),
          ],
        ),
      ),
      actions: <Widget>[
        Card(
          color: Colors.red,
          child: TextButton(
            child: Text(StatitikLocale.of(context).read('yes')),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
        Card(
          child: TextButton(
            child: Text(StatitikLocale.of(context).read('cancel')),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      ],
    );
  }
}
