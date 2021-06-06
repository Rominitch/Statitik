import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/internationalization.dart';

class DrawTutorial extends StatefulWidget {
  const DrawTutorial({Key? key}) : super(key: key);

  @override
  _DrawTutorialState createState() => _DrawTutorialState();
}

class _DrawTutorialState extends State<DrawTutorial> {
  late double width;
  late double w1_3;
  late double w2_3;
  late double w1_2;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width - 10;
    w1_3 = width/3;
    w2_3 = 2*width/3;
    w1_2 = width/2;

    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.all(5.0),
            child: Text( StatitikLocale.of(context).read('TUTO0_0'),
              maxLines: 3,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          actions: [
            Card(
            color: Colors.green[700],
                child: TextButton(
                    child: Text(StatitikLocale.of(context).read('TUTO0_1')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                ),
            )
          ]
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SimpleText(StatitikLocale.of(context).read('TUTO0_2')),
              Title(StatitikLocale.of(context).read('TUTO0_3')),
              CardTutoImage(StatitikLocale.of(context).read('TUTO0_4'), "tuto1", false),
              CardTutoImage(StatitikLocale.of(context).read('TUTO0_5'), "tuto2", ),
              CardTutoImage(StatitikLocale.of(context).read('TUTO0_6'), "tuto3", false),
              CardTutoColumnChildren([
                Text(StatitikLocale.of(context).read('TUTO0_7'), textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headline5),
                Text(StatitikLocale.of(context).read('TUTO0_8'), textAlign: TextAlign.justify),
              ]),
              CardTutoColumnChildren([
                Text(StatitikLocale.of(context).read('TUTO0_9'), textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headline5),
                CardTutoCC(StatitikLocale.of(context).read('TUTO0_10'), <Widget>[
                  SimpleText(StatitikLocale.of(context).read('TUTO0_11')),
                  Icon(Icons.add_photo_alternate_outlined),
                  Conseil(StatitikLocale.of(context).read('TUTO0_12'), Colors.grey[400]!),
                  SimpleText(StatitikLocale.of(context).read('TUTO0_13')),
                  ImageTuto("tuto4", 40),
                  SimpleText(StatitikLocale.of(context).read('TUTO0_14')),
                ], Colors.grey[700]!),
                CardTutoCC(StatitikLocale.of(context).read('TUTO0_15'), [
                  SimpleText(StatitikLocale.of(context).read('TUTO0_16')),
                ], Colors.grey[700]!),
              ]),
              Title(StatitikLocale.of(context).read('TUTO0_17')),
              SimpleText(StatitikLocale.of(context).read('TUTO0_18')),
              CardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_19'), "tuto5",[
                SimpleText(StatitikLocale.of(context).read('TUTO0_20')),
              ], true, 70),
              CardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_21'), "tuto6",[
                SimpleText(StatitikLocale.of(context).read('TUTO0_22')),
                Conseil(StatitikLocale.of(context).read('TUTO0_23'), Colors.deepOrange),
              ], false, 80),
              CardTutoCC(StatitikLocale.of(context).read('TUTO0_24'), [
                SimpleText(StatitikLocale.of(context).read('TUTO0_25')),
                SimpleText(StatitikLocale.of(context).read('TUTO0_26')),
              ], Colors.grey[700]!),
              Title(StatitikLocale.of(context).read('TUTO0_27')),
              SimpleText(StatitikLocale.of(context).read('TUTO0_28')),
              SimpleText(StatitikLocale.of(context).read('TUTO0_29')),
              Conseil(StatitikLocale.of(context).read('TUTO0_30'), Colors.deepOrange),
              CardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_31'), "tuto7",[
                SimpleText(StatitikLocale.of(context).read('TUTO0_32')),
              ]),
              CardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_33'), "tuto9",[
                SimpleText(StatitikLocale.of(context).read('TUTO0_34')),
                Conseil(StatitikLocale.of(context).read('TUTO0_35'), Colors.deepOrange),
              ]),
              CardTutoColumnChildren([
                SimpleText(StatitikLocale.of(context).read('TUTO0_36')),
              ]),
              CardTutoColumnChildren([
                SimpleText(StatitikLocale.of(context).read('TUTO0_37')),
                SimpleText(StatitikLocale.of(context).read('TUTO0_38')),
                SimpleText(StatitikLocale.of(context).read('TUTO0_39')),
                SimpleText(StatitikLocale.of(context).read('TUTO0_40')),
                Conseil(StatitikLocale.of(context).read('TUTO0_41'), Colors.deepOrange),
              ]),
              Title(StatitikLocale.of(context).read('TUTO0_42')),
              CardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_43'), "tuto8", [
                SimpleText(StatitikLocale.of(context).read('TUTO0_44')),
                SimpleText(StatitikLocale.of(context).read('TUTO0_45'))
              ], true, 70),
              SimpleText(StatitikLocale.of(context).read('TUTO0_46')),
              Center(child: drawImagePress(context, "PikaNoResult", 250.0))
            ],
          )
        )
    );
  }

  Widget SimpleText(String text) {
    return Text(text, softWrap: true, maxLines: 5,  textAlign: TextAlign.justify, style: Theme.of(context).textTheme.bodyText2);
  }

  Widget Title(String text) {
    return Text(text, style: Theme.of(context).textTheme.headline5);
  }

  Widget ImageTuto(String image, double height) {
    return CachedNetworkImage(imageUrl: '$adresseHTML/StatitikCard/tuto/$image.png',
      errorWidget: (context, url, error) => Icon(Icons.help_outline),
      placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
      height: height,
    );
  }
  Widget CardTutoImage(String text, String image, [bool imageRight=true])
  {
    var content = imageRight ? <Widget>[
      Container(
        width: w2_3,
        child: SimpleText(text),
      ),
      ImageTuto(image, 150),
    ] : [
      ImageTuto(image, 150),
      Container(
        width: w2_3,
        child: SimpleText(text),
      ),
    ];
    return CardTutoRowChildren(content);
  }

  Widget CardTutoTitleImage(String title, String image, List<Widget> subContent, [bool imageRight=true, double imageHeight=150])
  {
    var content = imageRight ? <Widget>[
      Container(
        width: w2_3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children : <Widget>[
            Text(title, style: Theme.of(context).textTheme.headline6),
          ]+subContent
        )
      ),
      ImageTuto(image, imageHeight),
    ] : [
      ImageTuto(image, imageHeight),
      Container(
        width: w2_3,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children : <Widget>[
              Text(title, style: Theme.of(context).textTheme.headline6),
            ]+subContent
        )
      ),
    ];
    return CardTutoRowChildren(content);
  }

  Widget CardTutoRowChildren(List<Widget> content)
  {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5.0),
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: content,
        ),
      ),
    );
  }
  Widget CardTutoColumnChildren(List<Widget> content)
  {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5.0),
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: content,
        ),
      ),
    );
  }
  Widget CardTutoCC(String title, List<Widget> content, Color color)
  {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5.0),
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headline6),
          ]+content,
        ),
      ),
    );
  }

  Widget Conseil(String text, Color color) {
    return Text(text,
      softWrap: true, maxLines: 5,
      textAlign: TextAlign.justify, style: TextStyle(
         color:  color,
         fontStyle: FontStyle.italic,
         fontSize: 10,
        ),
    );
  }
}