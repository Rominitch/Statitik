import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/cartes/card_statistic.dart';
import 'package:statitikcard/screenOld/options.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_connexion.dart';
import 'package:statitikcard/screenOld/widgets/news_dialog.dart';
import 'package:statitikcard/screens/admin/page_admin_menu.dart';
import 'package:statitikcard/screens/page_expansions.dart';
import 'package:statitikcard/screens/products/page_products_explorer.dart';
import 'package:statitikcard/services/news.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

class NavigationData {
  final String  label;
  final IconData icon;

  const NavigationData({required this.icon, required this.label});
}

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions;
  List<News> _news = [];
  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      const DrawHomePage(),
      const PageExpansions(),
      const CardStatisticPage(),
      PageProductsExplorer.view(Environment.instance.pkCollection(), Environment.instance.pkRendering()),
      const OptionsPage(),
      if(Environment.instance.isAdministrator())
        PageAdminMenu(Environment.instance.pkCollection(), Environment.instance.pkRendering(), Environment.instance.pkDB()),
    ];

    final locale = null; //Localizations.maybeLocaleOf(context);
    if(locale != null) {
      SharedPreferences.getInstance().then((prefs) {
        var latestId = prefs.getInt('LatestNews') ?? 0;
        News.readFromDB(locale, latestId).then((news) {
          setState(() {
            if (news.isNotEmpty) {
              prefs.setInt('LatestNews', news[0].id);
              _news = news;
            }
          });
        });
      });
    }
  }

  List<NavigationData> navigation(BuildContext context) {
    return [
      NavigationData(
        icon: Icons.add_chart,
        label: AppLocalizations.of(context)!.h_t0,
      ),
      NavigationData(
        icon: Icons.insert_chart_outlined_rounded,
        label: AppLocalizations.of(context)!.h_t1,
      ),
      NavigationData(
        icon: StatitikFont.font01Pokecard,
        label: AppLocalizations.of(context)!.h_t3,
      ),
      NavigationData(
        icon: Icons.card_giftcard,
        label: AppLocalizations.of(context)!.h_t5,
      ),
      NavigationData(
        icon: Icons.settings,
        label: AppLocalizations.of(context)!.h_t2,
      ),
      if(Environment.instance.isAdministrator() && Platform.isWindows)
        NavigationData(
          icon: Icons.admin_panel_settings_outlined,
          label: AppLocalizations.of(context)!.h_t4,
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_news.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return createNewDialog(context, _news);
          }
      ).whenComplete( (){
          _news = [];
        }
      );
    }
    final nav = navigation(context);
    return LayoutBuilder(builder: (context, constraints) {
      if( !Platform.isWindows || constraints.minWidth < 500 ) {
        return Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            indicatorColor: Colors.amber,
            selectedIndex: _selectedIndex,
            destinations: List<NavigationDestination>.generate(nav.length,
                (id){
                  final item = nav[id];
                  return NavigationDestination(icon: Icon(item.icon), label: item.label);
                },)
          ),
          body: SafeArea(
            child: _widgetOptions[_selectedIndex]
          )
        );
      } else {
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  destinations: List<NavigationRailDestination>.generate(nav.length,
                  (id) {
                    final item = nav[id];
                    return NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label));
                  }),
                  labelType: NavigationRailLabelType.all,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }
                ),
                Expanded(
                  child: _widgetOptions[_selectedIndex]
                ),
              ]
          ),
          ),
        );
      }
    });
  }
}
