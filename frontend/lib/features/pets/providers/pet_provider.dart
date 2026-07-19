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

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _repository.getPets();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkBackendHealth() {
    return _repository.checkBackendHealth();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
