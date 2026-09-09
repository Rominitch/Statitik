import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/admin_card_creator.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card.dart';
import 'package:statitikcard/models/poke_card_design.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';

import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/screenOld/admin/card_creator.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/widgets/expansion/widget_creator_card_from_expansion.dart';
import 'package:statitikcard/widgets/expansion/widget_creator_card_quick.dart';

class PageAdminEditExpansion extends StatefulWidget {
  final PokeNavAdmin       _nav;
  final ExpansionSelection _expension;
  final Function           _onReturn;

  const PageAdminEditExpansion(this._nav, this._expension, this._onReturn, {super.key});

  @override
  State<PageAdminEditExpansion> createState() => _PageAdminEditExpansionState();
}

class _PageAdminEditExpansionState extends State<PageAdminEditExpansion> {
  List<Widget>  _cardInfo         = [];
  List<Widget>  _cardEnergyInfo   = [];
  List<Widget>  _cardNoNumberInfo = [];
  bool _modify = false;
  late AdminCardCreator _creator;

  int idList = 0;
  bool _showQuickCreator = true;
  CardEditorOptions options = CardEditorOptions();

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

  bool isJapanese() {
    return widget._expension.language!.location() == CardLocation.Asie;
  }

  void onAddCard(int listId, int? pos) {
    setState((){
      _modify = true;

      // Remove default state
      final cards = widget._expension.expansion!.cards;
      if( !cards.isValid() ) {
        cards.cards.clear();
      }

      final newItem = _creator.newCard();
      // Added
      if(listId == 1) {
        if( pos == null) {
          cards.energyCard.add(newItem);
        } else {
          cards.energyCard.insert(pos, newItem);
        }
      }
      else if(listId == 2) {
        if( pos == null) {
          cards.noNumberedCard.add(newItem);
        } else {
          cards.noNumberedCard.insert(pos, newItem);
        }
      } else {
        if( pos == null) {
          cards.cards.add([newItem]);
        } else {
          cards.cards.insert(pos, [newItem]);
        }
      }

      updateCardList(listId);
    });
  }

  void removeCard(int listId,int localId) {
    setState(() {
      final cards = widget._expension.expansion!.cards;
      List cardList;
      if(listId == 1) {
        cardList = cards.energyCard;
      } else if(listId == 2) {
        cardList = cards.noNumberedCard;
      } else {
        cardList = cards.cards;
      }

      _modify = true;
      cardList.removeAt(localId);

      updateCardList(listId);
    });
  }

  @override
  void initState() {
    _creator = AdminCardCreator(widget._nav, widget._expension.expansion!);

    updateCardList(0);
    updateCardList(1);
    updateCardList(2);

    super.initState();
  }

