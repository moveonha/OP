import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final bool isFavorite;
  final double? similarity;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    Key? key,
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    this.similarity,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          try {
            Navigator.of(context).pushNamed(
              '/product-detail',
              arguments: {'id': widget.id},
            );
          } catch (error) {
            print('Navigation error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('상품 상세 페이지를 열 수 없습니다.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  // 상품 이미지
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '이미지 없음',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 찜하기 버튼
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.orange,
                          size: 20,
                        ),
                        onPressed: widget.onFavoriteToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
                  ),
                  // 취향 일치도 표시
                  if (widget.similarity != null && widget.similarity! > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(widget.similarity! * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 상품 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₩${widget.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}