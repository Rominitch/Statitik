import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/services/environment.dart';

class ThanksPage extends StatelessWidget {
  const ThanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( AppLocalizations.of(context)!.o_b3, style: Theme.of(context).textTheme.displaySmall ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(context)!.th_b0),
              textBullet('Kyuubi'),
              textBullet('3l3ktr0'),
              const SizedBox(height: 16.0),
              Card(
                child: TextButton(
                  onPressed: () => Environment.launchURL(Uri.parse('https://www.pokecardex.com')),
                  child: const Center(child: Text('https://www.pokecardex.com', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
                ),
              ),
            ]
          )
        ),
      )
    );
  }
}
