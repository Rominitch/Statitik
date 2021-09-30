import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class ListSelector extends StatefulWidget {
  final String titleCode;
  final Language language;
  final SplayTreeMap dataMap;
  final bool multiLangue;
  //late String Function (dynamic) printValue;

  ListSelector(this.titleCode, this.language, nonOrderedDataMap, [this.multiLangue = false]) :
    dataMap = SplayTreeMap.from(nonOrderedDataMap,
            (key1, key2) => nonOrderedDataMap[key1].name(language).compareTo(nonOrderedDataMap[key2].name(language)));

  @override
  _ListSelectorState createState() => _ListSelectorState();
}

class _ListSelectorState extends State<ListSelector> {
  TextEditingController _controller = TextEditingController();

  Map _filteredMap = {};

  void computeFilteredList() {
    if( _controller.text.isNotEmpty ) {
      _filteredMap.clear();

      widget.dataMap.forEach(
        (id, info) {
          if(info.search( widget.multiLangue ? null : widget.language, _controller.text ) )
            _filteredMap[id] = info;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read(widget.titleCode), style: Theme.of(context).textTheme.headline3, ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white),
                labelText: StatitikLocale.of(context).read('CA_B5')
              ),
              onChanged: (value) {
                setState(() {
                  computeFilteredList();
                });
              },
            ),
            if(_filteredMap.isNotEmpty)
              Expanded(child: ListView.builder(
                  itemCount: _filteredMap.length,
                  itemBuilder: (context, id) {
                    var idDB = _filteredMap.keys.toList()[id];
                    var info = _filteredMap.values.toList()[id];
                    return  Card(
                      margin: EdgeInsets.all(2.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: widget.multiLangue ? Text(info.defaultName(' / ')) : Text(info.name(widget.language)),
                        onPressed: (){
                          Navigator.of(context).pop(idDB);
                        },
                      ),
                    );
                  },
                )
              )
          ]
        )
      )
    );
  }
}
