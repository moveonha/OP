// lib/models/product.dart
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
      id: json['id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image'] ?? '',  // 단일 이미지 URL로 유지
      characteristics: json['product_labels']?[0]?['characteristics'] != null
          ? Map<String, double>.from(json['product_labels'][0]['characteristics'])
          : {},
      isFavorite: false,
    );
  }

  Product copyWithSimilarity(double newSimilarity) {
    return Product(
      id: id,
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
      characteristics: characteristics,
      similarity: newSimilarity,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'price': price,
      'image': imageUrl,
      'characteristics': characteristics,
      'isFavorite': isFavorite,
    };
  }
}