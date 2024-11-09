// lib/widgets/product_recommendation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class ProductRecommendation extends StatefulWidget {
  const ProductRecommendation({Key? key}) : super(key: key);

  @override
  State<ProductRecommendation> createState() => _ProductRecommendationState();
}

class _ProductRecommendationState extends State<ProductRecommendation> {
  @override
  void initState() {
    super.initState();
    // 컴포넌트가 마운트될 때 추천 상품 데이터 로드
    Future.microtask(() =>
      context.read<RecommendationProvider>().fetchRecommendedProducts()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (ctx, recommendationProvider, child) {
        if (recommendationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (recommendationProvider.error != null) {
          return Center(
            child: Text('Error: ${recommendationProvider.error}'),
          );
        }

        final recommendedProducts = recommendationProvider.recommendedProducts;

        if (recommendedProducts.isEmpty) {
          return const Center(
            child: Text('추천 상품이 없습니다.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '추천 상품',
                style: Theme.of(context).textTheme.titleLarge,
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
                      width: 160,
                      child: ProductCard(
                        id: product.id,
                        title: product.title,
                        price: product.price,
                        imageUrl: product.imageUrl,
                        isFavorite: product.isFavorite,
                        onFavoriteToggle: () {
                          final productsProvider = 
                              Provider.of<ProductsProvider>(context, listen: false);
                          productsProvider.toggleFavorite(product.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}