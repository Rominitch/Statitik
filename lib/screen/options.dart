import 'package:flutter/material.dart';
import 'package:statitik_pokemon/services/environment.dart';

class OptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Options'
        ),
        FlatButton(
            onPressed: () {
              Environment.instance.startDB=false;
              Environment.instance.readStaticData();
            },
            child: Text('Actualiser')
        ),
        FlatButton(
            onPressed: () {
              Environment.instance.showAbout(context);
            },
            child: Text('Info')
        ),
      ],
    );
  }
}
