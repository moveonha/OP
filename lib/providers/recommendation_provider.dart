import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../models/product.dart';

class RecommendationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Product> _recommendedProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get recommendedProducts => _recommendedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 유사도 계산 함수
  double _calculateSimilarity(Map<String, double> userPrefs, Map<String, double> productChars) {
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

  // 사용자 취향 데이터 가져오기
  Future<Map<String, double>> _getUserPreferences() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      return Map<String, double>.from(response['preferences'] as Map);
    } catch (e) {
      // 기본 선호도 반환
      return {
        'sweet': 0.5,
        'bitter': 0.5,
        'sour': 0.5,
        'body': 0.5,
        'alcohol': 0.5,
      };
    }
  }

  // 추천 상품 가져오기
  Future<void> fetchRecommendedProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 사용자 취향 데이터 가져오기
      final userPreferences = await _getUserPreferences();

      // 상품 데이터와 라벨 데이터 가져오기
      final response = await _supabase
          .from('products')
          .select('''
            *,
            product_labels (
              characteristics
            )
          ''') as List<dynamic>;

      // 상품 데이터 변환 및 유사도 계산
      List<Product> products = [];
      for (var item in response) {
        final product = Product.fromJson(item);
        final characteristics = item['product_labels']?[0]?['characteristics'] ?? {};
        
        // 유사도 점수 계산
        _calculateSimilarity(
          userPreferences,
          Map<String, double>.from(characteristics)
        );

        products.add(product);
      }

      // 유사도 기준으로 정렬
      products.sort((a, b) => b.similarity.compareTo(a.similarity));

      _recommendedProducts = products.take(10).toList(); // 상위 10개 추천
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 취향 업데이트
  Future<void> updateUserPreferences(Map<String, double> newPreferences) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await _supabase
          .from('user_preferences')
          .upsert({
            'user_id': userId,
            'preferences': newPreferences,
          });

      // 추천 상품 리스트 갱신
      await fetchRecommendedProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 상품 평가 기록
  Future<void> rateProduct(String productId, double rating) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await _supabase
          .from('product_ratings')
          .upsert({
            'user_id': userId,
            'product_id': productId,
            'rating': rating,
          });

      // 추천 상품 리스트 갱신
      await fetchRecommendedProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}