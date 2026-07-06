import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  String baseUrl = 'http://localhost:8069';
  
  // 1. Login
  final loginResponse = await http.post(
    Uri.parse('$baseUrl/api/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'jsonrpc': '2.0',
      'params': {
        'username': 'admin',
        'password': 'admin',
      }
    }),
  );

  final loginData = jsonDecode(loginResponse.body);
  final token = loginData['result']['token'];

  // 2. Fetch Profile with POST jsonrpc
  final profileResponse = await http.post(
    Uri.parse('$baseUrl/api/user/profile'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Access-Token': token,
    },
    body: jsonEncode({
      'jsonrpc': '2.0',
      'params': {}
    }),
  );

  print('Profile status: ${profileResponse.statusCode}');
  
  if (profileResponse.statusCode == 200) {
    String profileString = profileResponse.body;
    if (profileString.length > 500) {
      profileString = profileString.substring(0, 500) + '...';
    }
    print('Profile Data: $profileString');
  } else {
    print('Profile error: ${profileResponse.body}');
  }
}
