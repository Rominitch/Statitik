import 'package:flutter/material.dart';

import 'package:statitikcard/screen/languagePage.dart';
import 'package:statitikcard/screen/tirage/tirage_produit.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
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
          child: Text( StatitikLocale.of(context).read('H_T0'), style: Theme.of(context).textTheme.headline3, ),
         ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(StatitikLocale.of(context).read('DC_B0')),
                Expanded(child: SizedBox()),
                Image(image: AssetImage('assets/press/Zeraora.png')),
                Card( color: greenValid, child: FlatButton(child: Text(StatitikLocale.of(context).read('DC_B1'), style: TextStyle(color: Colors.grey[800]) ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage)));
                  },
                )),
                Expanded(child: SizedBox()),
                Text(StatitikLocale.of(context).read('DC_B2'), style: TextStyle( decoration: TextDecoration.underline, )),
                SizedBox(height: 8.0,),
                Row(children: [
                  Icon(Icons.help_outline),
                  SizedBox(width: 10.0),
                  Flexible(child: Text(StatitikLocale.of(context).read('DC_B3'))),]),
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
            child: Text( StatitikLocale.of(context).read('DC_B4'), style: Theme.of(context).textTheme.headline3, ),
          ),
        ),
        body:SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(StatitikLocale.of(context).read('DC_B5')),
              textBullet(StatitikLocale.of(context).read('DC_B6')),
              textBullet(StatitikLocale.of(context).read('DC_B7')),
              Expanded(child: SizedBox()),
              Container(
                child: signInButton(refresh, context)
              ),
              if(message != null) Container( child: Center( child: Text(message, style: TextStyle(color: Colors.red)))),
              Expanded(child: SizedBox()),
              Container( padding: const EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(StatitikLocale.of(context).read('DC_B8')),
                      textBullet(StatitikLocale.of(context).read('DC_B9')),
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