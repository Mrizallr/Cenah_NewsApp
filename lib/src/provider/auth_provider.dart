import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cenah_news/src/controllers/auth_controller.dart';
import 'package:cenah_news/src/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get token => _token;

  Future<void> initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        _token = token;
        _isAuthenticated = true;

        final userId = prefs.getString('user_id');
        final userEmail = prefs.getString('user_email');
        final userName = prefs.getString('user_name');
        final userTitle = prefs.getString('user_title');
        final userAvatar = prefs.getString('user_avatar');

        if (userId != null && userEmail != null && userName != null) {
          _currentUser = User(
            id: userId,
            email: userEmail,
            name: userName,
            title: userTitle ?? '',
            avatar: userAvatar ?? '',
          );
        }
        debugPrint('User initialized from SharedPreferences');
      }
    } catch (e, stack) {
      debugPrint('initAuth error: $e');
      debugPrint(stack.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Attempting login with email: $email');

      final response = await _authService.login(email, password);

      // Validasi response
      if (response.data.token.isEmpty || response.data.user.id.isEmpty) {
        throw Exception('Invalid response data');
      }

      await _saveAuthData(response.data);

      _isAuthenticated = true;
      debugPrint('Login successful for user: ${response.data.user.email}');

      return true;
    } on SocketException {
      debugPrint('Network error: No internet connection');
      rethrow;
    } on FormatException {
      debugPrint('Format error: Invalid server response');
      rethrow;
    } catch (e, stack) {
      debugPrint('Login error: $e');
      debugPrint(stack.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Registering user: ${userData['email']}');
      await _authService.register(userData);
      debugPrint('Registration successful');
      return true;
    } catch (e, stack) {
      debugPrint('Registration error: $e');
      debugPrint(stack.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove('auth_token'),
        prefs.remove('user_id'),
        prefs.remove('user_email'),
        prefs.remove('user_name'),
        prefs.remove('user_title'),
        prefs.remove('user_avatar'),
      ]);

      _isAuthenticated = false;
      _currentUser = null;
      _token = null;
      debugPrint('User logged out successfully');
    } catch (e, stack) {
      debugPrint('Logout error: $e');
      debugPrint(stack.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.setString('auth_token', userData.token),
        prefs.setString('user_id', userData.user.id),
        prefs.setString('user_email', userData.user.email),
        prefs.setString('user_name', userData.user.name),
        prefs.setString('user_title', userData.user.title),
        prefs.setString('user_avatar', userData.user.avatar),
      ]);

      _token = userData.token;
      _currentUser = userData.user;

      debugPrint('Auth data saved successfully');
    } catch (e, stack) {
      debugPrint('Save auth data error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }
}
