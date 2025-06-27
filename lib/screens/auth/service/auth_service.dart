import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/user_model.dart';

class AuthService {
  final String baseUrl;

  AuthService() : baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Extract token and user data from response
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Create user object
        final user = User(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
        );

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // Extract token and user data from response
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Create user object
        final user = User(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
        );

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      } else {
        print('Registration failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': response.body,
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Failed to send OTP',
      };
    } catch (e) {
      print('OTP request error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
          'password': newPassword,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Failed to reset password',
      };
    } catch (e) {
      print('Password reset error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }
}
 