  Widget cardBuilder(PokeCardInExpansion card, int id, int listId) {
    final cards = widget._expension.expansion!.cards;

    // Search if Jap Card link exist
    var colorCard = const Color(0xFF5D9070);

    if( widget._nav.collection.containsCard(card.card) ) {
      var subEx = widget._nav.collection
          .searchCardIntoAllSubExtension(card.card);
      int count = 0;
      for (final element in subEx) {
        if (element.expansion.location() == CardLocation.Asie) {
          count += 1;
        }
      }

      if(isJapanese()) {
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
    var idCard = PokeCardIdentifier.from([localListId, localId, 0]);
    var numberCard = cards.numberOfCard(localId);

    bool hasJPImageLink = false;
    if( isJapanese() ) {
      final imageId = PokeCardImageIdentifier(card.setInfo.keys.first);
      final cardDesign = card.tryGetImage(imageId);
      if(cardDesign != null) {
        hasJPImageLink = cardDesign!.jpDBId == 0;
      }
    }


    return Card(
      color: colorCard,
      child: TextButton(
        onLongPress: () {
          setState(() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: Center(child: Text(AppLocalizations.of(context)!.nce_b3, style: Theme.of(context).textTheme.displaySmall)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    Card(
                      color: Colors.grey[700],
                      child: TextButton(
                        child: Text(AppLocalizations.of(context)!.nce_b4),
                        onPressed: () {
                          onAddCard(localListId, localId);
                          Navigator.of(context).pop();
                        },
                      )
                    ),
                    Card(
                      color: Colors.red,
                      child: TextButton(
                        child: Text(AppLocalizations.of(context)!.nce_b5),
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
          //TODO
          /*
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardEditor(widget.se, idCard, options)),
          ).then((value) {
            setState(() {
              updateCardList(localListId);
              _modify   = true;
            });
          });
          */
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row( mainAxisAlignment: MainAxisAlignment.center,
                children: [card.imageType()] + widget._nav.rendering.imageRarity(card.rarity)),
            Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(numberCard, style: TextStyle(fontSize: numberCard.length > 3 ? 10 : 12)),
                  if(isJapanese() && !hasJPImageLink) const Icon(Icons.broken_image, color: Colors.deepOrange, size: 11),
                  if(card.card.missingMainData())           const Icon(Icons.text_format, color: Colors.red, size: 10),
                  if(card.card.cardEffects.effects.isEmpty) const Icon(Icons.filter_vintage_outlined, color: Colors.red, size: 10),
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
    final cards = widget._expension.expansion!.cards;

    if( cards.isValid() ) {
      for (var cardList in cards.cards) {
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
    final cards = widget._expension.expansion!.cards;

    if( cards.isValid() ) {
      for (var cardList in cards.energyCard) {
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
    final cards = widget._expension.expansion!.cards;

    if( cards.isValid() ) {
      for (var cardList in cards.noNumberedCard) {
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
      // TODO: migration
      //widget._expension.expansion!.computeStats();
      showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return showExit(context);
          }).then((exit) {
        if (exit) {
          if(context.mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          return false;
        }
      }
      );
    }
    return true;
  }

  Widget headerExpansion() {
    final expansion = widget._expension.expansion!;
    return Row(children: [
      const Expanded(child: Text("Etat")),
      Tooltip(
        message: AppLocalizations.of(context)!.hasAlternativeSet,
        child: IconButton(icon: const Icon(Icons.folder_copy_outlined),
          color: expansion.cards.hasAlternativeSet() ? Colors.green : Colors.grey,
          onPressed: (){
            setState(() {
              // Toggle
              expansion.cards.setAlternativeSet(!expansion.cards.hasAlternativeSet());
              printOutput("${expansion.cards.configuration}");
            });
          },
        ),
      ),
      /*
      IconButton(icon: const Icon(Icons.battery_charging_full),
        color: expansion.cards.hasBoosterEnergy() ? Colors.green : Colors.grey,
        onPressed: (){
          setState(() {
            // Toggle
            expansion.cards.setBoosterEnergy(!expansion.cards.hasBoosterEnergy());
            printOutput("${expansion.cards.configuration}");
          });
        },
      ),
      */
      IconButton(icon: const Icon(Icons.account_tree),
        color: expansion.cards.notInsideRandom() ? Colors.green : Colors.grey,
        onPressed: (){
          setState(() {
            // Toggle
            expansion.cards.setNotInsideRandom(!expansion.cards.notInsideRandom());
            printOutput("${expansion.cards.configuration}");
          });
        },
      )
    ]);
  }

  Widget mobileView() {
    final expansion = widget._expension.expansion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(2.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerExpansion(),
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
                  isExpanded: _showQuickCreator,
                  //TODO : Migration
                  body: Placeholder()//CardCreator.quick(widget.language, expansion, data, PokeCardIdentifier.from([0, 0, 0]), onAddCard, onRefreshList, widget.language.isWorld(), onChangeList: onChangeList),
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
          if(expansion.cards.cards.isNotEmpty && idList == 0) GridView.count(
            primary: false,
            shrinkWrap: true,
            childAspectRatio: 1.35,
            crossAxisCount: 5,
            children: _cardInfo,
          ),
          if(expansion.cards.energyCard.isNotEmpty && idList == 1) GridView.count(
            primary: false,
            shrinkWrap: true,
            childAspectRatio: 1.35,
            crossAxisCount: 5,
            children: _cardEnergyInfo,
          ),
          if(expansion.cards.noNumberedCard.isNotEmpty && idList == 2) GridView.count(
            primary: false,
            shrinkWrap: true,
            childAspectRatio: 1.35,
            crossAxisCount: 5,
            children: _cardNoNumberInfo,
          ),
        ],
      )
    );
  }

  Widget desktopView() {
    final expansion = widget._expension.expansion!;
    final language  = widget._expension.language!;


    return LayoutBuilder(builder: (context, box) {
      final count = (box.maxWidth / PokeRendering.bestMiniCardWidth).ceil();
      final ratio = PokeRendering.bestMiniCardRatio;
      Widget? cardsGrid;
      switch(idList)
      {
        case 0:
          {
            cardsGrid = GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count, crossAxisSpacing: 0, mainAxisSpacing: 0,
                  childAspectRatio: ratio),
              primary: false,
              shrinkWrap: true,
              itemCount: widget._expension.expansion!.cards.cards.length,
              itemBuilder: (context, index) {
                final cards = widget._expension.expansion!.cards.cards;
                final card = cards[index][0];

                return cardBuilder(card, index, 0);
              },
            );
          }
          break;
        case 1:
          {
            cardsGrid = GridView.count(
              primary: false,
              shrinkWrap: true,
              childAspectRatio: ratio,
              crossAxisCount: count,
              children: _cardEnergyInfo,
            );
          }
          break;
        case 2:
          {
            cardsGrid = GridView.count(
              primary: false,
              shrinkWrap: true,
              childAspectRatio: ratio,
              crossAxisCount: count,
              children: _cardNoNumberInfo,
            );
          }
          break;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerExpansion(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: WidgetCreatorCardQuick(widget._nav, _creator, onAddCard, onRefreshList,
                  onChangeList: onChangeList),
              ),
              Expanded(
                flex: 2,
                child: cardsGrid!,
              )
            ],
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final expansion = widget._expension.expansion!;
    final language  = widget._expension.language!;
    final expName   = expansion.label(language)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image(image: language.create(), height: 30),
            const SizedBox(width: 4.0),
            expansion.image(language, hSize: 30),
            const SizedBox(width: 4.0),
            Flexible(
              child:Text(expName, softWrap: true,
                style: Theme.of(context).textTheme.titleLarge?..copyWith(
                    fontSize: expName.length > 9 ? 7 : 10
                )
              )
            ),
          ]
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //backAction(context);
            widget._onReturn();
          },
        ),
        actions: [if(_modify) Card(child: TextButton(
          child: Text(AppLocalizations.of(context)!.nce_b1),
          onPressed: () {
            EasyLoading.show();
            //TODO
            //expansion.computeStats();
            // Send database info
            widget._nav.database.transactionR( (connection) {
              return widget._nav.collection.saveDatabaseSEC(expansion, connection);
            }).onError((error, stackTrace) {
              EasyLoading.showError('Error');
              return false;
            }).then( (isValid) {
              EasyLoading.dismiss();
              if(isValid) {
                widget._onReturn();
              } else {
                EasyLoading.showError('Invalid');
              }
            });
          },
        )) ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          backAction(context);
        },
        child: LayoutBuilder(builder: (context, box) {
            if( box.maxWidth > 600 ) {
              return desktopView();
            } else {
              return mobileView();
            }
          }
        )
      )
    );
  }

  AlertDialog showExit(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.warning),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(AppLocalizations.of(context)!.nce_b8),
          ],
        ),
      ),
      actions: <Widget>[
        Card(
          color: Colors.red,
          child: TextButton(
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
        Card(
          child: TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      ],
    );
  }
}