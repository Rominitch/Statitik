import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/screen/Admin/cardEditor.dart';
import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/Marker.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/PokemonCardData.dart';

class NewCardExtensions extends StatefulWidget {
  const NewCardExtensions({Key? key}) : super(key: key);

  @override
  _NewCardExtensionsState createState() => _NewCardExtensionsState();
}

class _NewCardExtensionsState extends State<NewCardExtensions> {
  Language?     _language;
  SubExtension? _se;
  List<Widget>  _cardInfo         = [];
  List<Widget>  _cardEnergyInfo   = [];
  List<Widget>  _cardNoNumberInfo = [];
  bool _modify = false;
  PokemonCardExtension data = PokemonCardExtension.creation(PokemonCardData([], Level.Base, TypeCard.Plante, CardMarkers.from([])), Environment.instance.collection.unknownRarity!, Environment.instance.collection.sets);
  int idList = 0;

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
      if( !_se!.seCards.isValid ) {
        _se!.seCards.cards.clear();
        _se!.seCards.isValid = true;
      }

      // Create new card
      var newItem = PokemonCardExtension.creation(PokemonCardData([], data.data.level, data.data.type, CardMarkers.from([])),
          data.rarity, Environment.instance.collection.sets);

      // Added
      if(listId == 1) {
        if( pos == null) {
            _se!.seCards.energyCard.add(newItem);
        } else {
          _se!.seCards.energyCard.insert(pos, newItem);
        }
      }
      else if(listId == 2) {
        if( pos == null) {
          _se!.seCards.noNumberedCard.add(newItem);
        } else {
          _se!.seCards.noNumberedCard.insert(pos, newItem);
        }
      } else {
        if( pos == null) {
          _se!.seCards.cards.add([newItem]);
        } else {
          _se!.seCards.cards.insert(pos, [newItem]);
        }
      }

      updateCardList(listId);
    });
  }

  void removeCard(int listId,int localId) {
    setState(() {
      var cardList;
      if(listId == 1)
        cardList = _se!.seCards.energyCard;
      else if(listId == 2)
        cardList = _se!.seCards.noNumberedCard;
      else
        cardList = _se!.seCards.cards;

      _modify = true;
      cardList.removeAt(localId);

      updateCardList(listId);
    });
  }

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.pop(context);
    Navigator.pop(context);
    setState(() {
      // Change selection
      _language = language;
      _se       = subExt;

      updateCardList(0);
      updateCardList(1);
      updateCardList(2);
    });
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

      if(_language!.isJapanese()) {
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
    var idCard = localListId != 0 ? [localListId, localId] : [localListId, localId,0];
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextButton(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [card.imageType()]+card.imageRarity(_language!)),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_se!.seCards.numberOfCard(localId)),
                  if(_language!.isJapanese() && card.jpDBId == 0) Icon(Icons.broken_image, color: Colors.deepOrange, size: 11)
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
                            )),
                        Card(
                            color: Colors.red,
                            child: TextButton(
                              child: Text(StatitikLocale.of(context).read('NCE_B5')),
                              onPressed: () {
                                removeCard(localListId, localId);
                                Navigator.of(context).pop();
                              },
                            )),
                      ]
                  );
                }
            );
          });
        },
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardEditor(card, _language!.isWorld(), _se!, idCard)),
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
    if( _se!.seCards.isValid ) {
      _se!.seCards.cards.forEach((cardList) {
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
    if( _se!.seCards.isValid ) {
      _se!.seCards.energyCard.forEach((cardList) {
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
    if( _se!.seCards.isValid ) {
      _se!.seCards.noNumberedCard.forEach((cardList) {
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
      _se!.computeStats();
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
          child: Text(StatitikLocale.of(context).read('NCE_T0')),
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
            _se!.computeStats();
            // Send database info
            Environment.instance.sendCardInfo(_se!)
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
            Card(
              child: TextButton(
                child: _language != null ? Row(
                  children: [
                    Text(StatitikLocale.of(context).read('S_B0')),
                    SizedBox(width: 8.0),
                    Image(image: _language!.create(), height: 30),
                    SizedBox(width: 8.0),
                    Tooltip(message: _se!.name,
                      child:_se!.image(hSize: 30)),
                  ]) : Text(StatitikLocale.of(context).read('S_B0')),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension, addMode: false)));
                },
              )
            ),
            if(_se != null) CardCreator.quick(_language!, _se!, data, [0, 0, 0], onAddCard, _language!.isWorld(), onChangeList: onChangeList),
            if(_se != null && _se!.seCards.cards.isNotEmpty && idList == 0) GridView.count(
                primary: false,
                children: _cardInfo,
                shrinkWrap: true,
                childAspectRatio: 1.3,
                crossAxisCount: 5,
            ),
            if(_se != null && _se!.seCards.energyCard.isNotEmpty && idList == 1) GridView.count(
              primary: false,
              children: _cardEnergyInfo,
              shrinkWrap: true,
              childAspectRatio: 1.3,
              crossAxisCount: 5,
            ),
            if(_se != null && _se!.seCards.noNumberedCard.isNotEmpty && idList == 2) GridView.count(
              primary: false,
              children: _cardNoNumberInfo,
              shrinkWrap: true,
              childAspectRatio: 1.3,
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
