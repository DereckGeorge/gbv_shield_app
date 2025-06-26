import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/emergency_contact.dart';

class EmergencyService {
  final String? token;
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  EmergencyService({this.token});

  Future<List<EmergencyContact>> getNearbyContacts({
    required double latitude,
    required double longitude,
    double? radius,
    String? type,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (radius != null) 'radius': radius.toString(),
      if (type != null) 'type': type,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/api/emergency-contacts/nearby').replace(queryParameters: queryParams),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EmergencyContact.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nearby emergency contacts');
    }
  }
} 