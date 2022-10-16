import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:mobile_number/mobile_number.dart';
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
    FirebaseAuth auth = FirebaseAuth.instance;

    googleSignIn.signIn().then((GoogleSignInAccount? googleSignInAccount) {
      if(googleSignInAccount != null) {
        /*
        // Get Authentification data
        googleSignInAccount.authentication.then((GoogleSignInAuthentication googleSignInAuthentication) {

          // Finish connection
          onSuccess("google-${googleSignInAccount.id}",
                    googleSignInAccount.email.contains("cloudtestlabaccounts"));
        });
        */

        googleSignInAccount.authentication.then((
            GoogleSignInAuthentication googleSignInAuthentication) {
          final AuthCredential credential = GoogleAuthProvider
              .credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          auth.signInWithCredential(credential).then((
              UserCredential authResult) {
            onSuccess("google-${googleSignInAccount.id}",
                      "google-${authResult.user!.uid}",
                      googleSignInAccount.email.contains("cloudtestlabaccounts") );
          });
        });
      }
    });
  }

  Future<void> signInWithPhone(BuildContext? context, onError, onSuccess) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      showDialog(
          context: context!,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) { return enterPhone(context); }
      ).then( (myPhoneNumber) {
        if(myPhoneNumber != "") {
          auth.verifyPhoneNumber(
            phoneNumber: myPhoneNumber,
            verificationCompleted: (
                PhoneAuthCredential credential) {
              // Sign the user in (or link) with the auto-generated credential
              auth.signInWithCredential(credential).then((
                  UserCredential authResult) {
                String uid = "telephone-${authResult.user!.uid}";
                onSuccess(uid);
              }).onError((error, stackTrace) =>
                  onError('LOG_5', myPhoneNumber));
            },
            verificationFailed: (FirebaseAuthException e) {
              onError('LOG_5', "${e.message}: $myPhoneNumber");
            },
            codeSent: (String verificationId,
                int? resendToken) async {
              // Update the UI - wait for the user to enter the SMS code
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  // user must tap button!
                  builder: (BuildContext context) {
                    return showAlert(context);
                  })
                  .then((smsCode) {
                if(smsCode!="") {
                  // Create a PhoneAuthCredential with the code
                  PhoneAuthCredential credential = PhoneAuthProvider
                      .credential(
                      verificationId: verificationId,
                      smsCode: smsCode);

                  // Sign the user in (or link) with the credential
                  auth.signInWithCredential(credential).then((
                      UserCredential authResult) {
                    String uid = "telephone-${authResult.user!.uid}";
                    onSuccess(uid);
                  }).onError((error, stackTrace) {
                      onError('LOG_5', myPhoneNumber);
                    }
                  );
                } else {
                  onError('LOG_8', null);
                }
              });
            },
            timeout: const Duration(seconds: 2 * 60),
            codeAutoRetrievalTimeout: (
                String verificationId) {},
          ).onError((error, stackTrace) =>
              onError('LOG_5', error));
        } else {
          onError('LOG_8', null);
        }
      }
      );
    }
    catch(e) {
      onError(e);
    }
    /*
    MobileNumber.listenPhonePermission((isPermissionGranted) async {
      if (isPermissionGranted) {
        readMobileSIMInfo(context, onError, onSuccess);
      } else {
        onError('LOG_8', null);
      }
    });

    readMobileSIMInfo(context, onError, onSuccess);
    */
  }
/*
  Future<void> readMobileSIMInfo(BuildContext? context, onError, onSuccess) async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var simCards = (await MobileNumber.getSimCards)!;

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
                            child: Text("${sim.countryPhonePrefix} - ${sim.number}")
                        );
                      })
                ]
            );
          }
      );
    } on PlatformException catch (e) {
      onError('LOG_5', e);
    }
  }
*/
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