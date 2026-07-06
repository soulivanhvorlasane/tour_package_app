import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'auth_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (authState.status != AuthStatus.authenticated || authState.token == null) {
    return null;
  }

  String baseUrl = 'http://localhost:8069';
  if (!kIsWeb && Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8069';
  }

  final url = Uri.parse('$baseUrl/api/user/profile');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authState.token}',
        'Access-Token': authState.token!,
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('result') && data['result'] != null) {
        return UserProfile.fromJson(data['result']);
      }
      return UserProfile.fromJson(data);
    }
  } catch (e) {
    print('Failed to load user profile: $e');
  }
  
  return null;
});

Future<bool> uploadProfileImage(WidgetRef ref, String base64Image) async {
  final authState = ref.read(authProvider);
  if (authState.token == null) return false;

  String baseUrl = 'http://localhost:8069';
  if (!kIsWeb && Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8069';
  }

  final url = Uri.parse('$baseUrl/api/user/profile/image');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authState.token}',
        'Access-Token': authState.token!,
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {
          'image': base64Image,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('result') && data['result'] != false) {
        // Invalidate to fetch the new profile image
        ref.invalidate(userProfileProvider);
        return true;
      }
    }
  } catch (e) {
    print('Failed to upload profile image: $e');
  }
  return false;
}
