import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_language.dart';

import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/screenOld/widgets/news_dialog.dart';
import 'package:statitikcard/services/news.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage>  createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  late CustomRadioController langueController = CustomRadioController(onChange: (value) { refreshLocale(value); });

  StreamController sizeControler = StreamController();
  double? moSize;
  bool isScreenOn=false;

  @override
  void initState() {
    sizeControler.stream.listen((event) async {
      int size = await Environment.instance.storage.storageSize();
      moSize = size.toDouble() / 1024.0 / 1024.0;
      if(!sizeControler.isClosed) {
        setState(() {});
      }
    });

    WakelockPlus.enabled.then((value) => isScreenOn = value);

    sizeControler.add(0);

    super.initState();
  }

  @override
  void dispose() {
    sizeControler.close();

    super.dispose();
  }

  void refreshLocale(String language) {
    setState((){
      Environment.instance.onChangeLocale.add(Locale(language));
      //Environment.instance.locale = Locale(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    langueController.currentValue = Localizations.localeOf(context).languageCode;

    refreshWithError(String message) {
      EasyLoading.showError(message, dismissOnTap: true);
    }
    refresh() {
      setState(() {});
    }

    Widget toolBarLanguage() {
      return Row( children: [
        Expanded(child: Text(AppLocalizations.of(context)!.l_t0)),
        CustomRadio(value: "fr", controller: langueController, widget: Environment.instance.pkCollection().language(Language.fr).barIcon(Environment.heightLanguage)),
        CustomRadio(value: "en", controller: langueController, widget: Environment.instance.pkCollection().language(Language.en).barIcon(Environment.heightLanguage)),
      ]);
    }

    return Scaffold(
        appBar: AppBar(
        title: Center(
          child: Text( AppLocalizations.of(context)!.h_t2, style: Theme.of(context).textTheme.displaySmall ),
        ),
      ),
    body: SafeArea(
      child: Padding(
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
                    Center(child: Text(AppLocalizations.of(context)!.o_b9, style: Theme.of(context).textTheme.headlineSmall)),
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
                              child: Text(AppLocalizations.of(context)!.o_b0)
                          ),
                        ]
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        signInButton(AppLocalizations.of(context)!.v_b5, CredentialMode.google, refreshWithError, refresh, context),
                        if(Credential.hasPhoneLogin())
                          signInButton(AppLocalizations.of(context)!.v_b6, CredentialMode.phone, refreshWithError, refresh, context),
                      ],)
                  ]
                )
              )
            ),
            // Options panel
            Card(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Text(AppLocalizations.of(context)!.h_t2, style: Theme.of(context).textTheme.headlineSmall)),
                  toolBarLanguage(),
                  Row( children: [
                    Checkbox(value: isScreenOn,
                      onChanged: (newValue) {
                        setState(() {
                          isScreenOn = newValue ?? false;
                          Environment.instance.setScreenOn(isScreenOn);
                        });
                      }
                    ),
                    Expanded(child:
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context)!.o_b13),
                          Flexible(child: Text(AppLocalizations.of(context)!.o_b14, softWrap: true, textAlign: TextAlign.left, style: const TextStyle(fontSize: 10))),
                      ])
                    ),
                    ]
                  ),
                  Row( children: [
                    Checkbox(value: Environment.instance.storeImageLocally,
                      onChanged: (newValue) {
                        Environment.instance.storeImageLocally = newValue!;
                        EasyLoading.show();

                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setBool("storeImageLocaly",
                              Environment.instance.storeImageLocally);
                        }).whenComplete(() {
                          Environment.instance.storage.clean().then((value) {
                            setState(() {
                              moSize = 0.0;
                            });
                            EasyLoading.dismiss();
                          });
                        });
                      }
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.o_b10),
                            Flexible(child: Text(AppLocalizations.of(context)!.o_b11, softWrap: true, textAlign: TextAlign.left, style: const TextStyle(fontSize: 10))),
                            if(Environment.instance.storeImageLocally)
                              (moSize != null) ? Text(sprintf(AppLocalizations.of(context)!.o_b12, [moSize]), textAlign: TextAlign.left, style: const TextStyle(fontSize: 10)) : CircularProgressIndicator(color: Colors.orange[300]),
                        ]),
                      ),
                    ],
                  ),
                ]
              )
            )),
            Expanded(child: Center(child: drawImagePress(context, "PikaOption", 200.0))),
            Row(
              children: [
                Expanded(child: Card(
                  child: TextButton(
                      onPressed: () {
                        var latestId = 0;
                        News.readFromDB(Localizations.localeOf(context), latestId).then((news) {
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
                          const SizedBox(width: 5),
                          Text(AppLocalizations.of(context)!.ne_t0)
                      ])
                  ),
                )),
                Expanded(child: Environment.instance.createDiscordButton() ),
              ]
            ),
            Row(
              children: [
                Expanded(child: Card(
                  child: TextButton(
                      onPressed: () {
                        Environment.instance.showDisclaimer(context);
                      },
                      child: Text(AppLocalizations.of(context)!.disclaimer_t0)
                  ),
                )),
                Expanded(child: Card(
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/thanks');
                      },
                      child: Text(AppLocalizations.of(context)!.o_b3)
                  ),
                )),
                Expanded(child: Card(
                  child: TextButton(
                      onPressed: () {
                        Environment.instance.showAbout(context);
                      },
                      child: Text(AppLocalizations.of(context)!.o_b5)
                  ),
                )),
              ]
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget forgetMeDialog() {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.warning),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
          [
            Text(AppLocalizations.of(context)!.o_b6),
            Text(AppLocalizations.of(context)!.o_b7, style: TextStyle(color: Colors.red[600])),
            Text(AppLocalizations.of(context)!.o_b8)
          ]
      ),
      actions: [
        Card(
          color: Colors.red[600],
          child: TextButton( child: Text(AppLocalizations.of(context)!.confirm),
          onPressed: (){
            Environment.instance.removeUser().whenComplete(() {
              Navigator.of(context).pop();
              setState(() {});
            });
          },),),
        Card(
          color: Theme.of(context).primaryColor,
          child: TextButton( child: Text(AppLocalizations.of(context)!.cancel), onPressed: (){ Navigator.of(context).pop();},),),
      ],
    );
  }
}
