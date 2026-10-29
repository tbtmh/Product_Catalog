import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/product.dart';
import '../../data/product_repository.dart';

const int kPageSize = 10;

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productRepositoryProvider).fetchCategories();
});

class ProductListState {
  final List<Product> items;
  final int total; 
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error; 
  final String? loadMoreError; 

  const ProductListState({
    this.items = const [],
    this.total = 0,
    this.isInitialLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.loadMoreError,
  });

  bool get isEmpty => !isInitialLoading && error == null && items.isEmpty;

  ProductListState copyWith({
    List<Product>? items,
    int? total,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? loadMoreError,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return ProductListState(
      items: items ?? this.items,
      total: total ?? this.total,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

class ProductListNotifier extends Notifier<ProductListState> {
  int _gen = 0;

  @override
  ProductListState build() {
    ref.watch(selectedCategoryProvider);
    ref.watch(searchQueryProvider);
    ref.onDispose(() => _gen++);
    Future.microtask(_loadFirstPage);
    return const ProductListState();
  }

  ProductRepository get _repo => ref.read(productRepositoryProvider);
  String? get _category => ref.read(selectedCategoryProvider);
  String get _query => ref.read(searchQueryProvider);

  Future<ProductPage> _fetch(int skip) => _repo.fetchProducts(
        limit: kPageSize,
        skip: skip,
        category: _category,
        query: _query,
      );

  ProductListState _fromFirstPage(ProductPage page) => ProductListState(
        items: page.products,
        total: page.total,
        isInitialLoading: false,
        hasMore: page.products.length < page.total,
      );

  Future<void> _loadFirstPage() async {
    final gen = ++_gen;
    state = state.copyWith(
      isInitialLoading: true,
      clearError: true,
      clearLoadMoreError: true,
    );
    try {
      final page = await _fetch(0);
      if (gen != _gen) return;
      state = _fromFirstPage(page);
    } on AppException catch (e) {
      if (gen != _gen) return;
      state = state.copyWith(isInitialLoading: false, error: e.message);
    }
  }

  Future<void> retry() => _loadFirstPage();

  Future<void> refresh() async {
    final gen = ++_gen;
    try {
      final page = await _fetch(0);
      if (gen != _gen) return;
      state = _fromFirstPage(page);
    } on AppException catch (e) {
      if (gen != _gen) return;
      if (state.items.isEmpty) {
        state = state.copyWith(isInitialLoading: false, error: e.message);
      } else {
        state = state.copyWith(loadMoreError: e.message);
      }
    }
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasMore) return;
    if (state.error != null) return;

    final gen = _gen;
    state = state.copyWith(isLoadingMore: true, clearLoadMoreError: true);
    try {
      final page = await _fetch(state.items.length);
      if (gen != _gen) return;
      final all = [...state.items, ...page.products];
      state = state.copyWith(
        items: all,
        total: page.total,
        isLoadingMore: false,
        hasMore: page.products.isNotEmpty && all.length < page.total,
      );
    } on AppException catch (e) {
      if (gen != _gen) return;
      state = state.copyWith(isLoadingMore: false, loadMoreError: e.message);
    }
  }
}

final productListProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(
  ProductListNotifier.new,
);

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, int>((ref, id) {
  return ref.watch(productRepositoryProvider).fetchProduct(id);
});
