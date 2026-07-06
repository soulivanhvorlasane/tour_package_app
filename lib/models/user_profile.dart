import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UserProfile {
  final int id;
  final String name;
  final String? email;
  final String? imageUrl;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.imageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? json['login'],
      imageUrl: json['profile_image'] ?? json['image_url'] ?? json['image_1920'],
    );
  }

  ImageProvider? get profileImageProvider {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    
    // Check if it's a URL
    if (imageUrl!.startsWith('http') || imageUrl!.startsWith('/')) {
      String finalUrl = imageUrl!;
      
      // Fix host for emulators
      if (!kIsWeb && Platform.isAndroid) {
        finalUrl = finalUrl.replaceAll('http://localhost:', 'http://10.0.2.2:')
                           .replaceAll('http://soulivanh:', 'http://10.0.2.2:');
      } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        finalUrl = finalUrl.replaceAll('http://soulivanh:', 'http://localhost:');
      }

      return NetworkImage(finalUrl);
    }
    
    // Otherwise it's base64 from Odoo
    try {
      // Sometimes Odoo base64 strings have newlines or padding issues, but usually fine
      return MemoryImage(base64Decode(imageUrl!.replaceAll('\n', '')));
    } catch (e) {
      return null;
    }
  }
}
