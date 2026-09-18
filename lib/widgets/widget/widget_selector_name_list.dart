import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card_subject.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';

import 'package:statitikcard/services/environment.dart';

class WidgetSelectorNameList extends StatefulWidget {
  final PokeNavAdmin _navAdmin;
  final SplayTreeMap<String, CardTitle> dataMap;
  final Function(String, PokeLanguage)? addNewData;

  WidgetSelectorNameList(PokeNavAdmin navAdmin, List nonOrderedDataMap, {multiLangue = false, this.addNewData, super.key}):
    _navAdmin = navAdmin,
    dataMap = _createMap(nonOrderedDataMap, navAdmin, multiLangue);

  static SplayTreeMap<String, CardTitle> _createMap(List nonOrderedDataMap, PokeNavAdmin navAdmin, bool multiLangue) {
    final newMap = SplayTreeMap<String, CardTitle>();
    for (final CardTitle title in nonOrderedDataMap) {
      List<String> allNames = [ title.name(navAdmin.showLanguage)! ];
      if( multiLangue ) {
        for( final l in navAdmin.collection.languages() ) {
          if( l != navAdmin.showLanguage) {
            allNames.add(title.name(navAdmin.showLanguage)!);
          }
        }
      }
      newMap[allNames.join(' / ')] = title;
    }
    return newMap;
  }

  @override
  State<WidgetSelectorNameList> createState() => _WidgetSelectorNameListState();
}

class _WidgetSelectorNameListState extends State<WidgetSelectorNameList> {
  final TextEditingController _controller = TextEditingController();

  Map<String, CardTitle> _filteredMap = {};

  void computeFilteredList() {
    if( _controller.text.isNotEmpty ) {
      _filteredMap.clear();

      for(final entry in widget.dataMap.entries)
      {
          if(entry.key.contains( _controller.text ) ) {
            _filteredMap[entry.key] = entry.value;
          }
      }
    } else {
      _filteredMap = Map.from(widget.dataMap);
    }
  }

  @override
  void initState() {
    computeFilteredList();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      labelText: AppLocalizations.of(context)!.ca_b5
                  ),
                  onChanged: (value) {
                    setState(() {
                      computeFilteredList();
                    });
                  },
                ),
              ),
              if( widget.addNewData != null && Environment.instance.isAdministrator())
                Card( child: IconButton(
                  icon: const Icon(Icons.add_circle_rounded),
                  onPressed: () {
                    // Add new text into db and refresh view
                    widget.addNewData!( _controller.text, widget._navAdmin.showLanguage ).then( (value) {
                      if( value != null) {
                        Navigator.pop(context, value);
                      }
                    });
                  },
                )
                )
            ]
          ),
          if(_filteredMap.isNotEmpty)
            Expanded(child: ListView.builder(
              itemCount: _filteredMap.length,
              itemBuilder: (context, index) {
                var entry = _filteredMap.entries.elementAt(index);
                return  Card(
                  margin: const EdgeInsets.all(2.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(entry.key),
                    onPressed: (){
                      Navigator.of(context).pop(entry.value);
                    },
                  ),
                );
              },
            )
            )
        ]
      )
    );
  }
}
