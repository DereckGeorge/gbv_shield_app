import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/learn.dart';
import '../models/learn_category.dart';

class LearnService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final String? token;

  LearnService({this.token});

  Future<List<LearnCategory>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/learn-categories'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LearnCategory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Map<String, dynamic>> getLearns({String? categoryId, int page = 1}) async {
    final queryParams = {
      if (categoryId != null) 'category_id': categoryId,
      'page': page.toString(),
    };

    final response = await http.get(
      Uri.parse('$baseUrl/api/learns').replace(queryParameters: queryParams),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'data': (data['data'] as List).map((json) => Learn.fromJson(json)).toList(),
        'current_page': data['current_page'],
        'last_page': data['last_page'],
        'total': data['total'],
      };
    } else {
      throw Exception('Failed to load learns');
    }
  }

  Future<bool> toggleLike(String learnId) async {
    if (token == null) throw Exception('Authentication required');

    final response = await http.post(
      Uri.parse('$baseUrl/api/learns/$learnId/toggle-like'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to toggle like');
    }
  }

  Future<bool> markAsRead(String learnId) async {
    if (token == null) throw Exception('Authentication required');

    final response = await http.post(
      Uri.parse('$baseUrl/api/learns/$learnId/mark-as-read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to mark as read');
    }
  }
} 