import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/Admin/cardCreator.dart';
import 'package:statitikcard/screen/Admin/cardEditor.dart';
import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class NewCardExtensions extends StatefulWidget {
  const NewCardExtensions({Key? key}) : super(key: key);

  @override
  _NewCardExtensionsState createState() => _NewCardExtensionsState();
}

class _NewCardExtensionsState extends State<NewCardExtensions> {
  Language?     _language;
  SubExtension? _se;
  List<Widget>  _cardInfo = [];
  bool _modify = false;
  PokemonCardExtension data = PokemonCardExtension(PokemonCardData([], Level.Base, Type.Plante, CardMarkers.from([])) , Rarity.Commune);

  void onAddCard(int? pos) {
    setState((){
      _modify = true;

      // Remove default state
      if( !_se!.seCards.isValid ) {
        _se!.seCards.cards.clear();
        _se!.seCards.isValid = true;
      }
      // Add new card
      var newItem = PokemonCardExtension(PokemonCardData([], data.data.level, data.data.type, CardMarkers.from([])),
                    data.rarity);
      if( pos == null) {
        _se!.seCards.cards.add([newItem]);
      } else {
        _se!.seCards.cards.insert(pos, [newItem]);
      }
      _cardInfo = _cards();
    });
  }

  void removeCard(int localId) {
    setState(() {
      _modify = true;
      _se!.seCards.cards.removeAt(localId);
      _cardInfo = _cards();
    });
  }

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.pop(context);
    Navigator.pop(context);
    setState(() {
      // Change selection
      _language = language;
      _se       = subExt;
      _cardInfo = _cards();
    });
  }

  List<Widget> _cards() {
    List<Widget> myCards = [];
    int id=0;
    if( _se!.seCards.isValid ) {
      _se!.seCards.cards.forEach((cardList) {
        // Select only first
        var card = cardList[0];

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

        int localId = id;
        myCards.add( Padding(
          padding: const EdgeInsets.all(2.0),
          child: TextButton(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row( mainAxisAlignment: MainAxisAlignment.center,
                         children: [card.imageType()]+card.imageRarity()),
                    Text(_se!.seCards.numberOfCard(localId)),
                    if(_language!.isJapanese() && card.jpDBId == 0) Icon(Icons.broken_image),
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
                                    onAddCard(localId);
                                    Navigator.of(context).pop();
                                  },
                              )),
                              Card(
                                color: Colors.red,
                                child: TextButton(
                                child: Text(StatitikLocale.of(context).read('NCE_B5')),
                                onPressed: () {
                                  removeCard(localId);
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
                  MaterialPageRoute(builder: (context) => CardEditor(card, _language!.isWorld(), _se!, localId)),
                ).then((value) =>
                    setState(() {
                      _cardInfo = _cards();
                      _modify   = true;
                    }));
              },
          ),
        ));
        id +=1;
      });
    }
    return myCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(StatitikLocale.of(context).read('NCE_T0')),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            if( !_modify ) {
              Navigator.of(context).pop(true);
            } else {
              showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) { return showExit(context); }).then((exit)
              {
                if(exit)
                  Navigator.of(context).pop(true);
              });
            }
          },
        ),
        actions: [if(_modify) Card(child: TextButton(
          child: Text(StatitikLocale.of(context).read('NCE_B1')),
          onPressed: () {
            EasyLoading.show();
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
            if(_se != null) CardCreator.quick(_language!, _se!, data, 0, onAddCard, _language!.isWorld()),
            if(_se != null && _se!.seCards.cards.isNotEmpty) GridView.count(
                primary: false,
                children: _cardInfo,
                shrinkWrap: true,
                crossAxisCount: 5,
            ),
          ],
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
