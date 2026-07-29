import 'package:adaptive_navigation_view/adaptive_navigation_view.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:statitikcard/screenOld/Admin/admin_page.dart';
import 'package:statitikcard/screenOld/Products/products_explorer.dart';

import 'package:statitikcard/screenOld/cartes/card_statistic.dart';
import 'package:statitikcard/screenOld/stats/stats.dart';
import 'package:statitikcard/screenOld/options.dart';
import 'package:statitikcard/screenOld/PokeSpace/pokespace_connexion.dart';
import 'package:statitikcard/screenOld/widgets/news_dialog.dart';
import 'package:statitikcard/screens/page_expansions.dart';
import 'package:statitikcard/services/news.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/statitik_font_icons.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions;
  late final NavigationViewController _controller;
  List<News> _news = [];
  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      const DrawHomePage(),
      const PageExpansions(),
      const CardStatisticPage(),
      const ProductsExplorer(),
      const OptionsPage(),
      if(Environment.instance.isAdministrator())
        const AdminPage(),
    ];

    _controller = NavigationViewController(
      length: Environment.instance.isAdministrator() ? 6 : 5,
      initialIndex: 1,
      destinationType: DestinationTypes.byIndex,
      onDestinationIndex: (index) {
        setState(() => _selectedIndex = index ?? 0);
      },
      vsync: this,
    );

    SharedPreferences.getInstance().then((prefs) {
      var latestId = prefs.getInt('LatestNews') ?? 0;
      News.readFromDB(Environment.instance.locale, latestId).then((news) {
          setState(() {
            if (news.isNotEmpty) {
              prefs.setInt('LatestNews', news[0].id);
              _news = news;
            }
          });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: SafeArea( child: NavigationView(
          controller: _controller,
          appBar: NavigationAppBar(
            title: Text(Environment.instance.nameApp),
          ),
          pane: NavigationPane(
            destinations: [
              PaneItemDestination(
                icon: const Icon(Icons.add_chart),
                label: Text(StatitikLocale.of(context).read('H_T0')),
              ),
              PaneItemDestination(
                icon: const Icon(Icons.insert_chart_outlined_rounded),
                label: Text(StatitikLocale.of(context).read('H_T1')),
              ),
              PaneItemDestination(
                icon: const Icon(StatitikFont.font01Pokecard),
                label: Text(StatitikLocale.of(context).read('H_T3')),
              ),
              PaneItemDestination(
                icon: const Icon(Icons.card_giftcard),
                label: Text(StatitikLocale.of(context).read('H_T5')),
              ),
              PaneItemDestination(
                icon: const Icon(Icons.settings),
                label: Text(StatitikLocale.of(context).read('H_T2')),
              ),
              if(Environment.instance.isAdministrator())
              PaneItemDestination(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: Text(StatitikLocale.of(context).read('H_T4')),
              ),
            ],
          ),
          body: _widgetOptions[_selectedIndex],
        ),
        ),
      );
    });
  }
}
