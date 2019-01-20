import "package:flutter/material.dart";

import "home_page.dart" show HomePage;

void main() => runApp(InstaCleaner());

class InstaCleaner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Insta Cleaner",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
