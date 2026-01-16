import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  AdminService(this.baseUrl, this.accessToken);

  final String baseUrl;
  final String accessToken;

  bool? _cachedIsAdmin;

  Future<bool> isAdmin() async {
    if (_cachedIsAdmin != null) {
      return _cachedIsAdmin!;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/_synapse/room_service/is_admin'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to check admin status');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _cachedIsAdmin = data['is_admin'] == true;

    return _cachedIsAdmin!;
  }
}
