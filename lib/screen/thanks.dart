import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:url_launcher/url_launcher.dart';

class ThanksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read('O_B3'), style: Theme.of(context).textTheme.headline3, ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(StatitikLocale.of(context).read('TH_B0')),
            textBullet('Kyuubi'),
            textBullet('3l3ktr0'),
            TextButton(
                onPressed: () => _launchURL('https://www.pokecardex.com'),
                child: Center(child: Text('https://www.pokecardex.com', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
            ),
          ]
        )
      )
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
