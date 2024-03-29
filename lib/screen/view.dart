import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/Draw/BoosterDraw.dart';
import 'package:statitikcard/services/Draw/SessionDraw.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';

Widget createLanguage(Language l, BuildContext context, Widget Function(BuildContext) press)
{
  return Container(
    child: TextButton(
      child: Image(
        image: AssetImage('assets/langue/${l.image}.png'),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: press));
      },
    ),
  );
}

class ExtensionButton extends StatefulWidget {
  final void Function()     press;
  final SubExtension subExtension;

  ExtensionButton({required this.subExtension, required this.press});

  @override
  _ExtensionButtonState createState() => _ExtensionButtonState();
}

class _ExtensionButtonState extends State<ExtensionButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: Container(
        height: 40.0,
        child: TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0),
                                      minimumSize: Size(30.0, 40.0)),
          child: Environment.instance.showExtensionName
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [widget.subExtension.image(hSize: iconSize),
                             Text(widget.subExtension.name, textAlign: TextAlign.center,)
                            ]
              )
              : widget.subExtension.image(),
          onPressed: widget.press,
        ),
      ),
    );
  }
}

Widget createSubExtension(SubExtension se, BuildContext context, void Function() press, bool withName)
{
  return Card(
    color: Colors.grey[850],
    child: TextButton(
      style: TextButton.styleFrom(minimumSize: Size(0.0, 40.0)),
      child: withName ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          se.image(),
          SizedBox(width: 10.0),
          Text( '${se.name}' ),
        ])
      : se.image(),
      onPressed: press,
    ),
  );
}

Widget createBoosterDrawTitle(SessionDraw current, BoosterDraw bd, BuildContext context, Function press, Function update) {
  Color? color = Colors.grey[900];
  if( bd.isFinished() ) {
    final valid = bd.validationWorld(current.language);
    color = (valid == Validator.Valid) ? greenValid : Colors.deepOrange;
  }

  return Card(
    color: color,
    child: TextButton(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: (bd.subExtension != null) ? bd.subExtension!.image(hSize: iconSize) : Icon(Icons.add_to_photos)),
            Text(bd.id.toString()),
        ]),
      ),
      onPressed: () => press(context),
      onLongPress: () {
        if(current.productAnomaly || bd.isRandom())
        showDialog(
          context: context,
          builder: (_) => new AlertDialog(
            title: new Text(StatitikLocale.of(context).read('V_B2')),
            actions: [
              Card(
                color: Colors.grey[700],
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('V_B3')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    bd.resetExtensions();
                    press(context);
                  }
                ),
              ),
              if( current.productAnomaly && current.canDelete() ) Card(
                color: Colors.red,
                child: TextButton(
                  child: Text(StatitikLocale.of(context).read('delete'), style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      current.deleteBooster(bd.id-1);
                      Navigator.of(context).pop();
                      update();
                    }
                  ),
                ),
            ],
          )
        );
      },
    )
  );
}



Widget signInButton(String nameId, CredentialMode mode, Function([String?]) press, BuildContext context) {
  return  Card(
    color: Colors.grey.shade600,
    child: TextButton(
        onPressed: () {
          try {
            // Login
            Environment.instance.login(mode, context,
              afterLogOrError: ([String? messageError]) {
                // Try to restore PokeSpace if exists
                if(Environment.instance.user != null) {
                  EasyLoading.show();
                  Environment.instance.readPokeSpace().then((value) {
                  }).whenComplete(() {
                    EasyLoading.dismiss();

                    // Show error and refresh
                    press(messageError);
                  });
                }
                else
                  // Show error and refresh
                  press(messageError);
              }
            );
          }
          catch (e) {

          }
        },
        child:Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            StatitikLocale.of(context).read(nameId),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        )
    ),
  );
}

Widget signOutButton(Function press, context) {
  return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor, // background
      ),
    onPressed: () {
      Environment.instance.credential.signOutGoogle().then((result) {
        press();
      });
    },
    child:Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        StatitikLocale.of(context).read('deconnexion'),
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    )
  );
}

AlertDialog showAlert(BuildContext context) {
  return AlertDialog(
    title: Text(StatitikLocale.of(context).read('warning')),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(StatitikLocale.of(context).read('V_B0')),
          Text(StatitikLocale.of(context).read('V_B1')),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(StatitikLocale.of(context).read('yes')),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
      TextButton(
        child: Text(StatitikLocale.of(context).read('cancel')),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
    ],
  );
}

RichText textBullet(text) {
  return RichText(
    text: TextSpan(
      text: '• ',
      children: <TextSpan>[
        TextSpan(text: text,),
      ],
    ),
  );
}

List<Widget> createRegionsWidget(context, regionController, Language language) {
  List<Widget> regionsWidget = [];

  // No region item
  regionsWidget.add(CustomRadio(value: null, controller: regionController,
      widget: Row(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Center(child: Text(
              StatitikLocale.of(context).read('REG_0'),
              style: TextStyle(fontSize: 9),)))
          ])
    )
  );

  // parse region
  Environment.instance.collection.regions.values.forEach((region) {
    regionsWidget.add(CustomRadio(value: region, controller: regionController,
        widget: Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Center(child: Text(
                region.name(language),
                style: TextStyle(fontSize: 9),)))
            ])
      )
    );
  });
  return regionsWidget;
}

class MovingImageWidget extends StatefulWidget {
  final Widget child;

  const MovingImageWidget(this.child, {Key? key}) : super(key: key);

  @override
  _MovingImageWidgetState createState() => _MovingImageWidgetState();
}

class _MovingImageWidgetState extends State<MovingImageWidget> with SingleTickerProviderStateMixin {
  static const double maxAngle = 0.05;

  late AnimationController animationControler = AnimationController(
      value: 0,
      lowerBound: -maxAngle,
      upperBound: maxAngle,
      duration: Duration(seconds: 2),
      reverseDuration: Duration(seconds: 2), vsync: this
  );

  @override
  void initState() {
    super.initState();
    // Go
    animationControler.repeat(reverse: true);
  }
  @override
  void dispose() {
    Environment.instance.onInfoLoading.close();
    animationControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationControler,
        builder: (context, child) => Transform.rotate(
          angle: animationControler.value,
          child: Center(child: widget.child),
        )
    );
  }
}