import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

enum CredentialMode
{
  google,
  phone,
  autoLog
}

class Credential
{
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

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

  void signInWithGoogle(onSuccess) {
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
    await googleSignIn.signOut();

    var prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
    prefs.remove('userID');
  }

  AlertDialog showAlert(BuildContext context) {
    String smsCode="";
    return AlertDialog(
      title: Text(StatitikLocale.of(context).read('LOG_1')),
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
          child: Text(StatitikLocale.of(context).read('confirm')),
          onPressed: () {
            Navigator.of(context).pop(smsCode);
          },
        ),
        TextButton(
          child: Text(StatitikLocale.of(context).read('cancel')),
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
      title: Text(StatitikLocale.of(context).read('LOG_6')),
      content:  TextField(
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            smsCode = value;
          },
          //controller: _text,
          decoration: InputDecoration(hintText: StatitikLocale.of(context).read('LOG_7'),
            hintStyle: const TextStyle(fontSize: 10),
            //errorText: _validate ? 'Value Can\'t Be Empty' : null
          )
      ),
      actions: <Widget>[
        TextButton(
          child: Text(StatitikLocale.of(context).read('confirm')),
          onPressed: () {
            //_validate = _text.text.isEmpty;
            if(smsCode.isNotEmpty) {
              Navigator.of(context).pop(smsCode);
            }
          },
        ),
        TextButton(
          child: Text(StatitikLocale.of(context).read('cancel')),
          onPressed: () {
            Navigator.of(context).pop("");
          },
        ),
      ],
    );
  }
}