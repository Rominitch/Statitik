import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';

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
        signOutButton(refresh),
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
            child: Text('Suppression du compte')
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
              child: Text('Actualiser la base de données')
          ),
          SizedBox(height: 10),
          CheckboxListTile(value: useDebug,
              title: Text('Mode debug'),
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
        signInButton(refreshWithError),
        Expanded(child: SizedBox()),
      ];
    }

    return Scaffold(
        appBar: AppBar(
        title: Center(
          child: Text( 'Options', style: Theme.of(context).textTheme.headline3, ),
        ),
      ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons + <Widget>[
          Row(
            children: [
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Environment.instance.showDisclaimer(context);
                    },
                    child: Text('Disclaimer')
                ),
              )),
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/thanks');
                    },
                    child: Text('Remerciement')
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
                    child: Text('Support')
                ),
              )),
              Expanded(child: Card(
                child: FlatButton(
                    onPressed: () {
                      Environment.instance.showAbout(context);
                    },
                    child: Text('A propos')
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
      title: new Text("Attention"),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
          [
            Text('Conformement à la réglementation en rigeur, vous avez le droit à l\'oubli.\n'),
            Text('La suppression de votre UID dans la base de données est irréversible, vous ne pourrez plus jamais accéder à vos tirages.\n', style: TextStyle(color: Colors.red[600])),
            Text('Voulez-vous supprimer votre compte ?\n')
          ]
      ),
      actions: [
        Card(
          color: Colors.red[600],
          child: FlatButton( child: Text("Confirmer"),
          onPressed: (){
            Environment.instance.removeUser().whenComplete(() {
              Navigator.of(context).pop();
              setState(() {});
            });
          },),),
        Card(
          color: Theme.of(context).primaryColor,
          child: FlatButton( child: Text("Annuler"), onPressed: (){ Navigator.of(context).pop();},),),
      ],
    );
  }
}
