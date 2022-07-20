import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text( StatitikLocale.of(context).read('O_B4'), style: Theme.of(context).textTheme.headline3, ),
        ),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(StatitikLocale.of(context).read('SU_B0')),
                  const SizedBox(height: 16.0),
                  Card(
                    child:TextButton(
                        onPressed: () => Environment.launchURL(Uri.parse('https://github.com/Rominitch/Statitik')),
                        child: const Center(child: Text('https://github.com/Rominitch/Statitik', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
                    )
                  ),
                  const SizedBox(height: 16.0),
                  Text(StatitikLocale.of(context).read('SU_B1')),
                  const SizedBox(height: 16.0),
                  Card(
                    child: TextButton(
                      onPressed: () => Environment.launchURL(Uri.parse('mailto:rominitch@gmail.com')),
                      child: const Center(child: Text('rominitch@gmail.com', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
                    ),
                  ),
                ]
              )
          ),
        )
    );
  }
}
