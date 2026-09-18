import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/admin_card_creator.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/screens/admin/page_admin_edit_card.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/widgets/expansion/widget_creator_card_quick.dart';

class PageAdminEditExpansion extends StatefulWidget {
  final PokeNavAdmin       _nav;
  final ExpansionSelection _expansion;
  final Function           _onReturn;

  const PageAdminEditExpansion(this._nav, this._expansion, this._onReturn, {super.key});

  @override
  State<PageAdminEditExpansion> createState() => _PageAdminEditExpansionState();
}

class _PageAdminEditExpansionState extends State<PageAdminEditExpansion> {
  bool _modify = false;
  late AdminCardCreator _creator;

  int idList = 0;
  bool _showQuickCreator = true;

  PokeCardIdentifier? activeCard;
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

  bool isJapanese() {
    return widget._expansion.language!.location() == CardLocation.Asie;
  }

  void onAddCard(int listId, int? pos) {
    setState((){
      _modify = true;

      // Remove default state
      final cards = widget._expansion.expansion!.cards;
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
    });
  }

  void removeCard(int listId,int localId) {
    setState(() {
      final cards = widget._expansion.expansion!.cards;
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
    });
  }

  @override
  void initState() {
    _creator = AdminCardCreator(widget._nav, widget._expansion.expansion!);

    super.initState();
  }

  Widget cardBuilder(PokeCardInExpansion card, int id, int listId) {
    final cards = widget._expansion.expansion!.cards;

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
    var numberCard = cards.numberOfCard(localId);

    bool hasJPImageLink = false;
    if( isJapanese() ) {
      final imageId = PokeCardImageIdentifier(card.setInfo.keys.first);
      final cardDesign = card.tryGetImage(imageId);
      if(cardDesign != null) {
        hasJPImageLink = cardDesign.jpDBId == 0;
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
          setState(() {
            activeCard = PokeCardIdentifier.from([localListId, localId, 0]);
          });
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
    final expansion = widget._expansion.expansion!;
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
    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, crossAxisSpacing: 0, mainAxisSpacing: 0,
        childAspectRatio: PokeRendering.bestMiniCardRatio);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(2.0),
      child: Column(
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
                  body: WidgetCreatorCardQuick(widget._nav, _creator, onAddCard, onRefreshList,
                      onChangeList: onChangeList),//CardCreator.quick(widget.language, expansion, data, PokeCardIdentifier.from([0, 0, 0]), onAddCard, onRefreshList, widget.language.isWorld(), onChangeList: onChangeList),
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
          cardGrids(delegate)
        ],
      )
    );
  }

  Widget cardGrids(SliverGridDelegate delegate) {
    switch(idList)
    {
      case 0:
        {
          return GridView.builder(
            gridDelegate: delegate,
            itemCount: widget._expansion.expansion!.cards.cards.length,
            itemBuilder: (context, index) {
              final cards = widget._expansion.expansion!.cards.cards;
              final card = cards[index][0];
              return cardBuilder(card, index, 0);
            },
          );
        }
      case 1:
        {
          return GridView.builder(
            gridDelegate: delegate,
            itemCount: widget._expansion.expansion!.cards.energyCard.length,
            itemBuilder: (context, index) {
              final cards = widget._expansion.expansion!.cards.energyCard;
              final card = cards[index];
              return cardBuilder(card, index, 0);
            },
          );
        }
      case 2:
        {
          return GridView.builder(
            gridDelegate: delegate,
            itemCount: widget._expansion.expansion!.cards.noNumberedCard.length,
            itemBuilder: (context, index) {
              final cards = widget._expansion.expansion!.cards.noNumberedCard;
              final card = cards[index];
              return cardBuilder(card, index, 0);
            },
          );
        }
    }
    throw "No valid card id";
  }

  Widget desktopView(BoxConstraints box) {
    final count = (box.maxWidth / PokeRendering.bestMiniCardWidth).ceil();
    final delegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count, crossAxisSpacing: 0, mainAxisSpacing: 0,
        childAspectRatio: PokeRendering.bestMiniCardRatio);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        headerExpansion(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: WidgetCreatorCardQuick(widget._nav, _creator, onAddCard, onRefreshList,
                  onChangeList: onChangeList),
              ),
              Expanded(
                flex: 2,
                child: cardGrids(delegate),
              )
            ],
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final expansion = widget._expansion.expansion!;
    final language  = widget._expansion.language!;
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
            if( activeCard != null ) {
              setState(() {
                activeCard = null;
              });
            } else {
              //backAction(context);
              widget._onReturn();
            }
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
        child: activeCard != null
            ? PageAdminEditCard(_creator.nav(), PokeCardViewerIdentifier(expansion, activeCard!, specificLanguage: language), options)
            : LayoutBuilder(builder: (context, box) {
            if( box.maxWidth > 600 ) {
              return desktopView(box);
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