import 'dart:io';
import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../models/incident_type.dart';
import '../models/incident_support.dart';
import '../services/incident_service.dart';
import '../services/api_service.dart';
import '../screens/auth/provider/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncidentProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  late final IncidentService _service;
  
  List<IncidentType> _incidentTypes = [];
  List<IncidentSupport> _incidentSupports = [];
  List<Incident> _userIncidents = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;
  bool _isInitialized = false;

  IncidentProvider(this._authProvider) {
    _initService();
  }

  Future<void> _initService() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiService = ApiService(prefs);
      _service = IncidentService(apiService);
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize service: $e';
      notifyListeners();
    }
  }

  List<IncidentType> get incidentTypes => _incidentTypes;
  List<IncidentSupport> get incidentSupports => _incidentSupports;
  List<Incident> get userIncidents => _userIncidents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadIncidentTypes() async {
    if (!_isInitialized) await _initService();
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _incidentTypes = await _service.getIncidentTypes();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load incident types: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadIncidentSupports() async {
    if (!_isInitialized) await _initService();
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Fetching incident supports...'); // Debug print
      _incidentSupports = await _service.getIncidentSupports();
      print('Received ${_incidentSupports.length} incident supports'); // Debug print
      
      notifyListeners();
    } catch (e) {
      print('Error loading incident supports: $e'); // Debug print
      _error = 'Failed to load incident supports: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserIncidents({
    bool refresh = false,
    String? status,
    String? incidentTypeId,
    String? incidentSupportId,
  }) async {
    if (!_isInitialized) await _initService();
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _userIncidents = [];
    }
    if (!_hasMore && !refresh) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final incidents = await _service.getUserIncidents(
        page: _currentPage,
        status: status,
        incidentTypeId: incidentTypeId,
        incidentSupportId: incidentSupportId,
      );

      if (incidents.isEmpty) {
        _hasMore = false;
      } else {
        _userIncidents.addAll(incidents);
        _currentPage++;
        _hasMore = incidents.length >= 10; // Assuming page size is 10
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user incidents: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Incident> reportIncident(Incident incident, String? evidenceFilePath) async {
    if (!_isInitialized) await _initService();
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newIncident = await _service.reportIncident(incident, evidenceFilePath);
      _userIncidents.insert(0, newIncident);
      notifyListeners();
      return newIncident;
    } catch (e) {
      _error = 'Failed to report incident: $e';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 