import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/product-list';

  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedSort = '추천순';
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollPosition);
    Future.delayed(Duration.zero).then((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      Provider.of<RecommendationProvider>(context, listen: false).fetchRecommendedProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollPosition() {
    if (!mounted) return;
    setState(() {
      if (_scrollController.position.maxScrollExtent > 0) {
        _scrollPosition = (_scrollController.offset / _scrollController.position.maxScrollExtent)
            .clamp(0.0, 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Consumer2<ProductsProvider, RecommendationProvider>(
        builder: (ctx, productsData, recommendationData, _) {
          if (productsData.isLoading || recommendationData.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final recommendedProducts = recommendationData.recommendedProducts.take(5).toList();
          final products = productsData.items;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 추천 상품 섹션
                if (recommendedProducts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.recommend, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          '취향 저격 TOP 5',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: recommendedProducts.length,
                          itemBuilder: (ctx, i) {
                            final product = recommendedProducts[i];
                            // 전체 상품 목록에서 해당 상품 찾기
                            final mainProduct = productsData.items.firstWhere(
                              (p) => p.id == product.id,
                              orElse: () => product,
                            );
                            return Container(
                              width: 180,
                              margin: const EdgeInsets.only(right: 16),
                              child: ProductCard(
                                id: product.id,
                                title: product.title,
                                price: product.price,
                                imageUrl: product.imageUrl,
                                isFavorite: mainProduct.isFavorite,
                                similarity: product.similarity ?? 0.0,
                                onFavoriteToggle: () {
                                  productsData.toggleFavorite(product.id);
                                },
                              ),
                            );
                          },
                        ),
                        // 시각적 스크롤바 표시
                        Positioned(
                          bottom: 0,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: constraints.maxWidth * 0.2,
                                      margin: EdgeInsets.only(
                                        left: constraints.maxWidth * 0.8 * _scrollPosition,
                                      ).clamp(
                                        EdgeInsets.zero,
                                        EdgeInsets.only(left: constraints.maxWidth * 0.8),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 정렬 옵션과 전체 상품 목록
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '전체 상품',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedSort,
                          items: ['추천순', '가격높은순', '가격낮은순', '최신순']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedSort = newValue;
                              });
                              productsData.sortProducts(newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 상품 그리드
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => ProductCard(
                    id: products[i].id,
                    title: products[i].title,
                    price: products[i].price,
                    imageUrl: products[i].imageUrl,
                    isFavorite: products[i].isFavorite,
                    similarity: products[i].similarity ?? 0.0,
                    onFavoriteToggle: () {
                      productsData.toggleFavorite(products[i].id);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}