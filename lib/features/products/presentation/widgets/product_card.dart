import 'package:flutter/material.dart';

import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/product.dart';
import 'stock_badge.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final low = isLowStock(product.stock) || product.stock <= 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: low
            ? BorderSide(color: theme.colorScheme.error, width: 1.5)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: NetworkImageBox(url: product.thumbnail),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '\$${product.discountedPrice.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  StockBadge(stock: product.stock, compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
