import 'dart:io';
import 'package:flutter/material.dart';

class Drug {
  final String id;
  final String name;
  final File? imageFile;
  final String? imagePath;

  Drug({
    required this.id, 
    required this.name, 
    this.imageFile,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imagePath: json['imagePath'],
    );
  }

  bool get hasImage => imageFile != null;
  bool get hasName => name.isNotEmpty;
  bool get isValid => hasImage || hasName;
}

class PatientInfo {
  final int? age;
  final List<String> conditions;

  PatientInfo({required this.age, required this.conditions});

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'conditions': conditions,
    };
  }

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      age: json['age'],
      conditions: List<String>.from(json['conditions'] ?? []),
    );
  }
}

class DrugInteractionResult {
  final List<String> drugsChecked;
  final String patientContext;
  final List<String> drugProfile;
  final List<String> adverseEffects;
  final List<String> mechanismOfAction;
  final RiskProfile riskProfile;

  DrugInteractionResult({
    required this.drugsChecked,
    required this.patientContext,
    required this.drugProfile,
    required this.adverseEffects,
    required this.mechanismOfAction,
    required this.riskProfile,
  });

  factory DrugInteractionResult.fromJson(Map<String, dynamic> json) {
    return DrugInteractionResult(
      drugsChecked: List<String>.from(json['drugsChecked'] ?? []),
      patientContext: json['patientContext'] ?? '',
      drugProfile: List<String>.from(json['drugProfile'] ?? []),
      adverseEffects: List<String>.from(json['adverseEffects'] ?? []),
      mechanismOfAction: List<String>.from(json['mechanismOfAction'] ?? []),
      riskProfile: RiskProfile.fromJson(json['riskProfile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drugsChecked': drugsChecked,
      'patientContext': patientContext,
      'drugProfile': drugProfile,
      'adverseEffects': adverseEffects,
      'mechanismOfAction': mechanismOfAction,
      'riskProfile': riskProfile.toJson(),
    };
  }
}

class RiskProfile {
  final String severity;
  final String action;

  RiskProfile({required this.severity, required this.action});

  factory RiskProfile.fromJson(Map<String, dynamic> json) {
    return RiskProfile(
      severity: json['severity'] ?? '',
      action: json['action'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'severity': severity,
      'action': action,
    };
  }

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'severe':
      case 'high':
        return const Color(0xFFDC2626); // Red
      case 'moderate':
      case 'medium':
        return const Color(0xFFEA580C); // Orange
      case 'mild':
      case 'low':
        return const Color(0xFF16A34A); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData get severityIcon {
    switch (severity.toLowerCase()) {
      case 'severe':
      case 'high':
        return Icons.warning;
      case 'moderate':
      case 'medium':
        return Icons.info;
      case 'mild':
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}