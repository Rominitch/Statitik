import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
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
                title: new Text("Edition du booster"),
                actions: [
                  Card(
                    color: Colors.grey[700],
                    child: FlatButton(
                      child: Text('Changer l\'extension'),
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
                      child: Text('Supprimer', style: TextStyle(color: Colors.white),),
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
                    Text('${widget.idCard+1} ($nbCard)')
                  else
                    Text('${widget.idCard+1}')
                ]),
            padding: EdgeInsets.all(2.0),
            onLongPress: () {
              if( widget.card.hasAnotherRendering() ) {
                setState(() {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) { return CardSelector(widget.boosterDraw, widget.idCard, update); }
                  );
                  widget.refresh();
                });
              }
            },
            onPressed: () {
              setState(() {
                widget.boosterDraw.toggleCard(widget.idCard, Mode.Normal);
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
    bool enabled = widget.boosterDraw.isEnergy(widget.type);
    return Card(
      child: FlatButton(
        color: enabled ? greenValid : Colors.grey[800],
        minWidth: 20.0,
        child: energyImage(widget.type),
        onPressed: () {
          widget.boosterDraw.setEnergy(widget.type, enabled);
        },
      ),
    );
  }
}

void createCardType(BuildContext context, int id, BoosterDraw boosterDraw, Function refresh) {
  showDialog(
      context: context,
      builder: (BuildContext context) { return CardSelector(boosterDraw, id, refresh); }
  );
}

class CardSelector extends StatefulWidget {
  @override
  _CardSelectorState createState() => _CardSelectorState();

  final BoosterDraw boosterDraw;
  final int      id;
  final Function refresh;

  CardSelector(this.boosterDraw, this.id, this.refresh);
}

class _CardSelectorState extends State<CardSelector> {
  @override
  Widget build(BuildContext context) {
    CodeDraw code = widget.boosterDraw.cardBin[widget.id];
    Function r = () {setState((){});};

    return SimpleDialog(
      title: Text("Type de carte"),
      children: [Column(
          mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            createIconCard(context, Mode.Normal,  code.countNormal , widget.refresh, r),
            createIconCard(context, Mode.Reverse, code.countReverse, widget.refresh, r),
            createIconCard(context, Mode.Halo,    code.countHalo   , widget.refresh, r),
          ]
      ),]
    );
  }

  Widget createIconCard(BuildContext context, Mode mode, int count, Function refresh, Function localRefresh) {
    CodeDraw code = widget.boosterDraw.cardBin[widget.id];
    final Color background = Colors.grey[800];
    return Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              color: count > 0 ? modeColors[mode] : background,
              child: FlatButton(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Image(image: AssetImage('assets/carte/${modeImgs[mode]}.png'), width: 75.0),
                      SizedBox(height: 6.0),
                      Text(modeNames[mode]),
                    ]),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                onPressed: () {
                  widget.boosterDraw.setOtherRendering(widget.id, mode);
                  Navigator.of(context).pop();
                  refresh();
                },
              ),
            ),
            SizedBox(width: 10),
            Column(
              children: [
                RaisedButton(
                    onPressed: () {
                      widget.boosterDraw.increase(code, mode);
                      localRefresh();
                      refresh();
                    },
                    color: background,
                    child: Container(
                      child: Text('+', style: TextStyle(fontSize: 20)),
                    )
                ),
                Container(
                    child: Text('$count', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),)
                ),
                RaisedButton(
                    onPressed: () {
                      widget.boosterDraw.decrease(code, mode);
                      localRefresh();
                      refresh();
                    },
                    color: background,
                    child: Container(
                      child: Text('-', style: TextStyle(fontSize: 20)),
                    )
                ),
              ],
            )
          ],
        )
    );
  }
}


Widget signInButton(Function press) {
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
            'Connexion avec Google',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
        )
    ),
  );
}

Widget signOutButton(Function press) {
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
            'Deconnexion',
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
    title: Text('Attention'),
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text('Les données seront réinitialisées.'),
          Text('Voulez-vous continuer ?'),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text('Oui'),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
      TextButton(
        child: Text('Annuler'),
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