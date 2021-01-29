import 'package:flutter/material.dart';

import 'package:statitikcard/screen/languagePage.dart';
import 'package:statitikcard/screen/tirage/tirage_produit.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class DrawHomePage extends StatefulWidget {
  @override
  _DrawHomePageState createState() => _DrawHomePageState();
}

class _DrawHomePageState extends State<DrawHomePage> {
  String message;

  @override
  Widget build(BuildContext context) {
    if( Environment.instance.isLogged() ) {
      return Scaffold(
          appBar: AppBar(
          title: Center(
          child: Text( 'Tirage', style: Theme.of(context).textTheme.headline3, ),
         ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Bienvenue sur l\'enregistrement des tirages.\n\nMerci de rentrer les informations les plus justes possibles afin d\'aider la communauté.'),
                Expanded(child: SizedBox()),
                Card( color: greenValid, child: FlatButton(child: Text('Commencer', style: TextStyle(color: Colors.grey[800]) ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage)));
                  },
                )),
                Expanded(child: SizedBox()),
                Text('Astuces:', style: TextStyle( decoration: TextDecoration.underline, )),
                SizedBox(height: 8.0,),
                Row(children: [
                  Icon(Icons.help_outline),
                  SizedBox(width: 10.0),
                  Flexible(child: Text('Le clique long vous offre plus d\'options pour vos cartes ou boosters !')),]),
              ]
            ),
          ),
        ),
      );
    } else {
      Function refresh = (String message) {
        setState( () { this.message = message;} );
      };
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text( 'Connexion', style: Theme.of(context).textTheme.headline3, ),
          ),
        ),
        body:SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('En vous connectant, vous pouvez:'),
              textBullet('Enregistrer vos tirages'),
              textBullet('Comparer vos statistiques avec celles de la communauté'),
              Expanded(child: SizedBox()),
              Container(
                child: signInButton(refresh)
              ),
              if(message != null) Container( child: Center( child: Text(message, style: TextStyle(color: Colors.red)))),
              Expanded(child: SizedBox()),
              Container( padding: const EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('En vous connectant, vous acceptez :'),
                      textBullet('la sauvegarde de votre UID dans notre base de données'),
                    ]),
              ),
              SizedBox(height: 10.0,),
            ],
            ),
          ),
        ),
      );
    }
  }

  void goToProductPage(BuildContext context, Language language, SubExtension subExt) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(language: language, subExt: subExt) ));
  }
}