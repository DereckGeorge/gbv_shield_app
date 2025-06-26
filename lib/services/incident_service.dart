import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/incident.dart';
import '../models/incident_type.dart';
import '../models/incident_support.dart';
import '../services/api_service.dart';

class IncidentService {
  final ApiService _apiService;

  IncidentService(this._apiService);

  Future<List<IncidentType>> getIncidentTypes() async {
    final response = await _apiService.get('/api/incident-types', requiresAuth: true);
    return (response as List).map((json) => IncidentType.fromJson(json)).toList();
  }

  Future<List<IncidentSupport>> getIncidentSupports() async {
    final response = await _apiService.get('/api/incident-supports', requiresAuth: true);
    return (response as List).map((json) => IncidentSupport.fromJson(json)).toList();
  }

  Future<List<Incident>> getUserIncidents({
    int? page,
    String? status,
    String? incidentTypeId,
    String? incidentSupportId,
  }) async {
    final queryParams = {
      if (page != null) 'page': page.toString(),
      if (status != null) 'status': status,
      if (incidentTypeId != null) 'incident_type_id': incidentTypeId,
      if (incidentSupportId != null) 'incident_support_id': incidentSupportId,
    };
    
    final endpoint = Uri(
      path: '/api/incidents/my-reports',
      queryParameters: queryParams,
    ).toString();
    
    final response = await _apiService.get(endpoint, requiresAuth: true);
    return (response['data'] as List).map((json) => Incident.fromJson(json)).toList();
  }

  Future<Incident> reportIncident(Incident incident, String? evidenceFilePath) async {
    final response = await _apiService.postMultipart(
      '/api/incidents',
      incident.toJson(),
      evidenceFilePath,
      requiresAuth: true,
    );
    return Incident.fromJson(response['incident']);
  }
} 