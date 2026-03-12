import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> fetchPetCareTip() async {
    try {
      final url = Uri.parse('https://catfact.ninja/fact');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['fact'] as String;
      } else {
        throw Exception('Failed to load pet care tip');
      }
    } catch (e) {
      return 'Pet care tip unavailable at the moment.';
    }
  }
}
