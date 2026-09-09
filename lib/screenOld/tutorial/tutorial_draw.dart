import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/services/tools.dart';

class DrawTutorial extends StatefulWidget {
  const DrawTutorial({super.key});

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
            child: Text( AppLocalizations.of(context)!.tuto_0_0,
              maxLines: 3,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          actions: [
            Card(
            color: Colors.green[700],
                child: TextButton(
                    child: Text(AppLocalizations.of(context)!.tuto_0_1),
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
              simpleText(AppLocalizations.of(context)!.tuto_0_2),
              title(AppLocalizations.of(context)!.tuto_0_3),
              cardTutoImage(AppLocalizations.of(context)!.tuto_0_4, "tuto1", false),
              cardTutoImage(AppLocalizations.of(context)!.tuto_0_5, "tuto2", ),
              cardTutoImage(AppLocalizations.of(context)!.tuto_0_6, "tuto3", false),
              cardTutoColumnChildren([
                Text(AppLocalizations.of(context)!.tuto_0_7, textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headlineSmall),
                Text(AppLocalizations.of(context)!.tuto_0_8, textAlign: TextAlign.justify),
              ]),
              cardTutoColumnChildren([
                Text(AppLocalizations.of(context)!.tuto_0_9, textAlign: TextAlign.justify, style: Theme.of(context).textTheme.headlineSmall),
                cardTutoCC(AppLocalizations.of(context)!.tuto_0_10, <Widget>[
                  simpleText(AppLocalizations.of(context)!.tuto_0_11),
                  const Icon(Icons.add_photo_alternate_outlined),
                  conseil(AppLocalizations.of(context)!.tuto_0_12, Colors.grey[400]!),
                  simpleText(AppLocalizations.of(context)!.tuto_0_13),
                  imageTuto("tuto4", 40),
                  simpleText(AppLocalizations.of(context)!.tuto_0_14),
                ], Colors.grey[700]!),
                cardTutoCC(AppLocalizations.of(context)!.tuto_0_15, [
                  simpleText(AppLocalizations.of(context)!.tuto_0_16),
                ], Colors.grey[700]!),
              ]),
              title(AppLocalizations.of(context)!.tuto_0_17),
              simpleText(AppLocalizations.of(context)!.tuto_0_18),
              cardTutoTitleImage(AppLocalizations.of(context)!.tuto_0_19, "tuto5",[
                simpleText(AppLocalizations.of(context)!.tuto_0_20),
              ], true, 70),
              cardTutoTitleImage(AppLocalizations.of(context)!.tuto_0_21, "tuto6",[
                simpleText(AppLocalizations.of(context)!.tuto_0_22),
                conseil(AppLocalizations.of(context)!.tuto_0_23, Colors.deepOrange),
              ], false, 80),
              cardTutoCC(AppLocalizations.of(context)!.tuto_0_24, [
                simpleText(AppLocalizations.of(context)!.tuto_0_25),
                simpleText(AppLocalizations.of(context)!.tuto_0_26),
              ], Colors.grey[700]!),
              title(AppLocalizations.of(context)!.tuto_0_27),
              simpleText(AppLocalizations.of(context)!.tuto_0_28),
              simpleText(AppLocalizations.of(context)!.tuto_0_29),
              conseil(AppLocalizations.of(context)!.tuto_0_30, Colors.deepOrange),
              cardTutoTitleImage(AppLocalizations.of(context)!.tuto_0_31, "tuto7",[
                simpleText(AppLocalizations.of(context)!.tuto_0_32),
              ]),
              cardTutoTitleImage(AppLocalizations.of(context)!.tuto_0_33, "tuto9",[
                simpleText(AppLocalizations.of(context)!.tuto_0_34),
                conseil(AppLocalizations.of(context)!.tuto_0_35, Colors.deepOrange),
              ]),
              cardTutoColumnChildren([
                simpleText(AppLocalizations.of(context)!.tuto_0_36),
              ]),
              cardTutoColumnChildren([
                simpleText(AppLocalizations.of(context)!.tuto_0_37),
                simpleText(AppLocalizations.of(context)!.tuto_0_38),
                simpleText(AppLocalizations.of(context)!.tuto_0_39),
                simpleText(AppLocalizations.of(context)!.tuto_0_40),
                conseil(AppLocalizations.of(context)!.tuto_0_41, Colors.deepOrange),
              ]),
              title(AppLocalizations.of(context)!.tuto_0_42),
              cardTutoTitleImage(AppLocalizations.of(context)!.tuto_0_43, "tuto8", [
                simpleText(AppLocalizations.of(context)!.tuto_0_44),
                simpleText(AppLocalizations.of(context)!.tuto_0_45)
              ], true, 70),
              simpleText(AppLocalizations.of(context)!.tuto_0_46),
              Center(child: drawImagePress(context, "PikaNoResult", 250.0))
            ],
          )
        )
    );
  }

  Widget simpleText(String text) {
    return Text(text, softWrap: true, maxLines: 5,  textAlign: TextAlign.justify, style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget title(String text) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
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
              Text(title, style: Theme.of(context).textTheme.titleLarge),
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
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