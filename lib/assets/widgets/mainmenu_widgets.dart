// Main Menu Widgets
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController searchController;
  const new({
    super.key,
    required this.searchController,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Functions',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        controller: widget.searchController,
      ),
    );
  }
}

class Features extends StatelessWidget {
  final Function() onTap;
  final String featureName;
  final IconData icon;
  final bool isActive;
  
  const new({
    super.key,
    required this.onTap,
    required this.featureName,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isActive ? Colors.blue : Colors.white,
      child: InkWell(
        highlightColor: isActive ? null : Colors.black,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon),
              ),
              Text(featureName),
            ],
          ),
        ),
      ),
    );
  }
}

