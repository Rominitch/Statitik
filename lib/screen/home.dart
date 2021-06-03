import 'package:flutter/material.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/options.dart';
import 'package:statitikcard/screen/tirage/draw_connexion.dart';
import 'package:statitikcard/services/internationalization.dart';

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
      OptionsPage(),
    ];
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
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
            icon: Icon(Icons.settings),
            label: StatitikLocale.of(context).read('H_T2'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
