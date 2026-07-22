import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';

class AIService {
  AIService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.aiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Map<String, dynamic>> sendMessage({
    required List<Map<String, dynamic>> messages,
  }) async {
    final token = await TokenStorage.getAccessToken();

    final response = await _dio.post(
      ApiEndpoints.assistant,
      data: {'messages': messages},
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    return Map<String, dynamic>.from(response.data);
  }
}
