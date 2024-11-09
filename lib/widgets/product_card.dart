import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    Key? key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₩${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }
}