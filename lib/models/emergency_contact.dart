import 'package:flutter/foundation.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? description;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.description,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      description: json['description'],
      type: json['type'],
      address: json['address'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      distanceKm: json['distance_km'] != null 
        ? double.parse(json['distance_km'].toString())
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'description': description,
      'type': type,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
    };
  }
} 