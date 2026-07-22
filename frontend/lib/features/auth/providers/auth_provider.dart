import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final accessToken = await TokenStorage.getAccessToken();
      final refreshToken = await TokenStorage.getRefreshToken();

      final hasTokens =
          accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty;

      if (!hasTokens) {
        _isAuthenticated = false;
        _currentUser = null;
        return;
      }

      _currentUser = await AuthService.getCurrentUser();
      _isAuthenticated = true;
    } catch (error) {
      await TokenStorage.clearTokens();

      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = _getErrorMessage(error);
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.login(email: email.trim(), password: password);

      _currentUser = await AuthService.getCurrentUser();
      _isAuthenticated = true;

      return true;
    } catch (error) {
      await TokenStorage.clearTokens();

      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = _getErrorMessage(error);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String fullName,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.register(
        username: username.trim(),
        email: email.trim(),
        fullName: fullName.trim(),
        password: password,
      );

      await AuthService.login(email: email.trim(), password: password);

      _currentUser = await AuthService.getCurrentUser();
      _isAuthenticated = true;

      return true;
    } catch (error) {
      await TokenStorage.clearTokens();

      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = _getErrorMessage(error);

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    if (!_isAuthenticated) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.getCurrentUser();
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.logout();
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
