import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/admin/card_creator.dart';
import 'package:statitikcard/screen/admin/card_editor.dart';
import 'package:statitikcard/screen/admin/card_editor_options.dart';

import 'package:statitikcard/services/collection.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/marker.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/sub_extension_cards.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/tools.dart';

class NewCardExtensions extends StatefulWidget {
  final Language     language;
  final SubExtension se;

  const NewCardExtensions(this.language, this.se, {Key? key}) : super(key: key);

  @override
  State<NewCardExtensions> createState() => _NewCardExtensionsState();
}

class _NewCardExtensionsState extends State<NewCardExtensions> {
  List<Widget>  _cardInfo         = [];
  List<Widget>  _cardEnergyInfo   = [];
  List<Widget>  _cardNoNumberInfo = [];
  bool _modify = false;
  PokemonCardExtension data = PokemonCardExtension.creation(PokemonCardData([], Level.base, TypeCard.plante, CardMarkers.from([])), Environment.instance.collection.rarities[Collection.idEmptyRarity]!, Environment.instance.collection.sets);
  int idList = 0;
  bool _showQuickCreator = true;
  CardEditorOptions options = CardEditorOptions();

  final List<int> secretRarities = const [21, 22, 23, 24, 25, 26, 27, 36, 37];

  void onRefreshList() {
    setState(() {
      _modify = true;
    });
  }
  void onChangeList(int newIdList) {
   setState(() {
     idList = newIdList;
   });
  }

