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

  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 데이터 가져오기
    Future.delayed(Duration.zero).then((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      Provider.of<RecommendationProvider>(context, listen: false).fetchRecommendedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductsProvider, RecommendationProvider>(
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recommendedProducts.length,
                    itemBuilder: (ctx, i) {
                      final product = recommendedProducts[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 180,
                          child: ProductCard(
                            id: product.id,
                            title: product.title,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            isFavorite: product.isFavorite,
                            similarity: product.similarity ?? 0.0,
                            onFavoriteToggle: () {
                              productsData.toggleFavorite(product.id);
                            },
                          ),
                        ),
                      );
                    },
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
                    DropdownButton<String>(
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
    );
  }
}
