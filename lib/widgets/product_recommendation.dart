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
    Future.microtask(() =>
        Provider.of<RecommendationProvider>(context, listen: false)
            .fetchRecommendedProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (ctx, recommendationProvider, child) {
        if (recommendationProvider.isLoading) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }

        if (recommendationProvider.error != null) {
          return const SizedBox(height: 0); // 에러 시 공간 차지하지 않음
        }

        // 추천 상품을 유사도 기준으로 정렬하고 상위 5개만 선택
        final recommendedProducts = recommendationProvider.recommendedProducts
            .where((product) => product.similarity != null)
            .toList()
          ..sort((a, b) => (b.similarity ?? 0).compareTo(a.similarity ?? 0));
        
        final top5Products = recommendedProducts.take(5).toList();

        if (top5Products.isEmpty) {
          return const SizedBox(height: 0); // 추천 상품이 없을 때 공간 차지하지 않음
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.recommend, color: Colors.orange, size: 24),
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
                itemCount: top5Products.length,
                itemBuilder: (ctx, i) {
                  final product = top5Products[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 180, // 카드 너비 조정
                      child: ProductCard(
                        id: product.id,
                        title: product.title,
                        price: product.price,
                        imageUrl: product.imageUrl,
                        isFavorite: product.isFavorite,
                        similarity: product.similarity ?? 0.0,
                        onFavoriteToggle: () {
                          Provider.of<ProductsProvider>(context, listen: false)
                              .toggleFavorite(product.id);
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