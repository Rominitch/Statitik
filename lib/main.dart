import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:statitikcard/screen/cartes/card_statistic.dart';
import 'package:statitikcard/screen/wrapper.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/support.dart';
import 'package:statitikcard/screen/thanks.dart';
import 'package:statitikcard/services/internationalization.dart';

Future<void> main() async {
  // Enable AppCheck : API Integrity
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Build instance for first time
  runApp(const StatitikApp());
}

class StatitikApp extends StatelessWidget {
  const StatitikApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        colorScheme: ColorScheme.dark(secondary: Colors.orange[300]!),
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900]),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Colors.orange[300],
          selectionHandleColor: Colors.orange[300],
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.grey[600],
        //accentColor: Colors.orange[300],
        backgroundColor: Colors.grey[900],
        cardColor: Colors.grey[700],
        sliderTheme: SliderThemeData(activeTrackColor: Colors.orange[300], inactiveTickMarkColor: Colors.orange[300], thumbColor: Colors.orange[300],
                                     activeTickMarkColor: Colors.grey[900], inactiveTrackColor: Colors.grey[900]  ),
        //disabledColor: Colors.orange[200],
        textTheme: const TextTheme(
          headline1: TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 50.0,),
          headline3: TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 30.0,),
          headline4: TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 25.0,),
          headline5: TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 20.0,),
          headline6: TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 16.0,),
          bodyText2: TextStyle( color: Colors.white, fontSize: 16 ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states)
          {
              return states.contains(MaterialState.selected) ? Colors.orange[300]! : states.contains(MaterialState.disabled) ? Colors.grey[700] : Colors.white;
          }),
        ),
        radioTheme: RadioThemeData(fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states)
          {
            return states.contains(MaterialState.selected) ? Colors.orange[300]! : states.contains(MaterialState.disabled) ? Colors.grey[700] : Colors.white;
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: Colors.orange[500]!)
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.orange[300]),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.orange[300]!),
          ),
        ),
      ),
      title: 'StatitikCard',
      initialRoute: '/',
      localizationsDelegates: const [
        StatitikLocaleDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      builder: EasyLoading.init(),
      routes: {
        '/':        (context) => const ApplicationWidget(),
        '/home':    (context) => const ApplicationWidget(),
        '/stats':   (context) => StatsPage(),
        '/cards':   (context) => const CardStatisticPage(),
        '/support': (context) => const SupportPage(),
        '/thanks':  (context) => const ThanksPage(),
      }
    );
  }
}
