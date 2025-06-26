import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_service.dart';
import '../screens/auth/provider/auth_provider.dart';

class EmergencyProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final EmergencyService _service;
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  EmergencyProvider(this._authProvider)
      : _service = EmergencyService(token: _authProvider.token);

  List<EmergencyContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNearbyContacts({
    double? radius,
    String? type,
  }) async {
    try {
      if (_currentPosition == null) {
        await getCurrentLocation();
      }

      if (_currentPosition == null) {
        throw Exception('Could not get current location');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      _contacts = await _service.getNearbyContacts(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: radius,
        type: type,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start real-time location updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) {
      _currentPosition = position;
      notifyListeners();
      return position;
    });
  }
} 