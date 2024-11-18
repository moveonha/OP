// lib/providers/products_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Product> _items = [];
  String _currentSort = '추천순';
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get items {
    List<Product> sortedItems = [..._items];
    
    switch (_currentSort) {
      case '가격높은순':
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '가격낮은순':
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '최신순':
        sortedItems.sort((a, b) => b.id.compareTo(a.id));
        break;
      case '추천순':
      default:
        sortedItems.sort((a, b) => 
          (b.similarity ?? 0).compareTo(a.similarity ?? 0));
        break;
    }
    
    return sortedItems;
  }

  List<Product> get topRecommendedProducts {
    var recommendedItems = _items
        .where((product) => product.similarity != null)
        .toList()
      ..sort((a, b) => (b.similarity ?? 0).compareTo(a.similarity ?? 0));
    return recommendedItems.take(5).toList();
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  String get currentSortOrder => _currentSort;

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      _items = (response as List).map<Product>((json) => Product(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        imageUrl: json['image_url'] ?? '',
        characteristics: json['characteristics'] != null 
            ? Map<String, double>.from(json['characteristics'])
            : {},
        isFavorite: json['is_favorite'] ?? false,
        similarity: json['similarity'] != null 
            ? (json['similarity'] as num).toDouble() 
            : null,
      )).toList();

    } catch (error) {
      _error = '상품을 불러오는데 실패했습니다: $error';
      print('Error fetching products: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final productIndex = _items.indexWhere((p) => p.id == productId);
      if (productIndex >= 0) {
        final product = _items[productIndex];
        final newFavoriteStatus = !product.isFavorite;

        await _supabase
            .from('products')
            .update({'is_favorite': newFavoriteStatus})
            .eq('id', productId);

        _items[productIndex] = Product(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          characteristics: product.characteristics,
          isFavorite: newFavoriteStatus,
          similarity: product.similarity, // null 허용
        );
        notifyListeners();
      }
    } catch (error) {
      print('Error toggling favorite: $error');
      _error = '즐겨찾기 설정에 실패했습니다: $error';
    }
  }

  void sortProducts(String sortOrder) {
    if (_currentSort != sortOrder) {
      _currentSort = sortOrder;
      notifyListeners();
    }
  }

  Product findById(String id) {
    return _items.firstWhere(
      (product) => product.id == id,
      orElse: () => throw Exception('상품을 찾을 수 없습니다.'),
    );
  }

  Future<void> searchProducts(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase
          .from('products')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      _items = (response as List).map<Product>((json) => Product(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        imageUrl: json['image_url'] ?? '',
        characteristics: Map<String, double>.from(json['characteristics'] ?? {}),
        isFavorite: json['is_favorite'] ?? false,
        similarity: json['similarity'] != null 
            ? (json['similarity'] as num).toDouble() 
            : null,
      )).toList();

    } catch (error) {
      print('Error searching products: $error');
      _error = '검색에 실패했습니다: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}