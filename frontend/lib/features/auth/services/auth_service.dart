import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static Future<void> register({
    required String username,
    required String email,
    required String fullName,
    required String password,
  }) async {
    await ApiClient.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'full_name': fullName,
        'password': password,
      },
    );
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid login response.');
    }

    final accessToken = data['access_token']?.toString();
    final refreshToken = data['refresh_token']?.toString();

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw Exception('Authentication tokens were not returned.');
    }

    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  static Future<UserModel> getCurrentUser() async {
    final response = await ApiClient.get(ApiEndpoints.currentUser);

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid user response.');
    }

    return UserModel.fromJson(data);
  }

  static Future<void> refreshTokens() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token not found.');
    }

    final response = await ApiClient.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid refresh response.');
    }

    final newAccessToken = data['access_token']?.toString();
    final newRefreshToken = data['refresh_token']?.toString();

    if (newAccessToken == null ||
        newAccessToken.isEmpty ||
        newRefreshToken == null ||
        newRefreshToken.isEmpty) {
      throw Exception('New authentication tokens were not returned.');
    }

    await TokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
  }

  static Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
