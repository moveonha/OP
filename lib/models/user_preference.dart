import 'package:flutter/foundation.dart';

class UserPreference with ChangeNotifier {
  final String userId;
  final String? nickname;
  final Map<String, double> preferences;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserPreference({
    required this.userId,
    this.nickname,
    required this.preferences,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    try {
      // null 안전성 처리 추가
      final prefsMap = (json['preferences'] as Map?)?.cast<String, dynamic>() ?? {};
      return UserPreference(
        userId: json['id']?.toString() ?? '',  // null 처리
        nickname: json['nickname']?.toString(),  // 이미 optional
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
      // 기본값으로 생성할 때도 null 처리
      return UserPreference.createDefault(json['id']?.toString() ?? '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'nickname': nickname,
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
    String? nickname,
    Map<String, double>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
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