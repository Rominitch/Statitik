import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:statitikcard/screen/cartes/card_statistic.dart';
import 'package:statitikcard/screen/wrapper.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/thanks.dart';
import 'package:statitikcard/services/internationalization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  configureEasyLoading();

  // Build instance for first time
  runApp(const StatitikApp());
}

void configureEasyLoading() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = false;
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
        colorScheme: ColorScheme.dark(secondary: Colors.orange.shade300, background: Colors.grey.shade900),
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade900),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Colors.orange.shade300,
          selectionHandleColor: Colors.orange.shade300,
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.grey.shade600,
        cardColor: Colors.grey.shade700,
        sliderTheme: SliderThemeData(activeTrackColor: Colors.orange.shade300, inactiveTickMarkColor: Colors.orange.shade300, thumbColor: Colors.orange.shade300,
                                     activeTickMarkColor: Colors.grey.shade900, inactiveTrackColor: Colors.grey.shade900 ),
        //disabledColor: Colors.orange[200],
        textTheme: const TextTheme(
          displayLarge:   TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 50.0),
          displaySmall:   TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 30.0),
          headlineMedium: TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 25.0),
          headlineSmall:  TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 20.0),
          titleLarge:     TextStyle( color: Colors.white, fontFamily: 'Pacifico', fontSize: 16.0),
          bodyMedium:     TextStyle( color: Colors.white, fontSize: 16 ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states)
          {
              return states.contains(MaterialState.selected) ? Colors.orange.shade300 : states.contains(MaterialState.disabled) ? Colors.grey[700] : Colors.white;
          }),
        ),
        radioTheme: RadioThemeData(fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states)
          {
            return states.contains(MaterialState.selected) ? Colors.orange.shade300 : states.contains(MaterialState.disabled) ? Colors.grey[700] : Colors.white;
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[500]!)
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.orange.shade300),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.orange.shade300),
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
        '/thanks':  (context) => const ThanksPage(),
      }
    );
  }
}
