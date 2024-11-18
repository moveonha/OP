import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/hexagon_stats_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;

  const ProductDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (ctx, productsData, child) {
        final product = productsData.findById(widget.id);

        return Scaffold(
          backgroundColor: const Color(0xFFEFEFEF),
          body: CustomScrollView(
            slivers: [
              // 앱바
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 상품 정보
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
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
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 특성 그래프
              if (product.characteristics.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '맛 특성',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: HexagonStatsWidget(
                            characteristics: product.characteristics,
                            size: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFEFEFEF),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // 수량 조절
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 장바구니 담기 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(
                          product.id,
                          product.title,
                          product.price,
                          _quantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.title} $_quantity개가 장바구니에 추가되었습니다',
                            ),
                            action: SnackBarAction(
                              label: '실행 취소',
                              onPressed: () {
                                Provider.of<CartProvider>(context, listen: false)
                                    .removeSingleItem(product.id);
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '장바구니 담기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}