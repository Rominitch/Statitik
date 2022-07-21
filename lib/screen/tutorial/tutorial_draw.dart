import 'package:flutter/material.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/internationalization.dart';

class DrawTutorial extends StatefulWidget {
  const DrawTutorial({Key? key}) : super(key: key);

  @override
  State<DrawTutorial> createState() => _DrawTutorialState();
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
            padding: const EdgeInsets.all(5.0),
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
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              simpleText(StatitikLocale.of(context).read('TUTO0_2')),
              title(StatitikLocale.of(context).read('TUTO0_3')),
              cardTutoImage(StatitikLocale.of(context).read('TUTO0_4'), "tuto1", false),
              cardTutoImage(StatitikLocale.of(context).read('TUTO0_5'), "tuto2", ),
              cardTutoImage(StatitikLocale.of(context).read('TUTO0_6'), "tuto3", false),
              cardTutoColumnChildren([
                Text(StatitikLocale.of(context).read('TUTO0_7'), textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headline5),
                Text(StatitikLocale.of(context).read('TUTO0_8'), textAlign: TextAlign.justify),
              ]),
              cardTutoColumnChildren([
                Text(StatitikLocale.of(context).read('TUTO0_9'), textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headline5),
                cardTutoCC(StatitikLocale.of(context).read('TUTO0_10'), <Widget>[
                  simpleText(StatitikLocale.of(context).read('TUTO0_11')),
                  const Icon(Icons.add_photo_alternate_outlined),
                  conseil(StatitikLocale.of(context).read('TUTO0_12'), Colors.grey[400]!),
                  simpleText(StatitikLocale.of(context).read('TUTO0_13')),
                  imageTuto("tuto4", 40),
                  simpleText(StatitikLocale.of(context).read('TUTO0_14')),
                ], Colors.grey[700]!),
                cardTutoCC(StatitikLocale.of(context).read('TUTO0_15'), [
                  simpleText(StatitikLocale.of(context).read('TUTO0_16')),
                ], Colors.grey[700]!),
              ]),
              title(StatitikLocale.of(context).read('TUTO0_17')),
              simpleText(StatitikLocale.of(context).read('TUTO0_18')),
              cardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_19'), "tuto5",[
                simpleText(StatitikLocale.of(context).read('TUTO0_20')),
              ], true, 70),
              cardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_21'), "tuto6",[
                simpleText(StatitikLocale.of(context).read('TUTO0_22')),
                conseil(StatitikLocale.of(context).read('TUTO0_23'), Colors.deepOrange),
              ], false, 80),
              cardTutoCC(StatitikLocale.of(context).read('TUTO0_24'), [
                simpleText(StatitikLocale.of(context).read('TUTO0_25')),
                simpleText(StatitikLocale.of(context).read('TUTO0_26')),
              ], Colors.grey[700]!),
              title(StatitikLocale.of(context).read('TUTO0_27')),
              simpleText(StatitikLocale.of(context).read('TUTO0_28')),
              simpleText(StatitikLocale.of(context).read('TUTO0_29')),
              conseil(StatitikLocale.of(context).read('TUTO0_30'), Colors.deepOrange),
              cardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_31'), "tuto7",[
                simpleText(StatitikLocale.of(context).read('TUTO0_32')),
              ]),
              cardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_33'), "tuto9",[
                simpleText(StatitikLocale.of(context).read('TUTO0_34')),
                conseil(StatitikLocale.of(context).read('TUTO0_35'), Colors.deepOrange),
              ]),
              cardTutoColumnChildren([
                simpleText(StatitikLocale.of(context).read('TUTO0_36')),
              ]),
              cardTutoColumnChildren([
                simpleText(StatitikLocale.of(context).read('TUTO0_37')),
                simpleText(StatitikLocale.of(context).read('TUTO0_38')),
                simpleText(StatitikLocale.of(context).read('TUTO0_39')),
                simpleText(StatitikLocale.of(context).read('TUTO0_40')),
                conseil(StatitikLocale.of(context).read('TUTO0_41'), Colors.deepOrange),
              ]),
              title(StatitikLocale.of(context).read('TUTO0_42')),
              cardTutoTitleImage(StatitikLocale.of(context).read('TUTO0_43'), "tuto8", [
                simpleText(StatitikLocale.of(context).read('TUTO0_44')),
                simpleText(StatitikLocale.of(context).read('TUTO0_45'))
              ], true, 70),
              simpleText(StatitikLocale.of(context).read('TUTO0_46')),
              Center(child: drawImagePress(context, "PikaNoResult", 250.0))
            ],
          )
        )
    );
  }

  Widget simpleText(String text) {
    return Text(text, softWrap: true, maxLines: 5,  textAlign: TextAlign.justify, style: Theme.of(context).textTheme.bodyText2);
  }

  Widget title(String text) {
    return Text(text, style: Theme.of(context).textTheme.headline5);
  }

  Widget imageTuto(String image, double height) {
    return drawCachedImage('tuto', image, height: height);
  }
  Widget cardTutoImage(String text, String image, [bool imageRight=true])
  {
    var content = imageRight ? <Widget>[
      SizedBox(
        width: w2_3,
        child: simpleText(text),
      ),
      imageTuto(image, 150),
    ] : [
      imageTuto(image, 150),
      SizedBox(
        width: w2_3,
        child: simpleText(text),
      ),
    ];
    return cardTutoRowChildren(content);
  }

  Widget cardTutoTitleImage(String title, String image, List<Widget> subContent, [bool imageRight=true, double imageHeight=150])
  {
    var content = imageRight ? <Widget>[
      SizedBox(
        width: w2_3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children : <Widget>[
            Text(title, style: Theme.of(context).textTheme.headline6),
          ]+subContent
        )
      ),
      imageTuto(image, imageHeight),
    ] : [
      imageTuto(image, imageHeight),
      SizedBox(
        width: w2_3,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children : <Widget>[
              Text(title, style: Theme.of(context).textTheme.headline6),
            ]+subContent
        )
      ),
    ];
    return cardTutoRowChildren(content);
  }

  Widget cardTutoRowChildren(List<Widget> content)
  {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: content,
        ),
      ),
    );
  }
  Widget cardTutoColumnChildren(List<Widget> content)
  {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: content,
        ),
      ),
    );
  }
  Widget cardTutoCC(String title, List<Widget> content, Color color)
  {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(5.0),
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

  Widget conseil(String text, Color color) {
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