import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  factory AppException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
      case DioExceptionType.connectionError:
        return const AppException('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      case DioExceptionType.badResponse:
        return AppException(
            'เซิร์ฟเวอร์ตอบกลับผิดพลาด (${e.response?.statusCode ?? '-'})');
      case DioExceptionType.cancel:
        return const AppException('ยกเลิกคำขอแล้ว');
      default:
        return const AppException('เกิดข้อผิดพลาด');
    }
  }

  @override
  String toString() => message;
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  return dio;
});
