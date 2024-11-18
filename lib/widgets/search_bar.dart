// lib/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => '상품 검색';

  @override
  TextStyle get searchFieldStyle => const TextStyle(
        color: Colors.black,
        fontSize: 16,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '검색어를 입력하세요',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final productsData = Provider.of<ProductsProvider>(context);
    final searchResults = productsData.items.where((product) {
      final searchQuery = query.toLowerCase();
      final title = product.title.toLowerCase();
      final description = product.description.toLowerCase();
      
      return title.contains(searchQuery) || 
             description.contains(searchQuery);
    }).toList();

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '"$query"에 대한 검색 결과가 없습니다',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final product = searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            product.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${product.price.toStringAsFixed(0)}원',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/product-detail',
              arguments: product.id,
            );
          },
        );
      },
    );
  }
}