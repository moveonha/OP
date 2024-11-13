import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _showQuantitySelector = false;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
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
                          color: Colors.red,
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
                ],
              ),
            ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₩${widget.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, _) => Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _showQuantitySelector
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildQuantityButton(
                                      Icons.remove,
                                      () {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 16,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _buildQuantityButton(
                                      Icons.add,
                                      () => setState(() => _quantity++),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 16,
                                      color: Colors.orange.shade200,
                                    ),
                                    _buildQuantityButton(
                                      Icons.shopping_cart,
                                      () {
                                        final currentQuantity = _quantity;
                                        cart.addItem(
                                          widget.id,
                                          widget.title,
                                          widget.price,
                                          currentQuantity,
                                        );
                                        setState(() {
                                          _showQuantitySelector = false;
                                          _quantity = 1;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${widget.title} $currentQuantity개가 장바구니에 추가되었습니다',
                                            ),
                                            action: SnackBarAction(
                                              label: '실행 취소',
                                              onPressed: () {
                                                cart.removeSingleItem(widget.id);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      color: Colors.orange,
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _showQuantitySelector = true),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return SizedBox(
      width: 28,
      height: 32,
      child: IconButton(
        icon: Icon(
          icon,
          size: 16,
          color: color ?? Colors.orange,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 14,
      ),
    );
  }
}