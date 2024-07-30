class TranslationResponse {
  final String translatedText;
  final String audioFilePath;

  TranslationResponse(
      {required this.translatedText, required this.audioFilePath});

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      translatedText: json['translated_text'],
      audioFilePath: json['audio_file_path'],
    );
  }
}
