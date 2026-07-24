import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/repositories/pet_repository.dart';

/// A [PetRepository] test double that never touches the network.
///
/// Widget and provider tests must use this instead of the real
/// [PetRepository] default (which performs a live HTTP call) — otherwise
/// `pumpAndSettle()` will time out waiting for the request to resolve.
class FakePetRepository extends PetRepository {
  FakePetRepository({
    this.pets = const [],
    this.favoritePets = const [],
    this.error,
  });

  final List<Pet> pets;
  final List<Pet> favoritePets;
  final Object? error;

  String? lastSpecies;
  String? lastSize;
  String? lastEnergyLevel;
  String? lastStatus;

  final List<int> addedFavoriteIds = [];
  final List<int> removedFavoriteIds = [];

  @override
  Future<List<Pet>> getPets({
    int page = 1,
    int perPage = 100,
    String? species,
    String? size,
    String? energyLevel,
    String? status,
  }) async {
    lastSpecies = species;
    lastSize = size;
    lastEnergyLevel = energyLevel;
    lastStatus = status;

    if (error != null) {
      throw error!;
    }

    return List<Pet>.from(pets);
  }

  @override
  Future<Pet> getPetById(int petId) async {
    return pets.firstWhere(
      (pet) => pet.id == petId,
      orElse: () => throw Exception('Pet not found'),
    );
  }

  @override
  Future<List<Pet>> getFavoritePets({int page = 1, int perPage = 100}) async {
    if (error != null) {
      throw error!;
    }

    return List<Pet>.from(favoritePets);
  }

  @override
  Future<void> addFavorite(int petId) async {
    addedFavoriteIds.add(petId);
  }

  @override
  Future<void> removeFavorite(int petId) async {
    removedFavoriteIds.add(petId);
  }

  @override
  Future<List<Pet>> getMyPets({int page = 1, int perPage = 100}) async {
    if (error != null) {
      throw error!;
    }

    return List<Pet>.from(pets);
  }

  @override
  Future<List<Pet>> getPendingPets({int page = 1, int perPage = 100}) async {
    if (error != null) {
      throw error!;
    }

    return List<Pet>.from(pets);
  }

  @override
  Future<bool> checkBackendHealth() async => true;
}
