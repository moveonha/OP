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
    return UserPreference(
      userId: json['user_id'] as String,
      preferences: Map<String, double>.from(json['preferences'] as Map),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'preferences': preferences,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // 기본 선호도 값을 생성하는 팩토리 생성자
  factory UserPreference.createDefault(String userId) {
    return UserPreference(
      userId: userId,
      preferences: {
        'sweet': 0.0,       // 단맛
        'sour': 0.0,        // 신맛
        'bitter': 0.0,      // 쓴맛
        'turbidity': 0.0,   // 탁도
        'fragrance': 0.0,   // 향
        'crisp': 0.0,       // 청량함
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 선호도 업데이트 메서드
  void updatePreference(String key, double value) {
    if (preferences.containsKey(key)) {
      preferences[key] = value;
      updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  // 전체 선호도 업데이트 메서드
  void updateAllPreferences(Map<String, double> newPreferences) {
    preferences.addAll(newPreferences);
    updatedAt = DateTime.now();
    notifyListeners();
  }

  // 선호도 초기화 메서드
  void resetPreferences() {
    preferences.updateAll((key, value) => 0.0);
    updatedAt = DateTime.now();
    notifyListeners();
  }

  // 특정 선호도 값 가져오기
  double getPreference(String key) {
    return preferences[key] ?? 0.0;
  }

  // 복사본 생성 메서드
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