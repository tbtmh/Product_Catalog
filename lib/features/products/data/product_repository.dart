import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import 'models/product.dart';

class ProductRepository {
  final Dio _dio;
  const ProductRepository(this._dio);

  Future<ProductPage> fetchProducts({
    required int limit,
    required int skip,
    String? category,
    String? query,
    CancelToken? cancelToken,
  }) async {
    final q = query?.trim() ?? '';
    final params = <String, dynamic>{'limit': limit, 'skip': skip};
    final String path;
    if (q.isNotEmpty) {
      path = '/products/search';
      params['q'] = q;
    } else if (category != null) {
      path = '/products/category/${Uri.encodeComponent(category)}';
    } else {
      path = '/products';
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: params,
        cancelToken: cancelToken,
      );
      return ProductPage.fromJson(res.data!);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final res = await _dio.get<List<dynamic>>('/products/category-list');
      return (res.data ?? const []).map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Product> fetchProduct(int id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/products/$id');
      return Product.fromJson(res.data!);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(dioProvider)),
);
