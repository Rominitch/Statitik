import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/tirage/DrawHistory.dart';
import 'package:statitikcard/screen/tirage/PokeSpaceMyCards.dart';
import 'package:statitikcard/screen/tirage/PokeSpaceSavedDraw.dart';
import 'package:statitikcard/screen/tirage/PokeSpaceDrawResume.dart';
import 'package:statitikcard/screen/tutorial/drawTuto.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/UserDrawFile.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';

class DrawHomePage extends StatefulWidget {
  @override
  _DrawHomePageState createState() => _DrawHomePageState();
}

class _DrawHomePageState extends State<DrawHomePage> {
  String? message;
  List<UserDrawFile> userDraw = [];

  Widget createButton( List<Widget> info, Function onpress, {color}) {
    return Card(
      color: color,
      child: TextButton(
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: info,
            )
        ),
        onPressed: () {
          onpress();
        }
      )
    );
  }

  Widget drawPanel() {
    var buttons = [
      createButton([
          Icon(Icons.add_box_outlined),
          Flexible(
            child: Text(StatitikLocale.of(context).read('DC_B1'),
                style: Theme.of(context).textTheme.headline6,
                softWrap: true, maxLines: 2),
          ),
        ], () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage, addMode: true)));
        },
        color: greenValid,
      ),
      createButton([
          Icon(Icons.info_outline),
          Text(StatitikLocale.of(context).read('DC_B10'),
              style: Theme.of(context).textTheme.headline5
          ),
        ], () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DrawTutorial()));
        }
      )
    ];
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                drawImagePress(context, 'Snorlax_Pikachu_Pose', 60.0),
                SizedBox(width: 15.0),
                Text(StatitikLocale.of(context).read('DC_B14'),
                    style: Theme.of(context).textTheme.headline4),
                SizedBox(width: 15.0),
                drawImagePress(context, 'Snorlax_Pikachu', 60.0),
              ],
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: buttons.length,
              children: buttons,
              primary: false,
              shrinkWrap: true,
              childAspectRatio: 2.5,
            ),
            if(userDraw.isNotEmpty)
              Card( child:
                TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history),
                      Text(StatitikLocale.of(context).read('DC_B19'), style: Theme.of(context).textTheme.headline5),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceSavedDraw(userDraw)));
                  },
                )
              ),
          ],
        ),
      ),
    );
  }

  Widget myProfilePanel() {
    var buttons = [
      createButton([
        Column(
          children: [
            Text(StatitikLocale.of(context).read('DC_B16'), style: Theme.of(context).textTheme.headline5),
            Text(StatitikLocale.of(context).read('devBeta'),style: TextStyle(fontSize: 10)),
          ],
        )
        ],(){
        if(Environment.instance.isLogged())
          Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceMyCards()));
      }),
      createButton([
        Column(
          children: [
            Text(StatitikLocale.of(context).read('DC_B17'),
                style: Theme.of(context).textTheme.headline5),
            Text(StatitikLocale.of(context).read('devSoon'),
                style: TextStyle(fontSize: 10)),
          ],
        )
      ],(){

      }, color: Colors.black54),
      createButton([
        Column(
          children: [
            Text(StatitikLocale.of(context).read('DC_B18'),
                style: Theme.of(context).textTheme.headline5),
            Text(StatitikLocale.of(context).read('devSoon'),
                style: TextStyle(fontSize: 10)),
          ],
        )
      ],(){

      }, color: Colors.black54),
      createButton([
        Text(StatitikLocale.of(context).read('DC_B11'), style: Theme.of(context).textTheme.headline5),
      ], () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DrawHistory()));
      }),
    ];

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.grey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      drawImagePress(context, 'CafeMix_Pikachu', 60.0),
                      SizedBox(width: 15.0),
                      Text(StatitikLocale.of(context).read('DC_B15'),
                          style: Theme.of(context).textTheme.headline4),
                      SizedBox(width: 15.0),
                      drawImagePress(context, 'Piplup', 60.0),
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    children: buttons,
                    primary: false,
                    shrinkWrap: true,
                    childAspectRatio: 2.5,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if( Environment.instance.isLogged() ) {
      // First time: go to tutorial
      SharedPreferences.getInstance().then((prefs) {
        var needTuto = prefs.getBool('TutorialDraw');
        if(needTuto == null || !needTuto)
        {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DrawTutorial()));
          // Save to preferences (never shown)
          prefs.setBool('TutorialDraw', true);
        }
      }).whenComplete(() {
        // Search local collection
        UserDrawCollection.readSavedDraws().then((value) {
          setState(() {
            userDraw = value;
          });
        });
      });

      return Scaffold(
          appBar: AppBar(
          title: Center(
          child: Text(StatitikLocale.of(context).read('H_T0'), style: Theme.of(context).textTheme.headline3),
         ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                drawPanel(),
                myProfilePanel(),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        drawImagePress(context, 'Zeraora', 300.0),
                      ]
                    )
                  )
                ),
                Padding(padding: const EdgeInsets.all(6.0),
                  child: Column(
                    children: [
                      Text(StatitikLocale.of(context).read('DC_B2'), style: TextStyle(fontSize: 13, decoration: TextDecoration.underline, )),
                      SizedBox(height: 8.0),
                      Row(children: [
                        Icon(Icons.help_outline),
                        SizedBox(width: 10.0),
                        Flexible(child: Text(StatitikLocale.of(context).read('DC_B3'), style: TextStyle(fontSize: 11))),
                      ])
                    ]
                  )
                ),
              ]
            ),
          ),
        ),
      );
    } else {
      var refresh = (String? message) {
        setState( () { this.message = message;} );
      };
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text( StatitikLocale.of(context).read('DC_B4'), style: Theme.of(context).textTheme.headline3 ),
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
                child: signInButton('V_B5', CredentialMode.Google, refresh, context)
              ),
              Container(
                child: signInButton('V_B6', CredentialMode.Phone, refresh, context)
              ),
              if(message != null) Container( child: Center( child: Text(message!, style: TextStyle(color: Colors.red)))),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.AllSelection, language: language, subExt: subExt, afterSelected: afterSelectProduct) ));
  }

  void afterSelectProduct(BuildContext context, Language language, ProductRequested? product, ProductCategory? category) {
    // Build new session of draw
    Environment.instance.currentDraw =
        SessionDraw(product!.product, language);
    // Go to page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PokeSpaceDrawResume())).then( (value)
    {
      setState(() {});
    });
  }
}