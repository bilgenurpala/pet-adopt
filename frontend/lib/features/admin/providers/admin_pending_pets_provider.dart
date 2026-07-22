import 'package:flutter/foundation.dart';

import '../../pets/models/pet.dart';
import '../models/admin_category.dart';
import '../repositories/admin_repository.dart';
import '../services/admin_api_exception.dart';

class AdminPendingPetsProvider extends ChangeNotifier {
  AdminPendingPetsProvider({this.repository = const AdminRepository()});

  final AdminRepository repository;

  bool _isLoading = false;
  String? _error;
  final List<Pet> _pets = [];
  final List<AdminCategory> _categories = [];
  final Set<int> _busyIds = {};
  bool _isSaving = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Pet> get pets => List.unmodifiable(_pets);
  List<AdminCategory> get categories => List.unmodifiable(_categories);
  bool get isSaving => _isSaving;

  bool isBusy(int petId) => _busyIds.contains(petId);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getPets(),
        repository.getPendingPets(),
      ]);
      final categories = await repository.getCategories();
      final petsById = <int, Pet>{
        for (final pet in results.first) pet.id: pet,
        for (final pet in results.last) pet.id: pet,
      };
      _pets
        ..clear()
        ..addAll(petsById.values);
      _categories
        ..clear()
        ..addAll(categories);
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
    return delete(petId);
  }

  Future<String?> delete(int petId) {
    return _mutate(petId, () => repository.deletePet(petId));
  }

  Future<String?> save({int? petId, required Map<String, dynamic> data}) async {
    if (_isSaving) {
      return null;
    }

    _isSaving = true;
    notifyListeners();

    String? errorMessage;

    try {
      final pet = petId == null
          ? await repository.createPet(data)
          : await repository.updatePet(petId, data);
      final index = _pets.indexWhere((item) => item.id == pet.id);

      if (index == -1) {
        _pets.add(pet);
      } else {
        _pets[index] = pet;
      }
    } on AdminApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong.';
    }

    _isSaving = false;
    notifyListeners();

    return errorMessage;
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
