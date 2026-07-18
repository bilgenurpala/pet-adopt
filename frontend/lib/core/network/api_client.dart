import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'dio_provider.dart';

class ApiClient {
  ApiClient._();

  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await DioProvider.dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  static Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await DioProvider.dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  static Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await DioProvider.dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  static Future<Response> delete(String endpoint) async {
    try {
      return await DioProvider.dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  static ApiException _handleException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    switch (e.response?.statusCode) {
      case 401:
        return const UnauthorizedException();

      case 404:
        return const NotFoundException();

      case 500:
        return const ServerException();

      default:
        return ApiException(e.message ?? 'Unknown error occurred.');
    }
  }
}
