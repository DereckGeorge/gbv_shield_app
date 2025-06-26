import 'package:gbv_field/models/emergency_contact.dart';
import 'package:gbv_field/services/api_service.dart';

class EmergencyContactService {
  final ApiService _apiService;

  EmergencyContactService(this._apiService);

  Future<List<EmergencyContact>> getNearbyContacts({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    String? type,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radius.toString(),
      if (type != null) 'type': type,
    };

    final response = await _apiService.get(
      '/api/emergency-contacts?${Uri(queryParameters: queryParams).query}'
    );

    return (response as List).map((json) => EmergencyContact.fromJson(json)).toList();
  }
} 