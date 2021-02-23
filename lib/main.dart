import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:statitikcard/screen/Wrapper.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/support.dart';
import 'package:statitikcard/screen/thanks.dart';
import 'package:statitikcard/services/internationalization.dart';

void main() {
  // Build instance for first time
  runApp(StatitikApp());
}

class StatitikApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.grey[600],
        accentColor: Colors.orange[300],
        backgroundColor: Colors.grey[900],
        cardColor: Colors.grey[700],
        textTheme: TextTheme(
          headline1: TextStyle( color: Colors.grey[400], fontFamily: 'Pacifico', fontSize: 50.0,),
          headline3: TextStyle( fontFamily: 'Pacifico', fontSize: 30.0,),
          headline5: TextStyle( fontFamily: 'Pacifico', fontSize: 20.0,),
          bodyText2: TextStyle( fontSize: 16 ),
        ),
      ),
      title: 'StatitikCard',
      initialRoute: '/',
      localizationsDelegates: [
        const StatitikLocaleDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
      ],
      routes: {
        '/': (context) => ApplicationWidget(),
        '/home': (context) => Wrapper(),
        '/stats': (context) => StatsPage(),
        '/support': (context) => SupportPage(),
        '/thanks': (context) => ThanksPage(),
      }
    );
  }
}
