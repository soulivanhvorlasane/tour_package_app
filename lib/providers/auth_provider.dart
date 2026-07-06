import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class AuthNotifier extends Notifier<AuthState> {
  static const _tokenKey = 'auth_token';

  @override
  AuthState build() {
    _init();
    return const AuthState();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(status: AuthStatus.authenticated, token: token);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      String baseUrl = 'http://localhost:8069';
      if (!kIsWeb && Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:8069';
      }
      final url = Uri.parse('$baseUrl/api/login');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'params': {
            'username': email,
            'password': password,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('result') && data['result'] != null && data['result'].containsKey('token')) {
          final token = data['result']['token'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          
          state = state.copyWith(
            status: AuthStatus.authenticated,
            token: token,
          );
        } else if (data.containsKey('error')) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: data['error']['message'] ?? 'Login failed',
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid response from server',
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An error occurred: $e',
      );
    }
  }

  Future<void> logout() async {
    if (state.token != null) {
      try {
        String baseUrl = 'http://localhost:8069';
        if (!kIsWeb && Platform.isAndroid) {
          baseUrl = 'http://10.0.2.2:8069';
        }
        
        await http.post(
          Uri.parse('$baseUrl/api/user/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${state.token}',
            'Access-Token': state.token!,
          },
          body: jsonEncode({
            'jsonrpc': '2.0',
            'params': {}
          }),
        );
      } catch (e) {
        // ignore errors on logout, just proceed to clear local state
        print('Logout error: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
