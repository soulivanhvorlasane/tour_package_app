import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final loginUrl = Uri.parse('http://localhost:8069/api/login');
  final loginRes = await http.post(loginUrl, 
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'jsonrpc': '2.0', 'params': {'username': 'admin', 'password': 'admin'}})
  );

  final token = jsonDecode(loginRes.body)['result']['token'];
  print('Token: $token');

  final profileUrl = Uri.parse('http://localhost:8069/api/user/profile');
  final profileRes = await http.post(profileUrl, 
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Access-Token': token
    },
    body: jsonEncode({'jsonrpc': '2.0', 'params': {}})
  );

  final data = jsonDecode(profileRes.body);
  final profileData = data['result'] ?? data;
  
  final profileImage = profileData['profile_image'] ?? profileData['image_url'] ?? profileData['image_1920'];
  
  if (profileImage == null) {
    print('Image is null');
  } else if (profileImage is bool) {
    print('Image is boolean: $profileImage');
  } else if (profileImage is String) {
    print('Image is String, length: ${profileImage.length}');
    if (profileImage.length > 50) {
      print('Start: ${profileImage.substring(0, 50)}');
    } else {
      print('Content: $profileImage');
    }
  } else {
    print('Image is of type: ${profileImage.runtimeType}');
  }
}
