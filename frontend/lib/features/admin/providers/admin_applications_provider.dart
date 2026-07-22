import 'package:flutter/foundation.dart';

import '../models/admin_adoption_application.dart';
import '../repositories/admin_repository.dart';
import '../services/admin_api_exception.dart';

class AdminApplicationsProvider extends ChangeNotifier {
  AdminApplicationsProvider({this.repository = const AdminRepository()});

  final AdminRepository repository;

  bool _isLoading = false;
  String? _error;
  String _filter = 'all';
  final List<AdminAdoptionApplication> _applications = [];
  final Set<int> _busyIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;
  List<AdminAdoptionApplication> get applications =>
      List.unmodifiable(_applications);

  bool isBusy(int adoptionId) => _busyIds.contains(adoptionId);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final status = _filter == 'all' ? null : _filter;
      final applications = await repository.getApplications(status: status);
      _applications
        ..clear()
        ..addAll(applications);
    } on AdminApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(String filter) async {
    if (_filter == filter) {
      return;
    }

    _filter = filter;
    await load();
  }

  Future<String?> updateStatus(int adoptionId, String status) async {
    if (_busyIds.contains(adoptionId)) {
      return null;
    }

    _busyIds.add(adoptionId);
    notifyListeners();

    String? errorMessage;

    try {
      await repository.updateApplicationStatus(adoptionId, status);
    } on AdminApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong.';
    }

    _busyIds.remove(adoptionId);

    if (errorMessage == null) {
      await load();
    } else {
      notifyListeners();
    }

    return errorMessage;
  }
}
