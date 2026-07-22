import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

abstract final class DioProvider {
  static Future<bool>? _refreshOperation;

  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await TokenStorage.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestOptions = error.requestOptions;

          final isAuthenticationRequest =
              requestOptions.path == ApiEndpoints.login ||
              requestOptions.path == ApiEndpoints.register ||
              requestOptions.path == ApiEndpoints.refresh;

          final wasAlreadyRetried = requestOptions.extra['wasRetried'] == true;

          if (statusCode != 401 ||
              isAuthenticationRequest ||
              wasAlreadyRetried) {
            handler.next(error);
            return;
          }

          try {
            final refreshed = await _refreshAccessToken();

            if (!refreshed) {
              await TokenStorage.clearTokens();
              handler.next(error);
              return;
            }

            final newAccessToken = await TokenStorage.getAccessToken();

            requestOptions.extra['wasRetried'] = true;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await dio.fetch<dynamic>(requestOptions);

            handler.resolve(response);
          } catch (_) {
            await TokenStorage.clearTokens();
            handler.next(error);
          }
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }

  static Future<bool> _refreshAccessToken() {
    final runningOperation = _refreshOperation;

    if (runningOperation != null) {
      return runningOperation;
    }

    final operation = _performTokenRefresh();
    _refreshOperation = operation;

    return operation.whenComplete(() {
      _refreshOperation = null;
    });
  }

  static Future<bool> _performTokenRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    try {
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        return false;
      }

      final accessToken = data['access_token']?.toString();
      final newRefreshToken = data['refresh_token']?.toString();

      if (accessToken == null || newRefreshToken == null) {
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      return true;
    } on DioException {
      return false;
    }
  }
}
