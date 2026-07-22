import 'package:flutter/foundation.dart';

import '../models/admin_dashboard_stats.dart';
import '../repositories/admin_repository.dart';
import '../services/admin_api_exception.dart';

class AdminDashboardProvider extends ChangeNotifier {
  AdminDashboardProvider({this.repository = const AdminRepository()});

  final AdminRepository repository;

  bool _isLoading = false;
  String? _error;
  AdminDashboardStats? _stats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AdminDashboardStats? get stats => _stats;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await repository.getStats();
    } on AdminApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
