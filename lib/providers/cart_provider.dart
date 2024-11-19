import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Set<String> _selectedItems = {}; // 선택된 아이템 ID 저장

  Map<String, CartItem> get items => {..._items};
  Set<String> get selectedItems => {..._selectedItems};

  int get itemCount => _items.length;
  int get selectedItemCount => _selectedItems.length;

  bool isSelected(String productId) => _selectedItems.contains(productId);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  double get selectedTotalAmount {
    var total = 0.0;
    _selectedItems.forEach((productId) {
      if (_items.containsKey(productId)) {
        final item = _items[productId]!;
        total += item.price * item.quantity;
      }
    });
    return total;
  }

  // 아이템 선택/해제
  void toggleItemSelection(String productId) {
    if (_selectedItems.contains(productId)) {
      _selectedItems.remove(productId);
    } else {
      _selectedItems.add(productId);
    }
    notifyListeners();
  }

  // 전체 선택/해제
  void toggleAllSelection() {
    if (_selectedItems.length == _items.length) {
      _selectedItems.clear();
    } else {
      _selectedItems = _items.keys.toSet();
    }
    notifyListeners();
  }

  // 선택된 아이템 삭제
  void removeSelectedItems() {
    _selectedItems.forEach((productId) {
      _items.remove(productId);
    });
    _selectedItems.clear();
    notifyListeners();
  }

  void addItem(String productId, String title, double price, [int quantity = 1, String imageUrl = '']) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity + quantity,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: quantity,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _selectedItems.remove(productId); // 선택 목록에서도 제거
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
      _selectedItems.remove(productId); // 선택 목록에서도 제거
    }
    notifyListeners();
  }

  void updateItemQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (quantity <= 0) {
      _items.remove(productId);
      _selectedItems.remove(productId); // 선택 목록에서도 제거
    } else {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: quantity,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    _selectedItems.clear(); // 선택 목록도 초기화
    notifyListeners();
  }

  int getItemQuantity(String productId) {
    if (_items.containsKey(productId)) {
      return _items[productId]!.quantity;
    }
    return 0;
  }
}