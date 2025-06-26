import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  final SharedPreferences _prefs;

  ApiService(this._prefs) : baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      ..._headers,
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    final headers = requiresAuth ? await _authHeaders : _headers;
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to load data: ${response.body}');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data, {bool requiresAuth = false}) async {
    final headers = requiresAuth ? await _authHeaders : _headers;
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to create data: ${response.body}');
    }
  }

  Future<dynamic> postMultipart(String endpoint, Map<String, dynamic> data, String? filePath, {bool requiresAuth = false}) async {
    final headers = requiresAuth ? await _authHeaders : _headers;
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Add headers (except Content-Type which is set automatically for multipart)
    request.headers.addAll({
      'Accept': 'application/json',
      if (headers.containsKey('Authorization')) 
        'Authorization': headers['Authorization']!,
    });

    // Add file if provided
    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('evidence', filePath));
    }

    // Add other fields
    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again');
    } else {
      throw Exception('Failed to create data: ${response.body}');
    }
  }
} 