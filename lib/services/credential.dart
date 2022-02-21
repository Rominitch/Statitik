import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

enum CredentialMode
{
  Google,
  Phone,
  AutoLog
}

class Credential
{
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> initialize() async
  {
    try {
      await Firebase.initializeApp();

      // Auto login
      var prefs = await SharedPreferences.getInstance();
      if( prefs.getString('uid') != null ) {
        Environment.instance.login(CredentialMode.AutoLog, null, null);
      }

      printOutput("User created");
    } catch(e) {
      Environment.instance.user = null;
    }
  }

  void signInWithGoogle(onSuccess) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    googleSignIn.signIn().then((GoogleSignInAccount? googleSignInAccount) {
      if(googleSignInAccount != null) {
        googleSignInAccount.authentication.then((
            GoogleSignInAuthentication googleSignInAuthentication) {
          final AuthCredential credential = GoogleAuthProvider
              .credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          _auth.signInWithCredential(credential).then((
              UserCredential authResult) {
            onSuccess("google-" + authResult.user!.uid);
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
          builder: (BuildContext context) { return enterPhone(context); })
          .then( (myPhoneNumber) {
        if(myPhoneNumber != "") {
          auth.verifyPhoneNumber(
            phoneNumber: myPhoneNumber,
            verificationCompleted: (
                PhoneAuthCredential credential) {
              // Sign the user in (or link) with the auto-generated credential
              auth.signInWithCredential(credential).then((
                  UserCredential authResult) {
                String uid = "telephone-" +
                    authResult.user!.uid;
                onSuccess(uid);
              }).onError((error, stackTrace) =>
                  onError('LOG_5', myPhoneNumber));
            },
            verificationFailed: (FirebaseAuthException e) {
              onError('LOG_5', myPhoneNumber);
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
                    String uid = "telephone-" +
                        authResult.user!.uid;
                    onSuccess(uid);
                  }).onError((error, stackTrace) =>
                      onError('LOG_5', myPhoneNumber));
                } else {
                  onError('LOG_8', null);
                }
              });
            },
            timeout: const Duration(seconds: 2 * 60),
            codeAutoRetrievalTimeout: (
                String verificationId) {},
          ).then((value) {}
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
  }

  Future<void> signOutGoogle() async {
    Environment.instance.user = null;
    await googleSignIn.signOut();

    var prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');
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
        decoration: InputDecoration(hintText: "Sms code"),
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
            hintStyle: TextStyle(fontSize: 10),
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