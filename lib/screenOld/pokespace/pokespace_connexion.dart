import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/PokeSpace/pokespace_my_decks.dart';
import 'package:statitikcard/screenOld/commonPages/language_page.dart';
import 'package:statitikcard/screenOld/commonPages/product_page.dart';
import 'package:statitikcard/screenOld/PokeSpace/draw_history.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_my_cards.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_my_product.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_saved_draw.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_draw_resume.dart';
import 'package:statitikcard/screenOld/tutorial/tutorial_draw.dart';
import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/screenOld/widgets/gradient_button.dart';

import 'package:statitikcard/services/draw/session_draw.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/user_draw_file.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';

class DrawHomePage extends StatefulWidget {
  const DrawHomePage({super.key});

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
            child: Text(AppLocalizations.of(context)!.dc_b1,
                style: Theme.of(context).textTheme.titleLarge,
                softWrap: true, maxLines: 2),
          ),
        ], () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: goToProductPage, addMode: true)));
        },
        color: greenValid,
      ),
      createButton([
          const Icon(Icons.info_outline),
          Text(AppLocalizations.of(context)!.dc_b10,
              style: Theme.of(context).textTheme.headlineSmall
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
                Text(AppLocalizations.of(context)!.dc_b14,
                    style: Theme.of(context).textTheme.headlineMedium),
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
                      Text(AppLocalizations.of(context)!.dc_b19, style: Theme.of(context).textTheme.headlineSmall),
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
        Text(AppLocalizations.of(context)!.dc_b16,
          style: Theme.of(context).textTheme.headlineSmall)
        ],(){
        if(Environment.instance.isLogged()) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PokeSpaceMyCards()));
        }
      },
        color: cardMenuColor
      ),
      createButtonGradient([
        Text(AppLocalizations.of(context)!.dc_b17,
          style: Theme.of(context).textTheme.headlineSmall),
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
            Text(AppLocalizations.of(context)!.dc_b18,
              style: Theme.of(context).textTheme.headlineSmall),
            Text(AppLocalizations.of(context)!.devBeta, style: TextStyle(color: Colors.grey.shade300, fontSize: 12.0)),
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
        Text(AppLocalizations.of(context)!.dc_b11, style: Theme.of(context).textTheme.headlineSmall),
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
                      Text(AppLocalizations.of(context)!.dc_b15,
                          style: Theme.of(context).textTheme.headlineMedium),
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
          child: Text(AppLocalizations.of(context)!.h_t0, style: Theme.of(context).textTheme.displaySmall),
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
                      Text(AppLocalizations.of(context)!.dc_b2, style: const TextStyle(fontSize: 13, decoration: TextDecoration.underline, )),
                      const SizedBox(height: 8.0),
                      Row(children: [
                        const Icon(Icons.help_outline),
                        const SizedBox(width: 10.0),
                        Flexible(child: Text(AppLocalizations.of(context)!.dc_b3, style: const TextStyle(fontSize: 11))),
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
            child: Text( AppLocalizations.of(context)!.h_t0, style: Theme.of(context).textTheme.displaySmall ),
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
                  Text(AppLocalizations.of(context)!.dc_b4, style: Theme.of(context).textTheme.displaySmall),
                ]
              ),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.dc_b5),
              textBullet(AppLocalizations.of(context)!.dc_b6),
              textBullet(AppLocalizations.of(context)!.dc_b7),
              textBullet(AppLocalizations.of(context)!.dc_b21),
              textBullet(AppLocalizations.of(context)!.dc_b22),
              const SizedBox(height: 30),
              Container(
                child: signInButton('v_b5', CredentialMode.google, refreshWithError, refresh, context)
              ),
              if(Credential.hasPhoneLogin())
                Container(
                  child: signInButton('v_b6', CredentialMode.phone, refreshWithError, refresh, context)
                ),
              const SizedBox(height: 30),
              if(message != null) Center( child: Text(message!, style: const TextStyle(color: Colors.red))),
              Expanded(child: drawImagePress(context, 'PikaIntro', 300)),
              Container( padding: const EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppLocalizations.of(context)!.dc_b8),
                      textBullet(AppLocalizations.of(context)!.dc_b9),
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

  void goToProductPage(BuildContext context, LanguageOld language, SubExtension subExt) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(mode: ProductPageMode.allSelection, language: language, subExt: subExt, afterSelected: afterSelectProduct) ));
  }

  void afterSelectProduct(BuildContext context, LanguageOld language, ProductRequested? product, ProductCategory? category) {
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