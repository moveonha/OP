// lib/models/cart.dart
class Cart {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  Cart({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}