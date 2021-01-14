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
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [widget.subExtension.image(),
                           SizedBox(width: 8.0),
                           Text(widget.subExtension.name)
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

Widget createBoosterDrawTitle(BoosterDraw bd, BuildContext context, Function press) {
  return Card(
      color: bd.isFinished() ? Colors.green[400] : Colors.grey[900],
      child: FlatButton(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              bd.subExtension.image(),
              SizedBox(height: 6.0),
              Text(
                  '${bd.id}'
              ),
          ]),
        ),
        onPressed: () => press(context)
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
  @override
  Widget build(BuildContext context) {
    String cardValue = widget.boosterDraw.card[widget.idCard];
    bool isTake = cardValue != emptyMode;
    Mode selected = isTake ? convertMode[cardValue] : Mode.Normal;

    Function update = () {
      setState(() {});
      widget.refresh();
    };

    return Card(
        color: isTake ? colors[selected] : Colors.grey[900],
        child: FlatButton(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(  mainAxisAlignment: MainAxisAlignment.center,
                      children: [widget.card.imageType()] + widget.card.imageRarity()),
                  SizedBox(height: 6.0),
                  Text('${widget.idCard+1}'),
                ]),
            padding: EdgeInsets.all(2.0),
            onLongPress: () {
              if( widget.card.hasAnotherRendering() ) {
                setState(() {
                  createCardType(
                      context, widget.idCard, widget.boosterDraw, selected,
                      update);
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

    widget.boosterDraw.onEnergyChanged.stream.listen( (bool)
      {
        setState(() {
          //widget.boosterDraw.setEnergy(widget.type);
          widget.refresh();
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FlatButton(
        color: convertType[widget.boosterDraw.energyCode] == widget.type ? Colors.green : Colors.grey[800],
        minWidth: 20.0,
        child: energyImage(widget.type),
        onPressed: () {
          widget.boosterDraw.setEnergy(widget.type);
        },
      ),
    );
  }
}

const Map imgs   = {Mode.Normal: "normal", Mode.Reverse: "reverse", Mode.Halo: "halo"};
const Map names  = {Mode.Normal: "Normal", Mode.Reverse: "Reverse", Mode.Halo: "Halo"};
const Map colors = {Mode.Normal: Colors.green, Mode.Reverse: Colors.blueAccent, Mode.Halo: Colors.orange};

Widget createIconCard(BuildContext context, int id, BoosterDraw boosterDraw, Mode mode, bool isSelected, Function refresh) {

  return Card(
    color: isSelected ? colors[mode] : Colors.grey[900],
    child: FlatButton(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Image(image: AssetImage('assets/carte/${imgs[mode]}.png'), width: 75.0),
              SizedBox(height: 6.0),
              Text(names[mode]),
            ]),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        onPressed: () {
          boosterDraw.setOtherRendering(id, mode);
          Navigator.of(context).pop();
          refresh();
        },
      ),
  );
}

void createCardType(BuildContext context, int id, BoosterDraw boosterDraw, Mode selected, Function refresh) {
  showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Selection du type"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
            [
                createIconCard(context, id, boosterDraw, Mode.Normal, selected == Mode.Normal, refresh),
                createIconCard(context, id, boosterDraw, Mode.Reverse, selected == Mode.Reverse, refresh),
                createIconCard(context, id, boosterDraw, Mode.Halo, selected == Mode.Halo, refresh),
            ]
        ),
      )
  );
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