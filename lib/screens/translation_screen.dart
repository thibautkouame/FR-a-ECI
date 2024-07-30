import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/translation_widget.dart'; // Assure-toi que le chemin est correct

class TranslationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TranslationWidget(
          text: 'Bonjour', // Texte d'exemple
          langPair: 'fr-en', // Paire de langues d'exemple
        ),
      ),
    );
  }
}
