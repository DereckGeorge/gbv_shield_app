import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gbv_field/models/emergency_contact.dart';
import 'package:gbv_field/services/emergency_contact_service.dart';
import 'package:gbv_field/utils/permission_handler.dart';

class EmergencyContactProvider with ChangeNotifier {
  final EmergencyContactService _service;
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  EmergencyContactProvider(this._service);

  List<EmergencyContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool hasPermission = await PermissionUtil.checkAndRequestLocationPermission();
      if (!hasPermission) {
        _error = 'Location permission denied';
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get current location: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNearbyContacts({
    double? latitude,
    double? longitude,
    double radius = 10.0,
    String? type,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // If no coordinates provided, try to get current location
      if (latitude == null || longitude == null) {
        await getCurrentLocation();
        if (_currentPosition == null) {
          _error = 'Could not get current location';
          notifyListeners();
          return;
        }
        latitude = _currentPosition!.latitude;
        longitude = _currentPosition!.longitude;
      }

      _contacts = await _service.getNearbyContacts(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: type,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load nearby contacts: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startLocationUpdates() async {
    bool hasPermission = await PermissionUtil.checkAndRequestLocationPermission();
    if (!hasPermission) {
      _error = 'Location permission denied';
      notifyListeners();
      return;
    }

    // Get location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        loadNearbyContacts(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      },
      onError: (e) {
        _error = 'Location stream error: $e';
        notifyListeners();
      },
    );
  }
} 