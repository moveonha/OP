import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/hexagon_stats_widget.dart';
import 'dart:math' show sqrt;

class ProductDetailScreen extends StatelessWidget {
  final String id;

  const ProductDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  double calculateSimilarity(Map<String, dynamic> characteristics, Map<String, dynamic> userPreferences) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    final keys = ['sweet', 'sour', 'bitter', 'turbidity', 'fragrance', 'crisp'];
    
    for (String key in keys) {
      final a = characteristics[key] ?? 0.0;
      final b = userPreferences[key] ?? 0.0;
      
      dotProduct += (a * b);
      normA += (a * a);
      normB += (b * b);
    }
    
    if (normA == 0 || normB == 0) return 0;
    
    return (dotProduct / (sqrt(normA) * sqrt(normB))).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (ctx, cart, _) => IconButton(
              icon: Icon(
                cart.items.containsKey(id)
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
            ),
          ),
        ],
      ),
      body: Consumer2<ProductsProvider, UserPreferenceProvider>(
        builder: (context, productsProvider, userPrefProvider, _) {
          final product = productsProvider.findById(id);

          if (product == null) {
            return const Center(child: Text('상품을 찾을 수 없습니다.'));
          }

          double similarity = 0.0;
          if (userPrefProvider.preferences.isNotEmpty) {
            similarity = calculateSimilarity(
              product.characteristics,
              userPrefProvider.preferences,
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₩${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      if (userPrefProvider.preferences.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '취향 일치도',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: similarity,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.orange.shade400,
                                        ),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${(similarity * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                similarity >= 0.9
                                    ? '당신의 취향과 매우 잘 맞는 전통주입니다!'
                                    : similarity >= 0.7
                                        ? '당신의 취향과 잘 맞는 전통주입니다.'
                                        : similarity >= 0.4
                                            ? '당신의 취향과 부분적으로 일치합니다.'
                                            : '당신의 취향과는 거리가 있는 전통주입니다.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '맛과 향 분석',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (userPrefProvider.preferences.isNotEmpty)
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('상품'),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('내 취향'),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: HexagonStatsWidget(
                                characteristics: product.characteristics,
                                userPreferences: userPrefProvider.preferences,
                                size: MediaQuery.of(context).size.width * 0.75,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer2<ProductsProvider, CartProvider>(
        builder: (context, productsProvider, cart, _) {
          final product = productsProvider.findById(id);
          if (product == null) return const SizedBox();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(id, product.title, product.price);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('장바구니에 추가되었습니다'),
                      action: SnackBarAction(
                        label: '실행 취소',
                        onPressed: () {
                          cart.removeSingleItem(id);
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '장바구니에 담기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}