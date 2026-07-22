import 'package:dio/dio.dart';

import '../../../core/network/dio_provider.dart';
import 'admin_api_exception.dart';

class AdminApiService {
  const AdminApiService();

  static const String _stats = '/admin/stats';
  static const String _pets = '/pets';
  static const String _categories = '/categories';
  static const String _pendingPets = '/pets/pending';
  static const String _adoptions = '/adoptions';
  static const String _users = '/users';
  static const String _currentUser = '/users/me';

  static String _approvePet(int petId) => '/pets/$petId/approve';
  static String _pet(int petId) => '/pets/$petId';
  static String _adoptionStatus(int adoptionId) =>
      '/adoptions/$adoptionId/status';
  static String _userRole(int userId) => '/users/$userId/role';
  static String _user(int userId) => '/users/$userId';

  Future<Map<String, dynamic>> getStats() async {
    final response = await _send(() => DioProvider.dio.get(_stats));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _send(() => DioProvider.dio.get(_currentUser));
    return _asMap(response.data);
  }

  Future<List<dynamic>> getPendingPets({int page = 1, int perPage = 50}) async {
    final response = await _send(
      () => DioProvider.dio.get(
        _pendingPets,
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );
    return _itemsOf(response.data);
  }

  Future<List<dynamic>> getPets({int page = 1, int perPage = 50}) async {
    final response = await _send(
      () => DioProvider.dio.get(
        _pets,
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );
    return _itemsOf(response.data);
  }

  Future<List<dynamic>> getCategories({int page = 1, int perPage = 50}) async {
    final response = await _send(
      () => DioProvider.dio.get(
        _categories,
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );
    return _itemsOf(response.data);
  }

  Future<List<dynamic>> getApplications({
    int page = 1,
    int perPage = 50,
    String? status,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': perPage};

    if (status != null) {
      query['status'] = status;
    }

    final response = await _send(
      () => DioProvider.dio.get(_adoptions, queryParameters: query),
    );
    return _itemsOf(response.data);
  }

  Future<List<dynamic>> getUsers({int page = 1, int perPage = 50}) async {
    final response = await _send(
      () => DioProvider.dio.get(
        _users,
        queryParameters: {'page': page, 'per_page': perPage},
      ),
    );
    return _itemsOf(response.data);
  }

  Future<void> approvePet(int petId) async {
    await _send(() => DioProvider.dio.patch(_approvePet(petId)));
  }

  Future<void> deletePet(int petId) async {
    await _send(() => DioProvider.dio.delete(_pet(petId)));
  }

  Future<Map<String, dynamic>> createPet(Map<String, dynamic> data) async {
    final response = await _send(() => DioProvider.dio.post(_pets, data: data));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updatePet(
    int petId,
    Map<String, dynamic> data,
  ) async {
    final response = await _send(
      () => DioProvider.dio.patch(_pet(petId), data: data),
    );
    return _asMap(response.data);
  }

  Future<void> updateAdoptionStatus(int adoptionId, String status) async {
    await _send(
      () => DioProvider.dio.patch(
        _adoptionStatus(adoptionId),
        data: {'status': status},
      ),
    );
  }

  Future<void> updateUserRole(int userId, String role) async {
    await _send(
      () => DioProvider.dio.patch(_userRole(userId), data: {'role': role}),
    );
  }

  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> data,
  ) async {
    final response = await _send(
      () => DioProvider.dio.patch(_user(userId), data: data),
    );
    return _asMap(response.data);
  }

  Future<void> deleteUser(int userId) async {
    await _send(() => DioProvider.dio.delete(_user(userId)));
  }

  Future<Response> _send(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    return const {};
  }

  List<dynamic> _itemsOf(dynamic data) {
    if (data is Map && data['items'] is List) {
      return data['items'] as List<dynamic>;
    }

    if (data is List) {
      return data;
    }

    return const [];
  }

  AdminApiException _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const AdminApiException('Please check your internet connection.');
    }

    final statusCode = e.response?.statusCode;
    final detail = _detailOf(e.response?.data);

    return AdminApiException(
      detail ?? e.message ?? 'Something went wrong.',
      statusCode: statusCode,
    );
  }

  String? _detailOf(dynamic data) {
    if (data is Map && data['detail'] is String) {
      final detail = (data['detail'] as String).trim();

      if (detail.isNotEmpty) {
        return detail;
      }
    }

    return null;
  }
}
