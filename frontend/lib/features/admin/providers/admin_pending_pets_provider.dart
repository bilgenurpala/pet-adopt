import 'package:flutter/foundation.dart';

import '../../pets/models/pet.dart';
import '../repositories/admin_repository.dart';
import '../services/admin_api_exception.dart';

class AdminPendingPetsProvider extends ChangeNotifier {
  AdminPendingPetsProvider({this.repository = const AdminRepository()});

  final AdminRepository repository;

  bool _isLoading = false;
  String? _error;
  final List<Pet> _pets = [];
  final Set<int> _busyIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Pet> get pets => List.unmodifiable(_pets);

  bool isBusy(int petId) => _busyIds.contains(petId);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pets = await repository.getPendingPets();
      _pets
        ..clear()
        ..addAll(pets);
    } on AdminApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> approve(int petId) {
    return _mutate(petId, () => repository.approvePet(petId));
  }

  Future<String?> reject(int petId) {
    return _mutate(petId, () => repository.deletePet(petId));
  }

  Future<String?> _mutate(int petId, Future<void> Function() action) async {
    if (_busyIds.contains(petId)) {
      return null;
    }

    _busyIds.add(petId);
    notifyListeners();

    String? errorMessage;

    try {
      await action();
      _pets.removeWhere((pet) => pet.id == petId);
    } on AdminApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong.';
    }

    _busyIds.remove(petId);
    notifyListeners();

    return errorMessage;
  }
}
