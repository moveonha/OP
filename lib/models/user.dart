// lib/models/user.dart
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  final String id;
  final String email;
  String? name;
  int? age;
  String? gender;
  Map<String, dynamic> preferences;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.age,
    this.gender,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      preferences: json['preferences'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'preferences': preferences,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  void updatePreferences(Map<String, dynamic> newPreferences) {
    preferences = newPreferences;
    updatedAt = DateTime.now();
    notifyListeners();
  }
}