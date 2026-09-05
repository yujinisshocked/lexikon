import 'package:flutter/material.dart' hide SearchBar;
import 'package:lexikon/pages/mainmenu.dart';
import 'package:lexikon/pages/settings.dart';
import 'package:lexikon/utils/helpers/platform_helpers.dart';
import 'package:lexikon/assets/widgets/widgets.dart';
import 'package:lexikon/utils/helpers/variables_helpers.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // Pages index
  int selectedIndex = 0;
  bool isDesktop = PlatformHelpers().isDesktop();

  final List<Widget> _pages = [
    const MainMenu(),
    const SettingsPage(),
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu), 
            label: "Menu"
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        onTap: changePage,
      ),
    );
  }
}

// ============================================================================
// DESKTOP VIEW
// ============================================================================

class DesktopView extends StatefulWidget {
  const new({super.key});

  @override
  State<DesktopView> createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView> {
  final TextEditingController searchController = TextEditingController();
  bool isActive = false;
  Widget? currDesktop;
  final List<dynamic> features = VariablesHelpers().features;
  int selectedIndex = -1;

  void onTap(int index) {
    setState(() {
      selectedIndex = index;
      currDesktop = features[index]['page'];
    });

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          FeatureBar(
            searchController: searchController, 
            features: features, 
            onTap: onTap,
            selectedIndex: selectedIndex, 
            featureName: '',
          ),
          DesktopMenu(
            currDesktop: currDesktop ?? Center(child: Text("Please select a feature."),),
          ),
        ],
      ),
    );
  }
}

// SideBar
class SideBar extends StatefulWidget {
  const new({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}

// FeatureBar
class FeatureBar extends StatefulWidget {
  final TextEditingController searchController;
  final List<dynamic> features;
  final Function(int index) onTap;
  final int selectedIndex;
  final String featureName;

  const new({
    super.key,
    required this.searchController,
    required this.features,
    required this.onTap,
    required this.selectedIndex,
    required this.featureName,
  });

  @override
  State<FeatureBar> createState() => _FeatureBarState();
}

class _FeatureBarState extends State<FeatureBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 35,
      child: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: Text("Lexikon"),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          // Search Bar
          children: [
            SearchBar(searchController: widget.searchController,),
            Expanded(
              child: ListView.builder(
                itemCount: widget.features.length,
                itemBuilder: (context, index) {
                  return Features(
                    onTap: () => widget.onTap(index),
                    featureName: widget.features[index]['label'], 
                    icon: widget.features[index]['icon'],
                    isActive: widget.selectedIndex == index,
                  );
                }
              ),
            )
          ],
          // Features
        ),
      ),
    );
  }
}