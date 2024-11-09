import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final Map<String, double> characteristics;
  double similarity;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.characteristics = const {},
    this.similarity = 0.0,
    this.isFavorite = false,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
      return Product(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        imageUrl: json['image_url'] ?? '',
        characteristics: json['characteristics'] != null 
            ? Map<String, double>.from({
                'sweet': (json['characteristics']['sweet'] ?? 0).toDouble(),
                'sour': (json['characteristics']['sour'] ?? 0).toDouble(),
                'bitter': (json['characteristics']['bitter'] ?? 0).toDouble(),
                'turbidity': (json['characteristics']['turbidity'] ?? 0).toDouble(),
                'fragrance': (json['characteristics']['fragrance'] ?? 0).toDouble(),
                'crisp': (json['characteristics']['crisp'] ?? 0).toDouble(),
              })
            : {},
        isFavorite: json['is_favorite'] ?? false,
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'characteristics': characteristics,
      'is_favorite': isFavorite,
    };
  }
}