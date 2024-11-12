import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/hexagon_stats_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  final String id;  // productId 대신 id로 변경

  const ProductDetailScreen({
    Key? key,
    required this.id,  // 생성자 파라미터 수정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(id);  // productId 대신 id 사용

    if (product == null) {
      return const Scaffold(
        body: Center(
          child: Text('상품을 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          product.title,
          style: const TextStyle(color: Colors.black),
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
      body: SingleChildScrollView(
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
                  // 가격
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₩${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                  
                  // 설명
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  // 특성 차트 섹션
                  const SizedBox(height: 50),
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
                        const Text(
                          'AI 기반 취향 분석 결과',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: HexagonStatsWidget(
                            characteristics: product.characteristics,
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
      ),
      bottomNavigationBar: Container(
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
          child: Consumer<CartProvider>(
            builder: (ctx, cart, _) => ElevatedButton(
              onPressed: () {
                cart.addItem(
                  id,
                  product.title,
                  product.price,
                );
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
        ),
      ),
    );
  }
}