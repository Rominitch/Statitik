import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/services/draw/booster_draw.dart';
import 'package:statitikcard/services/draw/session_draw.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/credential.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';

Widget createLanguage(LanguageOld l, BuildContext context, Widget Function(BuildContext) press)
{
  return TextButton(
    child: Image(
      image: AssetImage('assets/langue/${l.image}.png'),
    ),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: press));
    },
  );
}

class ExtensionButton extends StatefulWidget {
  final void Function()     press;
  final SubExtension subExtension;

  const ExtensionButton({required this.subExtension, required this.press, super.key});

  @override
  State<ExtensionButton> createState() => _ExtensionButtonState();
}

class _ExtensionButtonState extends State<ExtensionButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: SizedBox(
        height: 40.0,
        child: TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0),
                                      minimumSize: const Size(30.0, 40.0)),
          onPressed: widget.press,
          child: Environment.instance.pkConfig().showExtensionName
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [widget.subExtension.image(hSize: iconSize),
                             Text(widget.subExtension.name, textAlign: TextAlign.center,)
                            ]
              )
              : widget.subExtension.image(),
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
      style: TextButton.styleFrom(minimumSize: const Size(0.0, 40.0)),
      onPressed: press,
      child: withName ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          se.image(),
          const SizedBox(width: 10.0),
          Text( se.name ),
        ])
      : se.image(),
    ),
  );
}

Widget createBoosterDrawTitle(SessionDraw current, BoosterDraw bd, BuildContext context, Function press, Function update) {
  Color? color = Colors.grey[900];
  if( bd.isFinished() ) {
    final valid = bd.validationWorld(current.language);
    color = (valid == Validator.valid) ? greenValid : Colors.deepOrange;
  }

  return Card(
    color: color,
    child: TextButton(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: (bd.subExtension != null) ? bd.subExtension!.image(hSize: iconSize) : const Icon(Icons.add_to_photos)),
            Text(bd.id.toString()),
        ]),
      ),
      onPressed: () => press(context),
      onLongPress: () {
        if(current.productAnomaly || bd.isRandom()) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.v_b2),
              actions: [
                Card(
                  color: Colors.grey[700],
                  child: TextButton(
                    child: Text(AppLocalizations.of(context)!.v_b3),
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
                    child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.white),),
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
        }
      },
    )
  );
}



Widget signInButton(String label, CredentialMode mode, Function(String) showMessageError, Function refresh, BuildContext context) {
  return  Card(
    color: Colors.grey.shade600,
    child: TextButton(
        onPressed: () {
          try {
            // Login
            Environment.instance.login(mode, context,
              afterLog: () {
                // Try to restore pokespace if exists
                if(Environment.instance.user != null) {
                  EasyLoading.show();
                  Environment.instance.readPokeSpace().then((value) {
                  }).whenComplete(() {
                    // Try to update latest connexion time (but not critical)
                    try {
                      Environment.instance.tryChangeUserConnexionDate(Environment.instance.user!.uid);
                    } catch(e) {
                      printOutput(e.toString());
                    }
                    EasyLoading.dismiss();
                    refresh();
                  });
                }
                else {
                  showMessageError(AppLocalizations.of(context)!.log_4);
                }
              },
              afterError: showMessageError
            );
          }
          catch (_) {}
        },
        child:Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label,
            style: const TextStyle(
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
      /*
      Environment.instance.credential.signOutGoogle().then((result) {
        press();
      });
      */
    },
    child:Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        AppLocalizations.of(context)!.deconnexion,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    )
  );
}

AlertDialog showAlert(BuildContext context) {
  return AlertDialog(
    title: Text(AppLocalizations.of(context)!.warning),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(AppLocalizations.of(context)!.v_b0),
          Text(AppLocalizations.of(context)!.v_b1),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(AppLocalizations.of(context)!.yes),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
      TextButton(
        child: Text(AppLocalizations.of(context)!.cancel),
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

List<Widget> createRegionsWidget(context, regionController, LanguageOld language) {
  List<Widget> regionsWidget = [];

  // No region item
  regionsWidget.add(CustomRadio(value: null, controller: regionController,
      widget: Row(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Center(child: Text(
              AppLocalizations.of(context)!.reg_0,
              style: const TextStyle(fontSize: 9),)))
          ])
    )
  );

  // parse region
  for (var region in Environment.instance.collection.regions.values) {
    regionsWidget.add(CustomRadio(value: region, controller: regionController,
        widget: Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Center(child: Text(
                region.name(language),
                style: const TextStyle(fontSize: 9),)))
            ])
      )
    );
  }
  return regionsWidget;
}

class MovingImageWidget extends StatefulWidget {
  final Widget child;

  const MovingImageWidget(this.child, {super.key});

  @override
  State<MovingImageWidget> createState() => _MovingImageWidgetState();
}

class _MovingImageWidgetState extends State<MovingImageWidget> with SingleTickerProviderStateMixin {
  static const double maxAngle = 0.05;

  late AnimationController animationControler = AnimationController(
      value: 0,
      lowerBound: -maxAngle,
      upperBound: maxAngle,
      duration: const Duration(seconds: 2),
      reverseDuration: const Duration(seconds: 2), vsync: this
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
    return RepaintBoundary(
      child:AnimatedBuilder(
        animation: animationControler,
        builder: (context, child) => Transform.rotate(
          angle: animationControler.value,
          child: Center(child: widget.child),
        )
      )
    );
  }
}