import '../model/user_model.dart';

class AuthService {
  static final List<User> _mockUsers = [
    User(name: 'Zawada', email: 'zawada@example.com'),
  ];

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      return _mockUsers.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<User?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = User(name: name, email: email);
    _mockUsers.add(user);
    return user;
  }
}
