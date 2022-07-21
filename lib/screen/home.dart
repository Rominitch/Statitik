import 'dart:math';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/screen/Admin/admin_page.dart';

import 'package:statitikcard/screen/cartes/card_statistic.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/options.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_connexion.dart';
import 'package:statitikcard/screen/widgets/news_dialog.dart';
import 'package:statitikcard/services/news.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    _widgetOptions = [
      const DrawHomePage(),
      StatsPage(),
      const CardStatisticPage(),
      const OptionsPage(),
      if(Environment.instance.isAdministrator())
        const AdminPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(min(_widgetOptions.length, _selectedIndex)),
        ),
      ),
      bottomNavigationBar:
       BottomNavigationBar(
          backgroundColor: useDebug ? const Color.fromARGB(255,50, 0, 0) : Environment.instance.isMaintenance ? Colors.cyan[900] : Colors.grey[900],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_chart),
              label: StatitikLocale.of(context).read('H_T0'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insert_chart_outlined_rounded),
              label: StatitikLocale.of(context).read('H_T1'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(StatitikFont.font01Pokecard),
              label: StatitikLocale.of(context).read('H_T3'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: StatitikLocale.of(context).read('H_T2'),
            ),
            if(Environment.instance.isAdministrator())
              BottomNavigationBarItem(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: StatitikLocale.of(context).read('H_T4'),
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
