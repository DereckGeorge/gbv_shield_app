import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/tip.dart';
import '../screens/auth/provider/auth_provider.dart';

class TipService {
  final String baseUrl;
  final AuthProvider authProvider;

  TipService(this.authProvider) : baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<Tip> getTipOfTheDay() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tips/today'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Tip.fromJson(data);
      } else {
        throw Exception('Failed to load tip of the day');
      }
    } catch (e) {
      throw Exception('Error fetching tip of the day: $e');
    }
  }

  Future<Map<String, dynamic>> toggleLike(String tipId) async {
    final token = authProvider.token;
    if (token == null) {
      throw Exception('Authentication required to like tips');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tips/$tipId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Please log in to like tips');
      } else {
        throw Exception('Failed to toggle like');
      }
    } catch (e) {
      throw Exception('Error toggling like: $e');
    }
  }
} 