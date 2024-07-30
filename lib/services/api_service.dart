import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl =
      'https://thibautkouame.github.io/savemybrain_api/api_test_save_mybrain.py';

  Future<Map<String, dynamic>> fetchTranslation(
      String text, String langPair) async {
    final response =
        await http.get(Uri.parse('$apiUrl?text=$text&langPair=$langPair'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load translation');
    }
  }
}
