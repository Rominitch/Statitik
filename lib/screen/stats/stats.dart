import 'package:flutter/material.dart';
import 'package:statitik_pokemon/screen/stats/filterExtension.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
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
                      child: Text('Langue'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FilterExtensions()));
                      },
                    ),
                  ),
                  Card(
                    child: FlatButton(
                      child: Text('Extension'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FilterExtensions()));
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