  void updateCardList(int listId) {
    if(listId == 1) {
      _cardEnergyInfo   = _cardsEnergy();
    } else if(listId == 2) {
      _cardNoNumberInfo = _cardsNoNumber();
    } else {
      _cardInfo = _cards();
    }
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
          data.rarity, Environment.instance.collection.sets, isJapanese: widget.se.extension.language.isJapanese());

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
      List cardList;
      if(listId == 1) {
        cardList = widget.se.seCards.energyCard;
      } else if(listId == 2) {
        cardList = widget.se.seCards.noNumberedCard;
      } else {
        cardList = widget.se.seCards.cards;
      }

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
    var colorCard = const Color(0xFF5D9070);
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
    var numberCard = widget.se.seCards.numberOfCard(localId);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextButton(
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
                  title: Center(child: Text(StatitikLocale.of(context).read('NCE_B3'), style: Theme.of(context).textTheme.displaySmall)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
            MaterialPageRoute(builder: (context) => CardEditor(widget.se, idCard, options)),
          ).then((value) {
            setState(() {
              updateCardList(localListId);
              _modify   = true;
            });
          });
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [card.imageType()]+card.imageRarity(widget.language)),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(numberCard, style: TextStyle(fontSize: numberCard.length > 3 ? 10 : 12)),
                  if(widget.language.isJapanese() && card.tryGetImage(CardImageIdentifier()).jpDBId == 0) const Icon(Icons.broken_image, color: Colors.deepOrange, size: 11),
                  if(card.data.missingMainData())           const Icon(Icons.text_format, color: Colors.red, size: 10),
                  if(card.data.cardEffects.effects.isEmpty) const Icon(Icons.filter_vintage_outlined, color: Colors.red, size: 10),
              ])
            ]
        ),
      ),
    );
  }

  List<Widget> _cards() {
    List<Widget> myCards = [];
    int id=0;
    int listId=0;
    if( widget.se.seCards.isValid ) {
      for (var cardList in widget.se.seCards.cards) {
        // Select only first
        var card = cardList[0];
        myCards.add( cardBuilder(card, id, listId) );

        id += 1;
      }
    }
    return myCards;
  }

  List<Widget> _cardsEnergy() {
    List<Widget> myCards = [];
    int id=0;
    int listId=1;
    if( widget.se.seCards.isValid ) {
      for (var cardList in widget.se.seCards.energyCard) {
        myCards.add( cardBuilder(cardList, id, listId) );

        id += 1;
      }
    }
    return myCards;
  }

  List<Widget> _cardsNoNumber() {
    List<Widget> myCards = [];
    int id=0;
    int listId=2;
    if( widget.se.seCards.isValid ) {
      for (var cardList in widget.se.seCards.noNumberedCard) {
        // Select only first
        myCards.add( cardBuilder(cardList, id, listId) );

        id += 1;
      }
    }
    return myCards;
  }

  bool backAction(BuildContext context) {
    if( !_modify ) {
      Navigator.of(context).pop(true);
    } else {
      widget.se.computeStats();
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return showExit(context);
        }).then((exit) {
          if (exit) {
            Navigator.of(context).pop(true);
          } else {
            return false;
          }
        }
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        bool exit = backAction(context);
        return Future.value(exit);
    },
    child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image(image: widget.language.create(), height: 30),
            const SizedBox(width: 4.0),
            widget.se.image(hSize: 30),
            const SizedBox(width: 4.0),
            Flexible(
              child:Text(widget.se.name, softWrap: true,
                style: Theme.of(context).textTheme.titleLarge?..copyWith(
                  fontSize: widget.se.name.length > 9 ? 7 : 10
                )
              )
            ),
          ]
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                if(isValid) {
                  Navigator.of(context).pop();
                } else {
                  EasyLoading.showError('Invalid');
                }
            });
          },
        )) ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Expanded(child: Text("Etat")),
              IconButton(icon: const Icon(Icons.folder_copy_outlined),
                color: mask(widget.se.seCards.configuration, SubExtensionCards.codeHasAlternativeSet) ? Colors.green : Colors.grey,
                onPressed: (){
                  setState(() {
                    int code = mask(widget.se.seCards.configuration, SubExtensionCards.codeHasAlternativeSet) ? 0 : SubExtensionCards.codeHasAlternativeSet;
                    widget.se.seCards.configuration = setMask(widget.se.seCards.configuration, code, SubExtensionCards.codeHasAlternativeSet);

                    printOutput("${widget.se.seCards.configuration}");
                  });
                },
              ),
              IconButton(icon: const Icon(Icons.battery_charging_full),
                color: mask(widget.se.seCards.configuration, SubExtensionCards.codeHasBoosterEnergy) ? Colors.green : Colors.grey,
                onPressed: (){
                  setState(() {
                    int code = mask(widget.se.seCards.configuration, SubExtensionCards.codeHasBoosterEnergy) ? 0 : SubExtensionCards.codeHasBoosterEnergy;
                    widget.se.seCards.configuration = setMask(widget.se.seCards.configuration, code, SubExtensionCards.codeHasBoosterEnergy);
                    printOutput("${widget.se.seCards.configuration}");
                  });
                },
              ),
              IconButton(icon: const Icon(Icons.account_tree),
                color: mask(widget.se.seCards.configuration, SubExtensionCards.codeNotInsideRandom) ? Colors.green : Colors.grey,
                onPressed: (){
                  setState(() {
                    int code = mask(widget.se.seCards.configuration, SubExtensionCards.codeNotInsideRandom) ? 0 : SubExtensionCards.codeNotInsideRandom;
                    widget.se.seCards.configuration = setMask(widget.se.seCards.configuration, code, SubExtensionCards.codeNotInsideRandom);
                    printOutput("${widget.se.seCards.configuration}");
                  });
                },
              )
            ]),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) {
                    return const Row(children: [
                      Icon(Icons.add_box_outlined),
                      SizedBox(width: 4),
                      Text("Quick Creator")
                      ]
                    );
                  },
                  body: CardCreator.quick(widget.language, widget.se, data, CardIdentifier.from([0, 0, 0]), onAddCard, onRefreshList, widget.language.isWorld(), onChangeList: onChangeList),
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
                shrinkWrap: true,
                childAspectRatio: 1.35,
                crossAxisCount: 5,
                children: _cardInfo,
            ),
            if(widget.se.seCards.energyCard.isNotEmpty && idList == 1) GridView.count(
              primary: false,
              shrinkWrap: true,
              childAspectRatio: 1.35,
              crossAxisCount: 5,
              children: _cardEnergyInfo,
            ),
            if(widget.se.seCards.noNumberedCard.isNotEmpty && idList == 2) GridView.count(
              primary: false,
              shrinkWrap: true,
              childAspectRatio: 1.35,
              crossAxisCount: 5,
              children: _cardNoNumberInfo,
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
