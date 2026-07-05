import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coverProvider = Provider.family<String, String?>((ref, imageUrl) {
  String url = imageUrl ?? '';

  // 1. If package has no image, use default_cover.png
  if (url.isEmpty) {
    url = 'http://localhost:8069/tour_package/static/img/default_cover.png';
  }

  // 2. Fix host for emulators
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      url = url.replaceAll('http://localhost:', 'http://10.0.2.2:')
               .replaceAll('http://soulivanh:', 'http://10.0.2.2:');
    } else if (Platform.isIOS || Platform.isMacOS) {
      url = url.replaceAll('http://soulivanh:', 'http://localhost:');
    }
  }

  return url;
});
