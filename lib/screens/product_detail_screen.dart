import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_preference_provider.dart';
import '../widgets/hexagon_stats_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  final String id;

  const ProductDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품 이미지
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '이미지를 불러올 수 없습니다',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // 상품 정보
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Consumer<CartProvider>(
                            builder: (ctx, cart, _) {
                              final quantity = cart.getItemQuantity(id);
                              return quantity > 0
                                  ? Text(
                                      '장바구니: $quantity개',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ],
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
                      
                      // 특성 차트 섹션
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
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
                                    color: Colors.black87,
                                  ),
                                ),
                                if (userPrefProvider.preferences.isNotEmpty)
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('상품'),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 12,
                                        height: 12,
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
                                userPreferences: userPrefProvider.preferences.isNotEmpty 
                                    ? userPrefProvider.preferences 
                                    : null,
                                size: MediaQuery.of(context).size.width * 0.75,
                              ),
                            ),
                            if (!userPrefProvider.preferences.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/taste-test');
                                  },
                                  icon: const Icon(Icons.psychology),
                                  label: const Text('취향 테스트 하러가기'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
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
            padding: const EdgeInsets.all(20),
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
                      duration: const Duration(seconds: 2),
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