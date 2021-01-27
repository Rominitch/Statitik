import 'package:flutter/material.dart';
import 'package:statitikcard/screen/Wrapper.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/services/environment.dart';

void main() {
  // Build instance for first time
  Environment env = Environment.instance;

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
        textTheme: TextTheme(
          headline1: TextStyle( color: Colors.grey[400], fontFamily: 'Pacifico', fontSize: 50.0,),
          headline3: TextStyle( fontFamily: 'Pacifico', fontSize: 30.0,),
          headline5: TextStyle( fontFamily: 'Pacifico', fontSize: 20.0,),
        ),
      ),
      title: 'StatitikCard',
      initialRoute: '/',
      routes: {
        '/': (context) => ApplicationWidget(),
        '/home': (context) => Wrapper(),
        '/stats': (context) => StatsPage(),
      }
    );
  }
}
