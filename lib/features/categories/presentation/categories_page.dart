import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/nav_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../products/presentation/state/product_providers.dart';
import '../../products/presentation/utils/category_label.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  static IconData _iconFor(String slug) {
    const rules = <String, IconData>{
      'watch': Icons.watch,
      'smartphone': Icons.smartphone,
      'mobile': Icons.smartphone,
      'laptop': Icons.laptop,
      'tablet': Icons.tablet_mac,
      'fragrance': Icons.spa,
      'skin': Icons.face,
      'beauty': Icons.brush,
      'grocer': Icons.shopping_basket,
      'furniture': Icons.chair,
      'home': Icons.home,
      'kitchen': Icons.kitchen,
      'sport': Icons.sports_soccer,
      'motorcycle': Icons.motorcycle,
      'vehicle': Icons.directions_car,
      'sunglass': Icons.wb_sunny,
      'shirt': Icons.checkroom,
      'dress': Icons.checkroom,
      'shoes': Icons.checkroom,
      'tops': Icons.checkroom,
    };
    for (final e in rules.entries) {
      if (slug.contains(e.key)) return e.value;
    }
    return Icons.category_outlined;
  }

  void _open(WidgetRef ref, String? category) {
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedCategoryProvider.notifier).state = category;
    ref.read(navIndexProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('หมวดหมู่สินค้า')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(categoriesProvider.future),
        child: categories.when(
          loading: () => const ScrollableCenter(child: LoadingView()),
          error: (e, _) => ScrollableCenter(
            child: ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(categoriesProvider),
            ),
          ),
          data: (slugs) {
            if (slugs.isEmpty) {
              return const ScrollableCenter(
                child: EmptyView(
                  title: 'ไม่พบหมวดหมู่นี้',
                  subtitle: 'ดึงลงเพื่อรีเฟรช',
                  icon: Icons.category_outlined,
                ),
              );
            }
            final items = <String?>[null, ...slugs]; 
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 96,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final slug = items[i];
                return _CategoryTile(
                  label: slug == null ? 'ทั้งหมด' : categoryLabel(slug),
                  icon: slug == null ? Icons.apps : _iconFor(slug),
                  selected: selected == slug,
                  onTap: () => _open(ref, slug),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: selected ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon,
                  size: 28,
                  color: selected ? scheme.onPrimaryContainer : scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
