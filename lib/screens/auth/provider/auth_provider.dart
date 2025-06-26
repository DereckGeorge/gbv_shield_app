import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/auth_service.dart';
import '../../../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load token from storage
      _token = await StorageService.getToken();
      print('Loaded token from storage: $_token');
      
      // Load user data if token exists
      if (_token != null) {
        final userData = await StorageService.getUser();
        if (userData != null) {
          _user = User.fromJson(userData);
          print('Loaded user from storage: ${_user?.name}');
        }
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
      _error = 'Error initializing authentication';
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _setError('Email and password are required');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      print('Attempting login with email: $email');
      final result = await _authService.login(email, password);
      print('Login result: $result');
      
      if (result['success']) {
        _user = result['user'] as User;
        _token = result['token'] as String;
        
        print('Login successful. Token: $_token');
        print('User: ${_user?.name}');
        
        // Save user data and token
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!.toJson());
        
        _setLoading(false);
        return true;
      } else {
        final message = result['message'] ?? 'Login failed';
        print('Login failed: $message');
        _setError(message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _setError('All fields are required');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      print('Attempting registration with email: $email');
      final result = await _authService.register(name, email, password);
      print('Registration result: $result');
      
      if (result['success']) {
        _user = result['user'] as User;
        _token = result['token'] as String;
        
        print('Registration successful. Token: $_token');
        print('User: ${_user?.name}');
        
        // Save user data and token
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!.toJson());
        
        _setLoading(false);
        return true;
      } else {
        final message = result['message'] ?? 'Registration failed';
        print('Registration failed: $message');
        _setError(message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    if (email.isEmpty) {
      _setError('Email is required');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.requestOtp(email);
      _setLoading(false);
      
      if (result['success']) {
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      print('Password reset request error: $e');
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      _setError('All fields are required');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.resetPassword(email, otp, newPassword);
      _setLoading(false);
      
      if (result['success']) {
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      print('Password reset error: $e');
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      print('Logging out...');
      await StorageService.clearAll();
      _user = null;
      _token = null;
      print('Logout successful');
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
      _setError('Error logging out');
    }
  }
}
 