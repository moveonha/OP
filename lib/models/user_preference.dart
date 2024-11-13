import 'package:flutter/foundation.dart';

class UserPreference with ChangeNotifier {
  final String userId;
  final Map<String, double> preferences;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserPreference({
    required this.userId,
    required this.preferences,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    try {
      final prefsMap = (json['preferences'] as Map).cast<String, dynamic>();
      return UserPreference(
        userId: json['id'] as String,
        preferences: prefsMap.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'] as String) 
            : null,
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'] as String) 
            : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing UserPreference: $e');
      }
      return UserPreference.createDefault(json['id'] as String);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'preferences': preferences,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory UserPreference.createDefault(String userId) {
    return UserPreference(
      userId: userId,
      preferences: {
        'sweet': 0.0,      // 단맛
        'sour': 0.0,       // 신맛
        'bitter': 0.0,     // 쓴맛
        'turbidity': 0.0,  // 탁도
        'fragrance': 0.0,  // 향
        'crisp': 0.0,      // 청량함
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void updatePreference(String key, double value) {
    if (preferences.containsKey(key)) {
      preferences[key] = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  void updateAllPreferences(Map<String, double> newPreferences) {
    preferences.addAll(newPreferences);
    updatedAt = DateTime.now();
    notifyListeners();
  }

  void resetPreferences() {
    preferences.updateAll((key, value) => 0.0);
    updatedAt = DateTime.now();
    notifyListeners();
  }

  double getPreference(String key) {
    return preferences[key] ?? 0.0;
  }

  UserPreference copyWith({
    String? userId,
    Map<String, double>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      userId: userId ?? this.userId,
      preferences: preferences ?? Map<String, double>.from(this.preferences),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserPreference(userId: $userId, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}