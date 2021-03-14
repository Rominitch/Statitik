import 'package:flutter/material.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text( StatitikLocale.of(context).read('O_B4'), style: Theme.of(context).textTheme.headline3, ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(StatitikLocale.of(context).read('SU_B0')),
                  TextButton(
                      onPressed: () => _launchURL('https://github.com/Rominitch/Statitik'),
                      child: Center(child: Text('https://github.com/Rominitch/Statitik', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
                  ),
                  SizedBox(height: 16.0),
                  //Text(StatitikLocale.of(context).read('SU_B2')),
                  //Center(child: Text('https://github.com/Rominitch/Statitik', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                  SizedBox(height: 16.0),
                  Text(StatitikLocale.of(context).read('SU_B1')),
                  TextButton(
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
