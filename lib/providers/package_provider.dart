import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/tour_package.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final packagesProvider = FutureProvider<List<TourPackage>>((ref) async {
  // Use 10.0.2.2 for Android emulator to access host localhost
  String baseUrl = 'http://localhost:8069';
  if (!kIsWeb && Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8069';
  }

  final url = Uri.parse('$baseUrl/api/packages');
  
  // Added headers and JSON-RPC body required by Odoo
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "jsonrpc": "2.0",
      "params": {}
    }),
  );

  if (response.statusCode == 200) {
    final dynamic data = jsonDecode(response.body);
    
    // Assuming the API returns a list of packages or an object with a 'data' array
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data')) {
      list = data['data'] as List<dynamic>;
    } else if (data is Map && data.containsKey('result')) { // Common for Odoo JSON-RPC
      list = data['result'] as List<dynamic>;
    } else {
      list = [];
    }
    
    return list.map((item) => TourPackage.fromJson(item as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load packages (Status ${response.statusCode})\n${response.body}');
  }
});

final packageDetailProvider = FutureProvider.family<TourPackage, int>((ref, packageId) async {
  String baseUrl = 'http://localhost:8069';
  if (!kIsWeb && Platform.isAndroid) {
    baseUrl = 'http://10.0.2.2:8069';
  }

  final url = Uri.parse('$baseUrl/api/package/detail');
  
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "jsonrpc": "2.0",
      "params": {
          "package_id": packageId
      }
    }),
  );

  if (response.statusCode == 200) {
    final dynamic data = jsonDecode(response.body);
    
    if (data is Map && data.containsKey('result')) {
      return TourPackage.fromJson(data['result'] as Map<String, dynamic>);
    } else {
      throw Exception('Unexpected JSON structure: missing result');
    }
  } else {
    throw Exception('Failed to load package detail (Status ${response.statusCode})');
  }
});
