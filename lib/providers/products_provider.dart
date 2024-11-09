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
        break;
    }
    
    return sortedItems;
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

      print('Fetched response: $response'); // 디버깅용

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
      )).toList();

      print('Converted to products: ${_items.length}'); // 디버깅용

    } catch (error) {
      _error = '상품을 불러오는데 실패했습니다: $error';
      print('Error fetching products: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await _supabase.from('products').insert({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'image_url': product.imageUrl,
        'characteristics': product.characteristics,
        'is_favorite': product.isFavorite,
      }).select();

      if (response.isNotEmpty) {
        final newProduct = Product(
          id: response[0]['id'].toString(),
          title: response[0]['title'],
          description: response[0]['description'],
          price: response[0]['price'].toDouble(),
          imageUrl: response[0]['image_url'],
          characteristics: Map<String, double>.from(response[0]['characteristics'] ?? {}),
          isFavorite: response[0]['is_favorite'] ?? false,
        );
        _items.add(newProduct);
        notifyListeners();
      }
    } catch (error) {
      print('Error adding product: $error');
      _error = '상품 추가에 실패했습니다: $error';
    }
  }

  Product findById(String id) {
    return _items.firstWhere(
      (product) => product.id == id,
      orElse: () => throw Exception('상품을 찾을 수 없습니다.'),
    );
  }

  void setSortOrder(String sortOrder) {
    if (_currentSort != sortOrder) {
      _currentSort = sortOrder;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final product = findById(productId);
      final newFavoriteStatus = !product.isFavorite;

      await _supabase
          .from('products')
          .update({'is_favorite': newFavoriteStatus})
          .eq('id', productId);

      product.toggleFavorite();
      notifyListeners();
    } catch (error) {
      print('Error toggling favorite: $error');
      _error = '즐겨찾기 설정에 실패했습니다: $error';
    }
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
      )).toList();

      notifyListeners();
    } catch (error) {
      print('Error searching products: $error');
      _error = '검색에 실패했습니다: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}