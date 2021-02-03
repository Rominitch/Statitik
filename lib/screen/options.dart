import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  String message;

  @override
  Widget build(BuildContext context) {
    Function refreshWithError = (message) {
      setState((){
        this.message = message;
      });
    };
    Function refresh = () {
      setState(() {});
    };

    List<Widget> buttons = [];
    if(Environment.instance.isLogged())
    {
      buttons = [
        signOutButton(refresh, context),
        Expanded(child: SizedBox()),
        FlatButton(
            color: Colors.red[800],
            onPressed: () {
              setState(()
              {
                showDialog(
                    context: context,
                    builder: (_) => forgetMeDialog()
                );
              });
            },
            child: Text(StatitikLocale.of(context).read('O_B0'))
        ),
        SizedBox(height: 10),
      ];

      if(Environment.instance.user.admin) {
        buttons += [
          FlatButton(
              onPressed: () {
                Environment.instance.startDB=false;
                Environment.instance.readStaticData();
              },
              child: Text(StatitikLocale.of(context).read('O_B1'))
          ),
          SizedBox(height: 10),
          CheckboxListTile(value: useDebug,
              title: Text(StatitikLocale.of(context).read('O_B2')),
              onChanged: (newValue) {
                setState(() {
                  useDebug = newValue;
                });
                Environment.instance.startDB=false;
                Environment.instance.db = Database();
                Environment.instance.readStaticData();

          }),
          SizedBox(height: 10),
        ];
      }

    } else {
      buttons = [
        signInButton(refreshWithError, context),
        Expanded(child: SizedBox()),
      ];
    }

    return Scaffold(
        appBar: AppBar(
        title: Center(
          child: Text( StatitikLocale.of(context).read('H_T2'), style: Theme.of(context).textTheme.headline3, ),
        ),
      ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons + <Widget>[
          Center(child: Image(image: AssetImage("assets/press/PikaOption.png"), height: 200.0)),
          Row(
            children: [
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Environment.instance.showDisclaimer(context);
                    },
                    child: Text(StatitikLocale.of(context).read('disclaimer_T0'))
                ),
              )),
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/thanks');
                    },
                    child: Text(StatitikLocale.of(context).read('O_B3'))
                ),
              )),
            ]
          ),
          Row(
            children: [
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/support');
                    },
                    child: Text(StatitikLocale.of(context).read('O_B4'))
                ),
              )),
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Environment.instance.showAbout(context);
                    },
                    child: Text(StatitikLocale.of(context).read('O_B5'))
                ),
              )),
            ],
          ),

        ],
      ),
    ),
    );
  }

  Widget forgetMeDialog() {
    return new AlertDialog(
      title: new Text(StatitikLocale.of(context).read('warning')),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
          [
            Text(StatitikLocale.of(context).read('O_B6')),
            Text(StatitikLocale.of(context).read('O_B7'), style: TextStyle(color: Colors.red[600])),
            Text(StatitikLocale.of(context).read('O_B8'))
          ]
      ),
      actions: [
        Card(
          color: Colors.red[600],
          child: FlatButton( child: Text(StatitikLocale.of(context).read('confirm')),
          onPressed: (){
            Environment.instance.removeUser().whenComplete(() {
              Navigator.of(context).pop();
              setState(() {});
            });
          },),),
        Card(
          color: Theme.of(context).primaryColor,
          child: FlatButton( child: Text(StatitikLocale.of(context).read('cancel')), onPressed: (){ Navigator.of(context).pop();},),),
      ],
    );
  }
}
