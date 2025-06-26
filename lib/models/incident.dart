import 'package:flutter/foundation.dart';
import 'package:gbv_field/models/incident_support.dart';
import 'package:gbv_field/models/incident_type.dart';

class Incident {
  final String? id;
  final String incidentTypeId;
  final String description;
  final DateTime incidentDate;
  final String? evidencePath;
  final String? evidenceType;
  final String? isFirstTime;
  final String? feelSafeNow;
  final String? incidentSupportId;
  final bool? likeToBeContacted;
  final String status;
  final String? adminNotes;
  final IncidentType? incidentType;
  final IncidentSupport? incidentSupport;

  Incident({
    this.id,
    required this.incidentTypeId,
    required this.description,
    required this.incidentDate,
    this.evidencePath,
    this.evidenceType,
    this.isFirstTime,
    this.feelSafeNow,
    this.incidentSupportId,
    this.likeToBeContacted,
    this.status = 'pending',
    this.adminNotes,
    this.incidentType,
    this.incidentSupport,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      incidentTypeId: json['incident_type_id'],
      description: json['description'],
      incidentDate: DateTime.parse(json['incident_date']),
      evidencePath: json['evidence_path'],
      evidenceType: json['evidence_type'],
      isFirstTime: json['is_first_time'],
      feelSafeNow: json['feel_safe_now'],
      incidentSupportId: json['incident_support_id'],
      likeToBeContacted: json['like_to_be_contacted'],
      status: json['status'] ?? 'pending',
      adminNotes: json['admin_notes'],
      incidentType: json['incident_type'] != null 
        ? IncidentType.fromJson(json['incident_type'])
        : null,
      incidentSupport: json['incident_support'] != null 
        ? IncidentSupport.fromJson(json['incident_support'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident_type_id': incidentTypeId,
      'description': description,
      'incident_date': incidentDate.toIso8601String(),
      'is_first_time': isFirstTime,
      'feel_safe_now': feelSafeNow,
      'incident_support_id': incidentSupportId,
      'like_to_be_contacted': likeToBeContacted,
    };
  }
} 