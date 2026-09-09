import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/admin/admin_card_creator.dart';
import 'package:statitikcard/models/admin/admin_html_card_parser.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/tools.dart';

class WidgetCreatorCardQuick extends StatefulWidget {
  final PokeNavAdmin          _navAdmin;
  final AdminCardCreator      _creator;

  final Function(int listId, int?)?   onAppendCard;
  final Function(int listId)?         onChangeList;
  final Function()?                   onNeedRefresh;
  // Computed
  final List<PokeRarity>      listRarity;
  final CardEditorOptions     options;

  WidgetCreatorCardQuick(this._navAdmin, this._creator, this.onAppendCard, this.onNeedRefresh, {super.key, this.onChangeList}):
        listRarity = (_creator.expansion.location() == CardLocation.Monde ? _navAdmin.collection.worldRarity() : _navAdmin.collection.japanRarity()),
        options = CardEditorOptions();

  @override
  State<WidgetCreatorCardQuick> createState() => _WidgetCreatorCardQuickState();
}

class _WidgetCreatorCardQuickState extends State<WidgetCreatorCardQuick> with TickerProviderStateMixin {
  late CustomRadioController typeController = CustomRadioController(
      onChange: (value) {
        onTypeChanged(value);
      });
  late CustomRadioController rarityController = CustomRadioController(
      onChange: (value) {
        onRarityChanged(value);
      });
  late CustomRadioController listChooserController = CustomRadioController(
      onChange: (value) {
        onChangeList(value);
      });

  late TabController tabController;

  final specialIDController = TextEditingController();

  bool _auto = false;

  bool isJapanese() {
    return widget._creator.expansion.location() == CardLocation.Asie;
  }

  void onChangeList(int value) {
    widget.onChangeList!(value);
  }

  void onTypeChanged(TypeCard value) {
    widget._creator.type = value;
  }

  void onRarityChanged(PokeRarity value) {
    widget._creator.rarity = value;
    if (_auto) {
      widget.onAppendCard!(listChooserController.currentValue, null);
    }
  }

  @override
  void initState() {
    typeController.afterPress(widget._creator.type);
    rarityController.afterPress(widget._creator.rarity);

    tabController = TabController(
        length: 6, vsync: this, initialIndex: widget.options.tabIndex);
    tabController.addListener(() {
      widget.options.tabIndex = tabController.index;
    });

    listChooserController.currentValue = 0;

    super.initState();
  }

  Future<void> fillEffects([bool forceRefill=false]) async {
    double count = 0.0;

    final parser = AdminHtmlCardParser(widget._navAdmin);

    for(var cardsList in widget._creator.expansion.cards.cards) {
      EasyLoading.showProgress(count / widget._creator.expansion.cards.cards.length, status: "$count / ${widget._creator.expansion.cards.cards.length}");

      for(var card in cardsList) {
        if(card.card.cardEffects.effects.isEmpty || forceRefill) {
          await parser.readEffectsJP(card);
        }
      }
      count += 1.0;
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Card( child: Column(children: [
      Card(
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.05),
            primary: false,
            shrinkWrap: true,
            itemCount: TypeCard.values.length,
            itemBuilder: (BuildContext context, int index) {
              var element = TypeCard.values.elementAt(index);
              return CustomRadio(value: element, controller: typeController, widget: getImageType(element));
            }
        ),
      ),
      Card(
        child: LayoutBuilder(builder: (context, box){
          final count = (box.maxWidth / 70).ceil();
          return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.3),
              itemCount: widget.listRarity.length,
              primary: false,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                var element = widget.listRarity.elementAt(index);
                return CustomRadio(value: element, controller: rarityController,
                    widget: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: widget._navAdmin.rendering.imageRarity(element, textureSize: null, fontSize: 8.0, generate: true)
                    )
                );
              }
          );
        }),
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRadio(value: 0, controller: listChooserController, widget: const Text("Normal")),
            CustomRadio(value: 1, controller: listChooserController, widget: const Text("Energie")),
            CustomRadio(value: 2, controller: listChooserController, widget: const Text("Special")),
          ]
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                color: Colors.grey[800],
                child: TextButton(
                  child: const Icon(Icons.add_circle_outline),
                  onPressed: (){
                    widget.onAppendCard!(listChooserController.currentValue, null);
                  },
                )
            ),
            Card(
                color: _auto ? Colors.green : Colors.grey[800],
                child: TextButton(
                    child: Text(AppLocalizations.of(context)!.nce_b2),
                    onPressed: () {
                      setState((){
                        _auto = !_auto;
                      });
                    }
                )
            ),
            if( isJapanese() ) Card(
                color: Colors.grey[800],
                child: TextButton(
                    child: Column(
                      children: [
                        const Icon(Icons.format_color_fill),
                        Text(AppLocalizations.of(context)!.nce_b9, style: const TextStyle(fontSize: 8.0))
                      ],
                    ),
                    onPressed: () {
                      EasyLoading.show();
                      fillEffects().then((value) {
                        EasyLoading.dismiss();
                        if(widget.onNeedRefresh != null) {
                          EasyLoading.dismiss();
                          widget.onNeedRefresh!();
                        }
                      }).onError((error, stackTrace) {
                        printOutput("$error - ${stackTrace.toString()}");
                        EasyLoading.dismiss();
                      });
                    }
                )
            ),
          ]
        ),
      ]
      )
    );
  }
}