import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/adoption.dart';
import '../services/adoption_service.dart';

class AdoptionProvider extends ChangeNotifier {
  List<Adoption> _applications = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Adoption> get applications => List<Adoption>.unmodifiable(_applications);

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await AdoptionService.getApplications();

      final List<dynamic> items;

      if (data is List) {
        items = data;
      } else if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final responseItems = map['items'];

        if (responseItems is List) {
          items = responseItems;
        } else {
          throw Exception('Adoption application list was not returned.');
        }
      } else {
        throw Exception('Invalid adoption applications response.');
      }

      _applications = items
          .whereType<Map>()
          .map((item) => Adoption.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyForPet(int petId) async {
    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AdoptionService.applyForPet(petId);
      await loadApplications();

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadApplications();
  }

  bool hasApplicationForPet(int petId) {
    return _applications.any(
      (application) =>
          application.petId == petId &&
          application.status.toLowerCase() != 'rejected' &&
          application.status.toLowerCase() != 'cancelled',
    );
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void clearApplications() {
    _applications = [];
    _errorMessage = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
