import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TranslationWidget extends StatefulWidget {
  final String text;
  final String langPair;

  TranslationWidget({required this.text, required this.langPair});

  @override
  _TranslationWidgetState createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  String _translation = '';
  String _audioPath = '';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchTranslation();
  }

  Future<void> _fetchTranslation() async {
    // Simuler une requête API pour la démonstration
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _translation = 'Hello'; // Exemple de traduction
      _audioPath =
          'https://example.com/audio/hello.mp3'; // Exemple de chemin audio
    });
  }

  void _playAudio() {
    if (_audioPath.isNotEmpty) {
      _audioPlayer.play(AssetSource(
          _audioPath)); // Utiliser AssetSource pour les fichiers locaux
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Original Text: ${widget.text}'),
        SizedBox(height: 8.0),
        Text('Translation: $_translation'),
        SizedBox(height: 8.0),
        if (_audioPath.isNotEmpty)
          ElevatedButton(
            onPressed: _playAudio,
            child: Text('Play Audio'),
          ),
      ],
    );
  }
}
