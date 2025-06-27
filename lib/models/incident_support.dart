import 'package:flutter/foundation.dart';

class IncidentSupport {
  final String id;
  final String name;
  final String? description;

  IncidentSupport({
    required this.id,
    required this.name,
    this.description,
  });

  factory IncidentSupport.fromJson(Map<String, dynamic> json) {
    return IncidentSupport(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
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