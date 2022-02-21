import 'package:flutter/material.dart';

import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/models.dart';

class CardNameSelector extends StatefulWidget {
  final Language language;
  const CardNameSelector(this.language);

  @override
  _CardNameSelectorState createState() => _CardNameSelectorState();
}

class _CardNameSelectorState extends State<CardNameSelector> {
  TextEditingController _controller = TextEditingController();
  late CustomRadioController cardController = CustomRadioController(
      onChange: (value)
      { setState(() {
        computeFilteredList();
      });
  });
  List _filterered = [];
  List pokemons = Environment.instance.collection.pokemons.values.toList();
  List others   = Environment.instance.collection.otherNames.values.toList();

  void computeFilteredList() {
    if( _controller.text.isNotEmpty ) {
      _filterered.clear();
      cardController.currentValue.forEach(
        (info) {
          if( info.name(widget.language).toLowerCase().contains(_controller.text.toLowerCase()) )
            _filterered.add(info);
        });
    } else {
      _filterered = List.from(cardController.currentValue);
    }
  }

  @override
  void initState() {
    cardController.currentValue = pokemons;

    others.sort( (a, b){ return a.name(widget.language).compareTo(b.name(widget.language)); } );

    computeFilteredList();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read('CA_T1'), style: Theme.of(context).textTheme.headline3, ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomRadio(value: pokemons, controller: cardController,
                    widget: Text(StatitikLocale.of(context).read('CA_B0'), style: Theme.of(context).textTheme.headline5)
                  ),
                ),
                Expanded(
                  child: CustomRadio(value: others, controller: cardController,
                    widget: Text(StatitikLocale.of(context).read('CA_B1'), style: Theme.of(context).textTheme.headline5)
                  ),
                )
              ]
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: StatitikLocale.of(context).read('CA_B5')
              ),
              onChanged: (value) {
                setState(() {
                  computeFilteredList();
                });
              },
            ),
            if(_filterered.isNotEmpty)
              Expanded(child: ListView.builder(
                  itemCount: _filterered.length,
                  itemBuilder: (context, id) {
                    var info = _filterered[id];
                    Color col = info.isPokemon() ? generationColor[info.generation] : Colors.grey;
                    return Container(
                      height: 40.0,
                      child: Card(
                        color: col,
                        child: TextButton(
                          child: Text(info.fullname(widget.language)),
                          onPressed: (){
                            Navigator.of(context).pop(info);
                          },
                        ),
                      )
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
