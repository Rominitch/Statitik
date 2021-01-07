import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    Function refresh = () {
      setState(() {});
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Options', style: Theme.of(context).textTheme.headline1,
          ),
        ),
        !Environment.instance.isLogged() ? signInButton(refresh) : signOutButton(refresh),
        Expanded(child: SizedBox()),
        /*
        FlatButton(
            onPressed: () {
              Environment.instance.startDB=false;
              Environment.instance.readStaticData();
            },
            child: Text('Actualiser la base de données')
        ),
         */
        FlatButton(
            onPressed: () {
              Environment.instance.showAbout(context);
            },
            child: Text('A propos')
        ),
      ],
    );
  }
}
