import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../repositories/pet_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({this.repository = const PetRepository()});

  final PetRepository repository;

  final List<Pet> _favoritePets = [];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Pet> get favoritePets => List.unmodifiable(_favoritePets);

  bool isFavorite(int petId) {
    return _favoritePets.any((pet) => pet.id == petId);
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final pets = await repository.getFavoritePets();

      _favoritePets
        ..clear()
        ..addAll(pets);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Pet pet) async {
    final index = _favoritePets.indexWhere((e) => e.id == pet.id);

    if (index != -1) {
      final removedPet = _favoritePets.removeAt(index);
      notifyListeners();

      try {
        await repository.removeFavorite(pet.id);
      } catch (_) {
        _favoritePets.insert(index, removedPet);
        notifyListeners();
        rethrow;
      }
    } else {
      _favoritePets.add(pet);
      notifyListeners();

      try {
        await repository.addFavorite(pet.id);
      } catch (_) {
        _favoritePets.removeWhere((e) => e.id == pet.id);
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> refresh() async {
    await loadFavorites();
  }

  void clearFavorites() {
    _favoritePets.clear();
    notifyListeners();
  }
}
