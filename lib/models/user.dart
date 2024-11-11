
class User {
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
      preferences: json['preferences'] ?? {
        'sweet': 0.0,
        'sour': 0.0,
        'bitter': 0.0,
        'turbidity': 0.0,
        'fragrance': 0.0,
        'crisp': 0.0,
      },
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

  User copyWith({
    String? name,
    int? age,
    String? gender,
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}