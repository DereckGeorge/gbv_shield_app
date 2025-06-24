import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
    return _user != null;
  }

  Future<bool> signup(String name, String email, String password) async {
    _user = await _authService.signup(name, email, password);
    notifyListeners();
    return _user != null;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
