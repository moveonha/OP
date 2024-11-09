// lib/providers/recommendation_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../config/supabase_config.dart';
import 'dart:math';

class RecommendationProvider with ChangeNotifier {
  List<Product> _recommendedProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get recommendedProducts => _recommendedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecommendedProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 현재 사용자의 취향 데이터 가져오기
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final userPrefs = await supabase
          .from('users')
          .select('preferences')
          .eq('id', userId)
          .single();

      // 모든 제품 가져오기
      final response = await supabase
          .from('products')
          .select('*')
          .order('created_at');

      List<Product> productList = [];
      for (var product in response) {
        var newProduct = Product.fromJson(product);
        
        // 사용자 취향과 제품 특성 간의 유사도 계산
        if (userPrefs != null && userPrefs['preferences'] != null) {
          final preferences = Map<String, double>.from(userPrefs['preferences']);
          double similarity = calculateSimilarity(preferences, newProduct.characteristics);
          newProduct = Product(
            id: newProduct.id,
            title: newProduct.title,
            description: newProduct.description,
            price: newProduct.price,
            imageUrl: newProduct.imageUrl,
            characteristics: newProduct.characteristics,
            similarity: similarity,
            isFavorite: newProduct.isFavorite,
          );
        }
        
        productList.add(newProduct);
      }

      // 유사도를 기준으로 정렬
      productList.sort((a, b) => b.similarity.compareTo(a.similarity));
      
      _recommendedProducts = productList;
      _error = null;

    } catch (e) {
      _error = e.toString();
      print('Error fetching recommended products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double calculateSimilarity(Map<String, double> userPrefs, Map<String, double> productChars) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    userPrefs.forEach((key, value) {
      if (productChars.containsKey(key)) {
        dotProduct += value * productChars[key]!;
        normA += value * value;
        normB += productChars[key]! * productChars[key]!;
      }
    });
    
    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}