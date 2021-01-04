import 'package:flutter/material.dart';
import 'package:statitik_pokemon/screen/languagePage.dart';
import 'package:statitik_pokemon/services/models.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Language language;
  SubExtension subExt;

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    setState(() {
      this.language = language;
      this.subExt   = subExt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Statistiques'),
        ),
        body: SafeArea(
          child:Column(
            children: [
              Row(
                children: [
                  Card(
                    child: FlatButton(
                      child: language != null ? Row(
                        children: [
                          Text('Extension'),
                          SizedBox(width: 8.0),
                          Image(image: language.create(), height: 30),
                          SizedBox(width: 8.0),
                          subExt.image(),
                      ]) : Text('Extension'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                      },
                    )
                  )
                ],
              ),
            ],
          )
        )
    );
  }
}
