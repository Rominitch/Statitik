import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/screen/widgets/NewsDialog.dart';
import 'package:statitikcard/services/News.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  String? message;
  late CustomRadioController langueController = CustomRadioController(onChange: (value) { refreshLocale(value); });

  void refreshLocale(String language) {
    setState((){
      StatitikLocale.of(context).setLocale(Locale(language));
    });
  }

  @override
  Widget build(BuildContext context) {
    langueController.currentValue = StatitikLocale.of(context).locale.languageCode;

    var refreshWithError = (String? message) {
      setState((){
        this.message = message;
      });
    };
    Function refresh = () {
      setState(() {});
    };

    Widget toolBarLanguage() {
      return Row( children: [
        Expanded(child: Text(StatitikLocale.of(context).read('L_T0'))),
        CustomRadio(value: "fr", controller: langueController, widget: Environment.instance.collection.languages[1].barIcon()),
        CustomRadio(value: "en", controller: langueController, widget: Environment.instance.collection.languages[2].barIcon()),
      ]);
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
        children: [
          // Profile Panel
          Card(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Text(StatitikLocale.of(context).read('O_B9'), style: Theme.of(context).textTheme.headline5)),
                  if(Environment.instance.isLogged())
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        signOutButton(refresh, context),
                        TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red[800], // background
                            ),
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
                      ]
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      signInButton('V_B5', CredentialMode.Google, refreshWithError, context),
                      signInButton('V_B6', CredentialMode.Phone, refreshWithError, context),
                    ],)
                ]
              )
            )
          ),
          // Options panel
          Card(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Text(StatitikLocale.of(context).read('H_T2'), style: Theme.of(context).textTheme.headline5)),
                toolBarLanguage(),
              ],
            ),
          )),
          Expanded(child: Center(child: drawImagePress(context, "PikaOption", 200.0))),
          Row(
            children: [
              Expanded(child: Card(
                child: TextButton(
                    onPressed: () {
                      var latestId = 0;
                      News.readFromDB(StatitikLocale
                          .of(context)
                          .locale, latestId).then((news) {
                        if (news.isNotEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return createNewDialog(context, news);
                              }
                          );
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        drawImagePress(context, 'news', 35),
                        SizedBox(width: 5),
                        Text(StatitikLocale.of(context).read('NE_T0'))
                    ])
                ),
              )),
              Expanded(child: Card(
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/support');
                    },
                    child: Text(StatitikLocale.of(context).read('O_B4'))
                ),
              )),
            ]
          ),
          Row(
            children: [
              Expanded(child: Card(
                child: TextButton(
                    onPressed: () {
                      Environment.instance.showDisclaimer(context);
                    },
                    child: Text(StatitikLocale.of(context).read('disclaimer_T0'))
                ),
              )),
              Expanded(child: Card(
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/thanks');
                    },
                    child: Text(StatitikLocale.of(context).read('O_B3'))
                ),
              )),
              Expanded(child: Card(
                child: TextButton(
                    onPressed: () {
                      Environment.instance.showAbout(context);
                    },
                    child: Text(StatitikLocale.of(context).read('O_B5'))
                ),
              )),
            ]
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
          child: TextButton( child: Text(StatitikLocale.of(context).read('confirm')),
          onPressed: (){
            Environment.instance.removeUser().whenComplete(() {
              Navigator.of(context).pop();
              setState(() {});
            });
          },),),
        Card(
          color: Theme.of(context).primaryColor,
          child: TextButton( child: Text(StatitikLocale.of(context).read('cancel')), onPressed: (){ Navigator.of(context).pop();},),),
      ],
    );
  }
}
