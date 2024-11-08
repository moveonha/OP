// lib/providers/products_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductsProvider with ChangeNotifier {
  final List<Product> _items = [
    Product(
      id: 'p1',
      title: '상품1',
      description: 'test description',
      price: 15000,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Product(
      id: 'p2',
      title: '상품2',
      description: '마나를 회복시켜주는 블루 포션입니다.',
      price: 20000,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    // 더 많은 상품 추가 가능
  ];

  // 정렬 상태를 저장하는 변수
  String _currentSort = '추천순';

  List<Product> get items {
    // 현재 정렬 상태에 따라 정렬된 리스트 반환
    List<Product> sortedItems = [..._items];
    
    switch (_currentSort) {
      case '가격높은순':
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '가격낮은순':
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '최신순':
        sortedItems.sort((a, b) => b.id.compareTo(a.id)); // ID 기준으로 정렬
        break;
      case '추천순':
      default:
        // 기본 정렬 순서 유지
        break;
    }
    
    return sortedItems;
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere(
      (product) => product.id == id,
      orElse: () => throw Exception('상품을 찾을 수 없습니다.'),
    );
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }

  // 정렬 방식 변경 메서드
  void setSortOrder(String sortOrder) {
    if (_currentSort != sortOrder) {
      _currentSort = sortOrder;
      notifyListeners();
    }
  }

  void toggleFavorite(String productId) {
    final product = findById(productId);
    product.toggleFavorite();
    notifyListeners();
  }
  // 현재 정렬 방식 getter
  String get currentSortOrder => _currentSort;
}