import 'package:flutter/foundation.dart';

import '../models/admin_user_summary.dart';
import '../repositories/admin_repository.dart';
import '../services/admin_api_exception.dart';

class AdminUsersProvider extends ChangeNotifier {
  AdminUsersProvider({this.repository = const AdminRepository()});

  final AdminRepository repository;

  bool _isLoading = false;
  String? _error;
  int? _currentUserId;
  final List<AdminUserSummary> _users = [];
  final Set<int> _busyIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentUserId => _currentUserId;
  List<AdminUserSummary> get users => List.unmodifiable(_users);

  bool isBusy(int userId) => _busyIds.contains(userId);

  bool isSelf(int userId) => _currentUserId == userId;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUserId = await repository.getCurrentUserId();
      final users = await repository.getUsers();
      _users
        ..clear()
        ..addAll(users);
    } on AdminApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> changeRole(int userId, String role) {
    return _mutate(userId, () async {
      await repository.updateUserRole(userId, role);
      final index = _users.indexWhere((user) => user.id == userId);

      if (index != -1) {
        _users[index] = _users[index].copyWith(role: role);
      }
    });
  }

  Future<String?> deleteUser(int userId) {
    return _mutate(userId, () async {
      await repository.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
    });
  }

  Future<String?> _mutate(int userId, Future<void> Function() action) async {
    if (_busyIds.contains(userId)) {
      return null;
    }

    _busyIds.add(userId);
    notifyListeners();

    String? errorMessage;

    try {
      await action();
    } on AdminApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong.';
    }

    _busyIds.remove(userId);
    notifyListeners();

    return errorMessage;
  }
}
