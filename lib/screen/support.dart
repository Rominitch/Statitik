import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text( 'Support', style: Theme.of(context).textTheme.headline3, ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Pour des demandes d\'améliorations ou signaler des bugs:'),
                  FlatButton(
                      onPressed: () => _launchURL('https://github.com/Rominitch/Statitik'),
                      child: Center(child: Text('https://github.com/Rominitch/Statitik', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
                  ),
                  SizedBox(height: 16.0),
                  //Text('Vous pouvez aussi nous soutenir financièrement:'),
                  //Center(child: Text('https://github.com/Rominitch/Statitik', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                  SizedBox(height: 16.0),
                  Text('Pour d\'autres demandes, contactez-nous:'),
                  FlatButton(
                      onPressed: () => _launchURL('mailto:rominitch@gmail.com'),
                      child: Center(child: Text('rominitch@gmail.com', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
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
