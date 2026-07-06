import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    // Wrapping the entire app in ProviderScope is required by Riverpod
    const ProviderScope(
      child: TourApp(),
    ),
  );
}

class TourApp extends StatelessWidget {
  const TourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
    );
  }
}
