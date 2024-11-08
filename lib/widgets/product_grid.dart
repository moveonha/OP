// lib/widgets/product_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import './product_card.dart';

class ProductGrid extends StatelessWidget {
  final bool showOnlyFavorites;

  const ProductGrid({
    super.key,
    this.showOnlyFavorites = false,
  });

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showOnlyFavorites ? productsData.favoriteItems : productsData.items;

    return products.isEmpty 
        ? const Center(
            child: Text(
              '상품이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (ctx, i) => ProductCard(
              id: products[i].id,
              title: products[i].title,
              imageUrl: products[i].imageUrl,
              price: products[i].price,
              isFavorite: products[i].isFavorite,
              onFavoriteToggle: () {
                products[i].toggleFavorite();
              },
            ),
          );
  }
}