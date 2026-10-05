import 'dart:math';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/Admin/admin_page.dart';
import 'package:statitikcard/screenOld/Products/products_explorer.dart';

import 'package:statitikcard/screenOld/cartes/card_statistic.dart';
import 'package:statitikcard/screenOld/stats/stats.dart';
import 'package:statitikcard/screenOld/options.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_connexion.dart';
import 'package:statitikcard/screenOld/widgets/news_dialog.dart';
import 'package:statitikcard/services/news.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    final currentLocale = Localizations.localeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences.getInstance().then((prefs) {
        var latestId = prefs.getInt('LatestNews') ?? 0;
        News.readFromDB( currentLocale, latestId).then((news) {
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
      const ProductsExplorer(),
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
          backgroundColor: useDebug ? const Color.fromARGB(255,50, 0, 0) : Environment.instance.pkConfig().isMaintenance ? Colors.cyan[900] : Colors.grey[900],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_chart),
              label: AppLocalizations.of(context)!.h_t0,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insert_chart_outlined_rounded),
              label: AppLocalizations.of(context)!.h_t1,
            ),
            BottomNavigationBarItem(
              icon: const Icon(StatitikFont.font01Pokecard),
              label: AppLocalizations.of(context)!.h_t3,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.card_giftcard),
              label: AppLocalizations.of(context)!.h_t5,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)!.h_t2,
            ),
            if(Environment.instance.isAdministrator())
              BottomNavigationBarItem(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: AppLocalizations.of(context)!.h_t4,
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
