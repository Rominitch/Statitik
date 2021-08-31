import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/screen/Admin/newCardExtensions.dart';
import 'package:statitikcard/screen/Admin/newProduct.dart';

import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/commonPages/productPage.dart';
import 'package:statitikcard/screen/tirage/DrawHistory.dart';
import 'package:statitikcard/screen/tirage/tirage_resume.dart';
import 'package:statitikcard/screen/tutorial/drawTuto.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class DrawHomePage extends StatefulWidget {
  @override
  _DrawHomePageState createState() => _DrawHomePageState();
}

class _DrawHomePageState extends State<DrawHomePage> {
  String? message;

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
      });

      return Scaffold(
          appBar: AppBar(
          title: Center(
          child: Text( StatitikLocale.of(context).read('H_T0'), style: Theme.of(context).textTheme.headline3, ),
         ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(StatitikLocale.of(context).read('DC_B0')),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Card( color: greenValid, 
                            child: TextButton(child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_box_outlined),
                                Text(StatitikLocale.of(context).read('DC_B1'), softWrap: true, maxLines: 2, ),
                                SizedBox(width: 15.0),
                                drawImagePress(context, 'Snorlax_Pikachu_Pose', 40.0),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage)));
                            }
                          )
                        ),
                      ),
                      Card( child: TextButton(child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline),
                          Text(StatitikLocale.of(context).read('DC_B10') ),
                          SizedBox(width: 15.0),
                          drawImagePress(context, 'Snorlax_Pikachu', 40.0),
                        ],
                      ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DrawTutorial()));
                        },
                      )),
                    ],
                  ),

                  Card( child: TextButton(child: Center(child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      drawImagePress(context, 'CafeMix_Pikachu', 40.0),
                      SizedBox(width: 15.0),
                      Icon(Icons.history),
                      Text(StatitikLocale.of(context).read('DC_B11') ),
                      SizedBox(width: 15.0),
                      drawImagePress(context, 'Piplup', 40.0),
                    ],
                  )),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DrawHistory()));
                    },
                  )),
                  drawImagePress(context, 'Zeraora', 370.0),
                  Text(StatitikLocale.of(context).read('DC_B2'), style: TextStyle(fontSize: 13, decoration: TextDecoration.underline, )),
                  SizedBox(height: 8.0,),
                  Row(children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 10.0),
                    Flexible(child: Text(StatitikLocale.of(context).read('DC_B3'), style: TextStyle(fontSize: 11))),]),
                    if(Environment.instance.user!.admin)
                      Card(
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(StatitikLocale.of(context).read('DC_B13')),
                          CircleAvatar(
                            backgroundColor: Colors.lightGreen,
                            radius: 20,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.add_shopping_cart),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => NewProductPage()));
                              },
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            radius: 20,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.post_add_outlined),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => NewCardExtensions()));
                              },
                            ),
                          ),
                          CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 20,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.remove_red_eye_rounded),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DrawHistory(true)));
                                },
                          )),
                          CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 20,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.refresh),
                                color: Colors.white,
                                onPressed: () {
                                  if(imageCache!=null) imageCache!.clear();
                                },
                              )),
                        ]),
                      )
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.SingleSelection, language: language, subExt: subExt, afterSelected: afterSelectProduct) ));
  }

  void afterSelectProduct(BuildContext context, Language language, Product? product, int categorie) {
    // Build new session of draw
    Environment.instance.currentDraw =
        SessionDraw(product: product!, language: language);
    // Go to page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ResumePage()));
  }
}