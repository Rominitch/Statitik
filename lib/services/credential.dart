import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:googleapis/people/v1.dart' as people;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';

import '../secrets/googleAPI.dart';

enum CredentialMode
{
  google,
  phone,
  autoLog
}

class Credential
{
  final _googleSignIn = GoogleSignIn(
    params: const GoogleSignInParams(
      clientId: Secret.googleAPIClientID,
      clientSecret: Secret.googleAPIClientSecret,
      scopes: ['openid', 'email'
        //'https://www.googleapis.com/auth/userinfo.profile',
        //'https://www.googleapis.com/auth/userinfo.email',
        //'openid', 'profile', 'email'
      ],
    ),
  );
  /*
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );
  */
  static bool hasPhoneLogin() {
    return false;
  }

  Future<void> initialize() async
  {
    try {
      // Auto login
      var prefs = await SharedPreferences.getInstance();
      if( prefs.getString('userID') != null ) {
        Environment.instance.login(CredentialMode.autoLog, null);
      }
      printOutput("User created");
    } catch(e) {
      Environment.instance.user = null;
    }
  }

  // Try to connect silently
  Future<GoogleSignInCredentials?> seamlessAuthentication() async {
    // 1. Try silent first (no user interaction)
    final silentCreds = await _googleSignIn.silentSignIn();
    if (silentCreds != null) return silentCreds;

    // 2. Try lightweight (minimal interaction)
    final lightCreds = await _googleSignIn.lightweightSignIn();
    if (lightCreds != null) return lightCreds;

    // 3. Fallback to full flow (complete OAuth)
    return await _googleSignIn.signInOnline();
  }

  void signInWithGoogle(onSuccess) {
    void afterConnexion(GoogleSignInCredentials? cred)
    {
      _googleSignIn.authenticatedClient.then( (authClient) async
      {
        if (authClient == null) {
          throw Exception('Failed to get authenticated client');
        }

        final response = await authClient.read(Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'));

        final email = RegExp(r'"email":\s*"([^"]+)"')
            .firstMatch(response)
            ?.group(1);
        final userId = RegExp(r'"id":\s*"([^"]+)"')
            .firstMatch(response)
            ?.group(1);

        if( email == null || userId == null )
        {
          throw Exception('Failed to get authenticated client');
        }

        final newId = "google-$userId";
        // Finish connection
        onSuccess(newId, newId, email.contains("cloudtestlabaccounts"));
      });
    }
    seamlessAuthentication().then( (GoogleSignInCredentials? authClient)
    {
      // If not possible, we start sign in
      if (authClient == null) {
        _googleSignIn.lightweightSignIn().then( afterConnexion );
      } else {
        afterConnexion (authClient);
      }
    });

    /*
    googleSignIn.signIn().then((GoogleSignInAccount? googleSignInAccount) {
      if(googleSignInAccount != null) {
        // Get Authentification data
        googleSignInAccount.authentication.then((GoogleSignInAuthentication googleSignInAuthentication) {
          final newId = "google-${googleSignInAccount.id}";
          // Finish connection
          onSuccess(newId, newId,
                    googleSignInAccount.email.contains("cloudtestlabaccounts"));
        });
      }
    });
    */
  }

  Future<void> signInWithPhone(BuildContext? context, onError, onSuccess) async {
    readMobileSIMInfo(context, onError, onSuccess);
  }

  Future<void> readMobileSIMInfo(BuildContext? context, onError, onSuccess) async {
    // Platform messages may fail, so we use a try/catch PlatformException.
      var simCards = [
        []
      ];

      showDialog(
          context: context!,
          barrierDismissible: false,
          // user must tap button!
          builder: (BuildContext context) {
            return Column(
                children: [
                  ListView.builder(
                      itemBuilder: (context, id){
                        var sim = simCards[id];
                        return TextButton(
                            onPressed: () {

                            },
                            child: Text("${sim[0]} - ${sim[1]}")
                        );
                      })
                ]
            );
          }
      );
  }

  Future<void> signOutGoogle() async {
    Environment.instance.user = null;
    await _googleSignIn.signOut();
    //await googleSignIn.signOut();

    var prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    prefs.remove('userID');
  }

  AlertDialog showAlert(BuildContext context) {
    String smsCode="";
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.log_1),
      content:  TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          smsCode = value;
        },
        //controller: _textFieldController,
        decoration: const InputDecoration(hintText: "Sms code"),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.confirm),
          onPressed: () {
            Navigator.of(context).pop(smsCode);
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.of(context).pop("");
          },
        ),
      ],
    );
  }

  AlertDialog enterPhone(BuildContext context) {
    //final _text = TextEditingController();
    //bool _validate = false;

    String smsCode="";
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.log_6),
      content:  TextField(
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            smsCode = value;
          },
          //controller: _text,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.log_7,
            hintStyle: const TextStyle(fontSize: 10),
            //errorText: _validate ? 'Value Can\'t Be Empty' : null
          )
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.confirm),
          onPressed: () {
            //_validate = _text.text.isEmpty;
            if(smsCode.isNotEmpty) {
              Navigator.of(context).pop(smsCode);
            }
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.of(context).pop("");
          },
        ),
      ],
    );
  }
}