import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  const CartItemWidget({
    super.key,
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Dismissible(
        key: ValueKey(id),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete_outline,
            color: Colors.red.shade400,
            size: 24,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('상품 삭제'),
              content: const Text('장바구니에서 이 상품을 삭제하시겠습니까?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    '삭제',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          Provider.of<CartProvider>(context, listen: false).removeItem(productId);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 상품 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFEFEFEF),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_outlined,
                        size: 24,
                        color: Colors.grey[400],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 상품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₩${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 수량 조절
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () {
                        if (quantity > 1) {
                          Provider.of<CartProvider>(context, listen: false)
                              .updateItemQuantity(productId, quantity - 1);
                        } else {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('상품 삭제'),
                              content: const Text('장바구니에서 이 상품을 삭제하시겠습니까?'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    '취소',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    Provider.of<CartProvider>(context, listen: false)
                                        .removeItem(productId);
                                  },
                                  child: Text(
                                    '삭제',
                                    style: TextStyle(color: Colors.red.shade400),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .updateItemQuantity(productId, quantity + 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}