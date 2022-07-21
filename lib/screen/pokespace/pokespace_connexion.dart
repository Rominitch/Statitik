import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_my_decks.dart';

import 'package:statitikcard/screen/commonPages/language_page.dart';
import 'package:statitikcard/screen/commonPages/product_page.dart';
import 'package:statitikcard/screen/PokeSpace/draw_history.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_my_cards.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_my_product.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_saved_draw.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_draw_resume.dart';
import 'package:statitikcard/screen/tutorial/tutorial_draw.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/gradient_button.dart';
import 'package:statitikcard/services/draw/session_draw.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/user_draw_file.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';

class DrawHomePage extends StatefulWidget {
  const DrawHomePage({Key? key}) : super(key: key);

  @override
  State<DrawHomePage> createState() => _DrawHomePageState();
}

class _DrawHomePageState extends State<DrawHomePage> {
  String? message;
  List<UserDrawFile> userDraw = [];

  Widget createButton( List<Widget> info, Function() onpress, {color}) {
    return Card(
      color: color,
      child: TextButton(
        onPressed: onpress,
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: info,
            )
        )
      )
    );
  }
  Widget createButtonGradient( List<Widget> info, Function() onpress, {color}) {
    return GradientButton(
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: info,
        )
      ),
      onpress,
      gradient:
        RadialGradient(center: const Alignment(0.0, 7.0),
        radius: 5.0,
        colors: [color, Colors.grey.shade700, Colors.grey.shade800],
        stops: const [0.5, 0.75, 1.0],
      ),
    );
  }

  Widget drawPanel() {
    var buttons = [
      createButton([
          const Icon(Icons.add_box_outlined),
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
          const Icon(Icons.info_outline),
          Text(StatitikLocale.of(context).read('DC_B10'),
              style: Theme.of(context).textTheme.headline5
          ),
        ], () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawTutorial()));
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
                const SizedBox(width: 15.0),
                Text(StatitikLocale.of(context).read('DC_B14'),
                    style: Theme.of(context).textTheme.headline4),
                const SizedBox(width: 15.0),
                drawImagePress(context, 'Snorlax_Pikachu', 60.0),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: buttons.length,
              primary: false,
              shrinkWrap: true,
              childAspectRatio: 2.5,
              children: buttons,
            ),
            if(userDraw.isNotEmpty)
              Card( child:
                TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history),
                      Text(StatitikLocale.of(context).read('DC_B19'), style: Theme.of(context).textTheme.headline5),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceSavedDraw(userDraw))).then((value) {
                      setState((){});
                    });
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
      createButtonGradient([
        Text(StatitikLocale.of(context).read('DC_B16'),
          style: Theme.of(context).textTheme.headline5)
        ],(){
        if(Environment.instance.isLogged()) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PokeSpaceMyCards()));
        }
      },
        color: cardMenuColor
      ),
      createButtonGradient([
        Text(StatitikLocale.of(context).read('DC_B17'),
          style: Theme.of(context).textTheme.headline5),
        ],(){
        if(Environment.instance.isLogged()) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PokeSpaceMyProducts()));
        }
      },
        color: productMenuColor
      ),
      createButtonGradient([
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(StatitikLocale.of(context).read('DC_B18'),
              style: Theme.of(context).textTheme.headline5),
            Text(StatitikLocale.of(context).read('devBeta'), style: TextStyle(color: Colors.grey.shade300, fontSize: 12.0)),
          ]
        )
      ],(){
        if(Environment.instance.isLogged()) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PokeSpaceMyDeck()));
        }
      },
        color: deckMenuColor
      ),
      createButton([
        Text(StatitikLocale.of(context).read('DC_B11'), style: Theme.of(context).textTheme.headline5),
      ], () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawHistory()));
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
                      const SizedBox(width: 15.0),
                      Text(StatitikLocale.of(context).read('DC_B15'),
                          style: Theme.of(context).textTheme.headline4),
                      const SizedBox(width: 15.0),
                      drawImagePress(context, 'Piplup', 60.0),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    primary: false,
                    shrinkWrap: true,
                    childAspectRatio: 2.5,
                    children: buttons,
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawTutorial()));
          // Save to preferences (never shown)
          prefs.setBool('TutorialDraw', true);
        }
      }).whenComplete(() {
        // Search local collection
        UserDrawCollection.readSavedDraws().then((value) {
          // WARNING: avoid infinite loop
          if(userDraw.length != value.length) {
            setState(() {
              userDraw = value;
            });
          }
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
                      Text(StatitikLocale.of(context).read('DC_B2'), style: const TextStyle(fontSize: 13, decoration: TextDecoration.underline, )),
                      const SizedBox(height: 8.0),
                      Row(children: [
                        const Icon(Icons.help_outline),
                        const SizedBox(width: 10.0),
                        Flexible(child: Text(StatitikLocale.of(context).read('DC_B3'), style: const TextStyle(fontSize: 11))),
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
      refreshWithError(String message) {
        setState( () {
          this.message = message;
        } );
      }
      refresh() {
        setState( () {} );
      }
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text( StatitikLocale.of(context).read('H_T0'), style: Theme.of(context).textTheme.headline3 ),
          ),
        ),
        body:SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  drawImagePress(context, 'CafeMix_Pikachu', 50),
                  const SizedBox(width: 10),
                  Text(StatitikLocale.of(context).read('DC_B4'), style: Theme.of(context).textTheme.headline3),
                ]
              ),
              const SizedBox(height: 10),
              Text(StatitikLocale.of(context).read('DC_B5')),
              textBullet(StatitikLocale.of(context).read('DC_B6')),
              textBullet(StatitikLocale.of(context).read('DC_B7')),
              textBullet(StatitikLocale.of(context).read('DC_B21')),
              textBullet(StatitikLocale.of(context).read('DC_B22')),
              const SizedBox(height: 30),
              Container(
                child: signInButton('V_B5', CredentialMode.google, refreshWithError, refresh, context)
              ),
              Container(
                child: signInButton('V_B6', CredentialMode.phone, refreshWithError, refresh, context)
              ),
              const SizedBox(height: 30),
              if(message != null) Center( child: Text(message!, style: const TextStyle(color: Colors.red))),
              Expanded(child: drawImagePress(context, 'PikaIntro', 300)),
              Container( padding: const EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(StatitikLocale.of(context).read('DC_B8')),
                      textBullet(StatitikLocale.of(context).read('DC_B9')),
                    ]),
              ),
              const SizedBox(height: 10.0,),
            ],
            ),
          ),
        ),
      );
    }
  }

  void goToProductPage(BuildContext context, Language language, SubExtension subExt) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.allSelection, language: language, subExt: subExt, afterSelected: afterSelectProduct) ));
  }

  void afterSelectProduct(BuildContext context, Language language, ProductRequested? product, ProductCategory? category) {
    // Build new session of draw
    Environment.instance.currentDraw =
        SessionDraw(product!.product, language);
    // Go to page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PokeSpaceDrawResume())).then( (value)
    {
      setState(() {

      });
    });
  }
}