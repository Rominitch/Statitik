import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:statitikcard/screen/Cartes/CardStatistic.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/options.dart';
import 'package:statitikcard/screen/tirage/draw_connexion.dart';
import 'package:statitikcard/screen/widgets/NewsDialog.dart';
import 'package:statitikcard/services/News.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      DrawHomePage(),
      StatsPage(),
      CardStatisticPage(),
      OptionsPage(),
    ];

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      SharedPreferences.getInstance().then((prefs) {
        var latestId = prefs.getInt('LatestNews') ?? 0;
        News.readFromDB(StatitikLocale
            .of(context)
            .locale, latestId).then((news) {
          if (news.isNotEmpty) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return createNewDialog(context, news);
                }
            );
            prefs.setInt('LatestNews', news[0].id);
          }
        });
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar:
       BottomNavigationBar(
          backgroundColor: useDebug ? Color.fromARGB(255,50, 0, 0) : Colors.grey[900],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_chart),
              label: StatitikLocale.of(context).read('H_T0'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined_rounded),
              label: StatitikLocale.of(context).read('H_T1'),
            ),
            BottomNavigationBarItem(
              icon: Icon(StatitikFont.font_01_pokecard),
              label: StatitikLocale.of(context).read('H_T3'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: StatitikLocale.of(context).read('H_T2'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          selectedFontSize: 12.0,
          unselectedFontSize: 10.0,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        )
      //),
    );
  }
}
