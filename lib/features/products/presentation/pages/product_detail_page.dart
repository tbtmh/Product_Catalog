import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/common_widgets.dart';
import '../../data/models/product.dart';
import '../state/product_providers.dart';
import '../widgets/stock_badge.dart';

class ProductDetailPage extends ConsumerWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(productDetailProvider(product.id));

    return Scaffold(
      appBar: AppBar(title: Text(product.title, overflow: TextOverflow.ellipsis)),
      body: detail.when(
        loading: () => _DetailContent(product: product, loadingMore: true),
        error: (e, _) => ErrorView(
          message: e is Exception ? e.toString() : 'เกิดข้อผิดพลาด',
          onRetry: () => ref.invalidate(productDetailProvider(product.id)),
        ),
        data: (p) => _DetailContent(product: p),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Product product;
  final bool loadingMore;

  const _DetailContent({required this.product, this.loadingMore = false});

  @override
  Widget build(BuildContext context) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700; // tablet
        final gallery = _Gallery(images: images, heroTag: 'product-${product.id}');
        final info = _Info(product: product, loadingMore: loadingMore);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: gallery),
                        const SizedBox(width: 24),
                        Expanded(child: info),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [gallery, const SizedBox(height: 16), info],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _Gallery extends StatefulWidget {
  final List<String> images;
  final String heroTag;

  const _Gallery({required this.images, required this.heroTag});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: widget.heroTag,
              child: NetworkImageBox(
                url: widget.images[_selected],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  width: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 2,
                      color: i == _selected ? scheme.primary : Colors.transparent,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: NetworkImageBox(url: widget.images[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final Product product;
  final bool loadingMore;

  const _Info({required this.product, required this.loadingMore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(product.rating.toStringAsFixed(1)),
            const SizedBox(width: 12),
            Chip(
              label: Text(product.category),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.discountedPrice.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.hasDiscount) ...[
              const SizedBox(width: 8),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '-${product.discountPercentage.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (loadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          Text('รายละเอียด', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(product.description),
          const SizedBox(height: 16),
          if (product.brand != null) _row('แบรนด์', product.brand!),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StockBadge(stock: product.stock),
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(width: 80, child: Text(label)),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
