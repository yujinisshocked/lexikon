import 'package:flutter/material.dart';
import 'package:lexikon/pages/mainmenu.dart';
import 'package:lexikon/pages/settings.dart';

class MainView extends StatefulWidget {
  const new({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // Pages index
  int selectedIndex = 0;

  final List<Widget> _pages = [
    MainMenu(),
    Settings(),
  ];

  final List<String> _title = [
    "Main Menu",
    "Settings",
  ];
  
  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title[selectedIndex]),
        centerTitle: true,
      ),

      body: _pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu), 
            label: "Menu"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        onTap: changePage,
      ),
    );
  }
}
