---
name: call-login-with-state-riverpod
description: A comprehensive, zero-to-hero guide on implementing a complete Authentication flow (Login/Logout) using Riverpod State Management and SharedPreferences.
---

# Implementing Login with Riverpod State Management (Zero to Hero)

This skill provides a complete guide on how to build a robust authentication system using Riverpod. It covers defining the state, making the API calls, persisting the session token securely, and reacting to state changes in the UI.

## 1. Prerequisites

Add the required dependencies to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  http: ^1.2.0
  shared_preferences: ^2.2.2
```

## 2. Define the Authentication State

Create an immutable state class that holds the current status, the authentication token, and any potential error messages.

**`lib/providers/auth_provider.dart` (Part 1)**
```dart
enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

## 3. Create the AuthNotifier

Create a `Notifier` that manages the `AuthState`. This is where all the business logic (API calls and Shared Preferences) happens.

**`lib/providers/auth_provider.dart` (Part 2)**
```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends Notifier<AuthState> {
  static const _tokenKey = 'auth_token';

  @override
  AuthState build() {
    _init(); // Load token from disk on startup
    return const AuthState();
  }

  // 1. Check for existing session
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(status: AuthStatus.authenticated, token: token);
    }
  }

  // 2. Perform Login
  Future<void> login(String username, String password) async {
    // Set state to loading to show a spinner in the UI
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final url = Uri.parse('http://localhost:8069/api/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'params': {
            'username': username,
            'password': password,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('result') && data['result']['token'] != null) {
          final token = data['result']['token'] as String;
          
          // Save token to disk
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          
          // Update state to authenticated
          state = state.copyWith(
            status: AuthStatus.authenticated,
            token: token,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: data['error']?['message'] ?? 'Login failed',
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Network error: $e',
      );
    }
  }

  // 3. Perform Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey); // Delete token from disk
    
    // Reset state back to initial
    state = const AuthState();
  }
}

// 4. Expose the Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
```

## 4. Building the UI

Now, consume the provider in your UI. The UI will automatically rebuild when `state.status` changes!

**`lib/screens/login_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Watch the authentication state
    final authState = ref.watch(authProvider);

    // Listen for errors to show a SnackBar
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 24),
            
            // Show Loading Spinner OR Login Button based on State
            authState.status == AuthStatus.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      // Trigger the login method
                      ref.read(authProvider.notifier).login(
                            _emailController.text,
                            _passwordController.text,
                          );
                    },
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

## 5. Protecting Routes (Optional)

You can easily protect certain UI elements or redirect users using Riverpod in your routing or navigation logic:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
  final isLoggedIn = authState.status == AuthStatus.authenticated;

  return isLoggedIn ? const ProfileScreen() : const WelcomeScreen();
}
```
