import 'package:flutter/material.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'package:statitikcard/services/models/Deck.dart';

class PokeSpaceMyDecksCreator extends StatefulWidget {
  final Deck      deck;

  const PokeSpaceMyDecksCreator(this.deck, {Key? key}) : super(key: key);


  @override
  State<PokeSpaceMyDecksCreator> createState() => _PokeSpaceMyDecksCreatorState();
}

class _PokeSpaceMyDecksCreatorState extends State<PokeSpaceMyDecksCreator> {
  late TextEditingController nameController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.deck.name);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatitikLocale.of(context).read('PSMDC_T0'), style: Theme.of(context).textTheme.headline3),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(StatitikLocale.of(context).read('PSMDC_B0')),
                    TextField(
                      controller: nameController,
                      onSubmitted: (String value) {
                        widget.deck.name = value;
                      }
                    )
                  ]
                )
              ],
            )
        ),
      ),
    );
  }
}
