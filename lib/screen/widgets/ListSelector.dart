import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';

class ListSelector extends StatefulWidget {
  final Widget   title;
  final Language language;
  final SplayTreeMap dataMap;
  final bool multiLangue;
  final Function(String, int)? addNewData;

  ListSelector(this.title, this.language, nonOrderedDataMap, {this.multiLangue = false, this.addNewData, Key? key}) :
    dataMap = SplayTreeMap.from(nonOrderedDataMap,
            (key1, key2) {
              assert(nonOrderedDataMap[key1] != null, "Impossible to find: $key1");
              assert(nonOrderedDataMap[key2] != null, "Impossible to find: $key2");
              final String s1 = nonOrderedDataMap[key1].name(language);
              final String s2 = nonOrderedDataMap[key2].name(language);
              return s1.compareTo(s2);
            }),
    super(key: key);

  @override
  State<ListSelector> createState() => _ListSelectorState();
}

class _ListSelectorState extends State<ListSelector> {
  final TextEditingController _controller = TextEditingController();

  Map _filteredMap = {};

  void computeFilteredList() {
    if( _controller.text.isNotEmpty ) {
      _filteredMap.clear();

      widget.dataMap.forEach(
        (id, info) {
          if(info.search( widget.multiLangue ? null : widget.language, _controller.text ) ) {
            _filteredMap[id] = info;
          }
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
        title: widget.title,
      ),
      body: SafeArea(
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
                      labelText: StatitikLocale.of(context).read('CA_B5')
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
                        widget.addNewData!( _controller.text, widget.language.id ).then( (value) {
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
                  itemBuilder: (context, id) {
                    var idDB = _filteredMap.keys.toList()[id];
                    var info = _filteredMap.values.toList()[id];
                    return  Card(
                      margin: const EdgeInsets.all(2.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
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
