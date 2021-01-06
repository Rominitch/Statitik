import 'package:flutter/material.dart';
import 'package:statitikcard/screen/languagePage.dart';
import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/options.dart';
import 'package:statitikcard/screen/tirage/tirage_produit.dart';
import 'package:statitikcard/services/models.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  List<Widget> _widgetOptions;

  void goToProductPage(BuildContext context, Language language, SubExtension subExt) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage(language: language, subExt: subExt) ));
  }

  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      LanguagePage(afterSelected: goToProductPage),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_chart),
            label: 'Tirage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined_rounded),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Options',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
