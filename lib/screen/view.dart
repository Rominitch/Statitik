import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

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

Widget createBoosterDrawTitle(BoosterDraw bd, BuildContext context, Function press, Function update) {
  SessionDraw current = Environment.instance.currentDraw;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (bd.subExtension != null) ? bd.subExtension!.image(hSize: iconSize) : Icon(Icons.add_to_photos),
            SizedBox(height: 6.0),
            Text('${bd.id}'),
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

class PokemonCard extends StatefulWidget {
  final int idCard;
  final PokeCard card;
  final BoosterDraw boosterDraw;
  final Function refresh;

  PokemonCard({required this.idCard, required this.card, required this.boosterDraw, required this.refresh});

  @override
  _PokemonCardState createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late List<Widget> icons;

  @override
  void initState() {
    icons =
    [
      if(widget.card.isValid())
        Row( mainAxisAlignment: MainAxisAlignment.center,
            children: [widget.card.imageType()] + widget.card.imageRarity()),
      if(widget.card.isValid()) SizedBox(height: 6.0),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CodeDraw cardValue = widget.boosterDraw.cardBin![widget.idCard];
    int nbCard = cardValue.count();
    Function update = () {
      setState(() {});
      widget.refresh();
    };

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: TextButton(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: icons+[
                if( nbCard > 1)
                  Text('${widget.boosterDraw.nameCard(widget.idCard)} ($nbCard)')
                else
                  Text('${widget.boosterDraw.nameCard(widget.idCard)}')
              ]),
          style: TextButton.styleFrom(
            backgroundColor: cardValue.color(),
            padding: const EdgeInsets.all(2.0)
          ),
          onLongPress: () {
            if( widget.card.hasAnotherRendering() || widget.card.hasAlternative ) {
              setState(() {
                showDialog(
                    context: context,
                    builder: (BuildContext context) { return CardSelector(widget.boosterDraw, widget.idCard, update, false); }
                );
                widget.refresh();
              });
            }
          },
          onPressed: () {
            setState(() {
              widget.boosterDraw.toggleCard(widget.boosterDraw.cardBin![widget.idCard], widget.card.defaultMode());
              widget.refresh();
            });
          }
      ),
    );
  }
}

class EnergyButton extends StatefulWidget {
  final BoosterDraw boosterDraw;
  final Type type;
  final Function refresh;

  EnergyButton({required this.type, required this.boosterDraw, required this.refresh});

  @override
  _EnergyButtonState createState() => _EnergyButtonState();
}

class _EnergyButtonState extends State<EnergyButton> {

  @override
  void initState() {
    super.initState();

    widget.boosterDraw.onEnergyChanged.stream.listen( (bool) {
      if (!mounted) return;
      setState(() {
        widget.refresh();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Function update = () {
      setState(() {
        widget.boosterDraw.onEnergyChanged.add(true);
      });
      widget.refresh();
    };

    CodeDraw code = widget.boosterDraw.energiesBin[widget.type.index];
    return Container(
        constraints: BoxConstraints(
          maxWidth: 55.0,
        ),
        padding: EdgeInsets.all(2.0),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: code.color(),
          ),
          child: energyImage(widget.type),
          onPressed: () {
            setState(() {
              widget.boosterDraw.toggleCard(code, Mode.Normal);
              widget.boosterDraw.onEnergyChanged.add(true);
            });
          },
          onLongPress: () {
            setState(() {
              showDialog(
                  context: context,
                  builder: (BuildContext context) { return CardSelector(widget.boosterDraw, widget.type.index, update, true); }
              ).whenComplete(()  {
                setState(() {
                  widget.boosterDraw.onEnergyChanged.add(true);
                  widget.refresh();
                });
              });
            });
          },
        ),
    );
  }
}

Widget signInButton(String nameId, int mode, Function press, BuildContext context) {
  return  Card(
    child: TextButton(
        onPressed: () {
          // Login
          Environment.instance.login(mode, context, press).then((result) {
              press(result);
          });
        },
        child:Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            StatitikLocale.of(context).read(nameId),
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
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

String categoryName(BuildContext context, int id) {
  try {
    return (id == -1) ? StatitikLocale.of(context).read('S_B9') : StatitikLocale.of(context).read('CAT_$id');
  } catch (e) {
    return StatitikLocale.of(context).read('error');
  }
}

