import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:url_launcher/url_launcher.dart';

class ThanksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( 'Remerciements', style: Theme.of(context).textTheme.headline3, ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Un grand merci aux membres de Pokécardex pour leur aide et soutien:'),
            textBullet('Kyuubi'),
            textBullet('3l3ktr0'),
            FlatButton(
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
