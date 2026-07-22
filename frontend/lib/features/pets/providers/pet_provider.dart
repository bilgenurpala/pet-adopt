import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../repositories/pet_repository.dart';

class PetProvider extends ChangeNotifier {
  PetProvider({PetRepository? repository})
    : _repository = repository ?? const PetRepository();

  final PetRepository _repository;

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pet> get pets => List.unmodifiable(_pets);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPets({
    String? species,
    String? size,
    String? energyLevel,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _repository.getPets(
        species: species,
        size: size,
        energyLevel: energyLevel,
        status: status,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _repository.getMyPets();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _repository.getPendingPets();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkBackendHealth() {
    return _repository.checkBackendHealth();
  }

  void clearPets() {
    _pets.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
