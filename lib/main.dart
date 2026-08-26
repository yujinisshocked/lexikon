import 'package:flutter/material.dart';
import 'package:lexikon/mainview.dart';

void main() {
  runApp(Lexikon());
}

class Lexikon extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainView());
  }
}
