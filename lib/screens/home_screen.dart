import 'package:flutter/material.dart';
import 'translation_screen.dart'; // Assure-toi que le chemin est correct

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TranslationScreen()),
            );
          },
          child: Text('Go to Translation'),
        ),
      ),
    );
  }
}
