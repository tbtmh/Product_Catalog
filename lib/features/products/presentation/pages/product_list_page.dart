import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/common_widgets.dart';
import '../state/product_providers.dart';
import '../utils/category_label.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _applySearch(text));
    setState(() {}); 
  }

  void _applySearch(String text) {
    _debounce?.cancel();
    final q = text.trim();
    if (ref.read(searchQueryProvider) == q) return;
    if (q.isNotEmpty) ref.read(selectedCategoryProvider.notifier).state = null;
    ref.read(searchQueryProvider.notifier).state = q;
  }

  void _clearSearch() {
    _searchController.clear();
    _applySearch('');
    setState(() {});
  }

  void _selectCategory(String? category) {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedCategoryProvider.notifier).state = category;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);

    ref.listen(productListProvider.select((s) => s.loadMoreError), (_, err) {
      if (err != null && ref.read(productListProvider).items.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(err)));
      }
    });

    ref.listen<String>(searchQueryProvider, (_, next) {
      if (next.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Product Catalog')),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              child: _buildBody(state, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted: _applySearch,
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้า เช่น iPhone, Perfume...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'ล้างคำค้นหา',
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                ),
          filled: true,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final selected = ref.watch(selectedCategoryProvider);
    final categories = ref.watch(categoriesProvider);
    final slugs = categories.maybeWhen(
      data: (list) => list,
      orElse: () => const <String>[],
    );

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: slugs.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final slug = i == 0 ? null : slugs[i - 1];
          return ChoiceChip(
            label: Text(slug == null ? 'ทั้งหมด' : categoryLabel(slug)),
            selected: selected == slug,
            onSelected: (_) => _selectCategory(slug),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProductListState state, ProductListNotifier notifier) {
    if (state.isInitialLoading && state.items.isEmpty) {
      return const ScrollableCenter(child: LoadingView());
    }

    if (state.error != null && state.items.isEmpty) {
      return ScrollableCenter(
        child: ErrorView(message: state.error!, onRetry: notifier.retry),
      );
    }

    if (state.isEmpty) {
      final q = ref.watch(searchQueryProvider);
      return ScrollableCenter(
        child: EmptyView(
          title: q.isEmpty ? 'ไม่พบสินค้า' : 'ไม่พบสินค้าสำหรับ "$q"',
          subtitle: 'ดึงลงเพื่อรีเฟรช',
        ),
      );
    }

    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final aspect = (0.68 / (1 + (textScale - 1) * 0.6)).clamp(0.45, 0.8);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'แสดง ${state.items.length} จาก ${state.total} รายการ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: aspect,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final product = state.items[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: product),
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: _buildFooter(state, notifier)),
      ],
    );
  }

  Widget _buildFooter(ProductListState state, ProductListNotifier notifier) {
    final theme = Theme.of(context);
    final shown = state.items.length;
    final remaining = math.max(0, state.total - shown);
    final nextCount = math.min(kPageSize, remaining);
    final hasError = state.loadMoreError != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: Column(
        children: [
          Text(
            'แสดงแล้ว $shown จากทั้งหมด ${state.total} รายการ',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: state.total == 0 ? 0 : shown / state.total,
            ),
          ),
          const SizedBox(height: 16),
          if (state.hasMore)
            FilledButton.tonalIcon(
              onPressed: state.isLoadingMore ? null : notifier.loadMore,
              icon: state.isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(hasError ? Icons.refresh : Icons.expand_more),
              label: Text(
                state.isLoadingMore
                    ? 'กำลังโหลด...'
                    : hasError
                        ? 'โหลดไม่สำเร็จ ลองใหม่'
                        : 'โหลดเพิ่ม (อีก $nextCount รายการ)',
              ),
            )
          else
            Text('แสดงสินค้าครบทั้งหมดแล้ว', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
