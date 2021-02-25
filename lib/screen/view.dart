import 'package:flutter/material.dart';
import 'package:statitikcard/screen/widgets/CardSelector.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

Widget createLanguage(Language l, BuildContext context, Function press)
{
  return Container(
    child: FlatButton(
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
  final Function     press;
  final SubExtension subExtension;

  ExtensionButton({this.subExtension, this.press});

  @override
  _ExtensionButtonState createState() => _ExtensionButtonState();
}

class _ExtensionButtonState extends State<ExtensionButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: FlatButton(
        height: 40.0,
        minWidth: 30.0,
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
    );
  }
}

Widget createSubExtension(SubExtension se, BuildContext context, Function press, bool withName)
{
  return Card(
    color: Colors.grey[850],
    child: FlatButton(
      height: 40.0,
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

  return Card(
      color: bd.isFinished() ? greenValid : Colors.grey[900],
      child: FlatButton(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (bd.subExtension != null) ? bd.subExtension.image(hSize: iconSize) : Icon(Icons.add_to_photos),
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
                    child: FlatButton(
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
                    child: FlatButton(
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

  PokemonCard({this.idCard, this.card, this.boosterDraw, this.refresh});

  @override
  _PokemonCardState createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  List<Widget> icons;

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
    CodeDraw cardValue = widget.boosterDraw.cardBin[widget.idCard];
    int nbCard = cardValue.count();
    Function update = () {
      setState(() {});
      widget.refresh();
    };

    return Card(
        color: cardValue.color(),
        child: FlatButton(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: icons+[
                  if( nbCard > 1)
                    Text('${widget.boosterDraw.nameCard(widget.idCard)} ($nbCard)')
                  else
                    Text('${widget.boosterDraw.nameCard(widget.idCard)}')
                ]),
            padding: EdgeInsets.all(2.0),
            onLongPress: () {
              if( widget.card.hasAnotherRendering() ) {
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
                widget.boosterDraw.toggleCard(widget.boosterDraw.cardBin[widget.idCard], widget.card.defaultMode());
                widget.refresh();
              });
            }
        )
    );
  }
}

class EnergyButton extends StatefulWidget {
  final BoosterDraw boosterDraw;
  final Type type;
  final Function refresh;

  EnergyButton({this.type, this.boosterDraw, this.refresh});

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
    return Card(
      child: FlatButton(
        color: code.color(),
        minWidth: 20.0,
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

Widget signInButton(Function press, BuildContext context) {
  return  Card(
    child: FlatButton(
        onPressed: () {
          // Login
          Environment.instance.login(0).then((result) {
              press(result);
          });
        },
        child:Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            StatitikLocale.of(context).read('V_B5'),
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
  return  Card(
    child: FlatButton(
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
              color: Colors.grey,
            ),
          ),
        )
    ),
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

