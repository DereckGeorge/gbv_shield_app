import 'package:flutter/foundation.dart';

class IncidentType {
  final String id;
  final String name;
  final String? description;

  IncidentType({
    required this.id,
    required this.name,
    this.description,
  });

  factory IncidentType.fromJson(Map<String, dynamic> json) {
    return IncidentType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
} 