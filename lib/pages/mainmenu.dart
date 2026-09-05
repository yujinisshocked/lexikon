import 'package:flutter/material.dart';
import 'package:lexikon/utils/helpers/variables_helpers.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // List of features with their respective icons and labels
  List<dynamic> features = VariablesHelpers().features;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                // Handle feature navigation
                final route = features[index]['route'];
                  Navigator.pushNamed(context, route);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    features[index]['icon'],
                    size: 40.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    features[index]['label'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DesktopMenu extends StatefulWidget {
  final Widget currDesktop;
  const new({
    super.key,
    required this.currDesktop,
  });

  @override
  State<DesktopMenu> createState() => _DesktopMenuState();
}

class _DesktopMenuState extends State<DesktopMenu> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: widget.currDesktop,
      ),
    );
  }
}