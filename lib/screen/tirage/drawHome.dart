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
      return LanguagePage(afterSelected: goToProductPage);
    } else {
      Function refresh = (String message) {
        setState( () { this.message = message;} );
      };
      String bullet = String.fromCharCode(0x2022);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center( child: Text('Connexion', style: Theme.of(context).textTheme.headline1,),),
          SizedBox(height: 20.0,),
          Container(
            child: signInButton(refresh)
          ),
          if(message != null) Container( child: Center( child: Text(message, style: TextStyle(color: Colors.red)))),
          Expanded(child: SizedBox()),
          Container( padding: const EdgeInsets.only(left: 10),
            child: Column(
                children: [
                  Text('En vous connectant, vous acceptez :\n$bullet la sauvegarde de votre UID dans notre base de données.',
                    style: TextStyle(fontSize: 16.0),),
                ]),
          ),
          SizedBox(height: 10.0,),
        ],
      );
    }
  }

  void goToProductPage(BuildContext context, Language language, SubExtension subExt) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(language: language, subExt: subExt) ));
  }
}