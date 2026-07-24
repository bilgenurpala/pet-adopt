import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/repositories/pet_repository.dart';
import 'package:frontend/features/pets/services/pet_api_service.dart';

class FakePetApiService extends PetApiService {
  FakePetApiService({this.pets = const []});

  final List<Pet> pets;
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
  }) async => List<Pet>.from(pets);

  @override
  Future<Pet> getPetById(int petId) async {
    return pets.firstWhere(
      (pet) => pet.id == petId,
      orElse: () => throw Exception('Pet not found'),
    );
  }

  @override
  Future<List<Pet>> getFavoritePets({int page = 1, int perPage = 100}) async =>
      List<Pet>.from(pets);

  @override
  Future<void> addFavorite(int petId) async {
    addedFavoriteIds.add(petId);
  }

  @override
  Future<void> removeFavorite(int petId) async {
    removedFavoriteIds.add(petId);
  }

  @override
  Future<List<Pet>> getMyPets({int page = 1, int perPage = 100}) async =>
      List<Pet>.from(pets);

  @override
  Future<List<Pet>> getPendingPets({int page = 1, int perPage = 100}) async =>
      List<Pet>.from(pets);

  @override
  Future<bool> checkBackendHealth() async => true;
}

const testPet = Pet(
  id: 1,
  name: 'Buddy',
  species: 'dog',
  breed: 'Golden Retriever',
  age: 2,
  gender: 'male',
  size: 'large',
  energyLevel: 'high',
  status: 'available',
  categoryId: 1,
  ownerId: 1,
  isApproved: true,
  description: 'Friendly dog',
  photoUrl: '',
);

const secondTestPet = Pet(
  id: 2,
  name: 'Luna',
  species: 'cat',
  breed: 'Siamese',
  age: 3,
  gender: 'female',
  size: 'small',
  energyLevel: 'low',
  status: 'available',
  categoryId: 2,
  ownerId: 2,
  isApproved: true,
  description: 'Calm cat',
  photoUrl: '',
);

void main() {
  group('PetRepository', () {
    test('getPets returns pets from the api service', () async {
      final repository = PetRepository(
        apiService: FakePetApiService(pets: const [testPet, secondTestPet]),
      );

      final pets = await repository.getPets();

      expect(pets, [testPet, secondTestPet]);
    });

    test('getPets returns an empty list when there are no pets', () async {
      final repository = PetRepository(apiService: FakePetApiService());

      final pets = await repository.getPets();

      expect(pets, isEmpty);
    });

    test('every returned pet has a valid, positive id', () async {
      final repository = PetRepository(
        apiService: FakePetApiService(pets: const [testPet, secondTestPet]),
      );

      final pets = await repository.getPets();

      expect(pets.every((pet) => pet.id > 0), isTrue);
    });

    test('getPetById returns the matching pet', () async {
      final repository = PetRepository(
        apiService: FakePetApiService(pets: const [testPet, secondTestPet]),
      );

      final pet = await repository.getPetById(secondTestPet.id);

      expect(pet, secondTestPet);
    });

    test('getFavoritePets delegates to the api service', () async {
      final repository = PetRepository(
        apiService: FakePetApiService(pets: const [testPet]),
      );

      final pets = await repository.getFavoritePets();

      expect(pets, [testPet]);
    });

    test('addFavorite delegates the pet id to the api service', () async {
      final apiService = FakePetApiService();
      final repository = PetRepository(apiService: apiService);

      await repository.addFavorite(42);

      expect(apiService.addedFavoriteIds, [42]);
    });

    test('removeFavorite delegates the pet id to the api service', () async {
      final apiService = FakePetApiService();
      final repository = PetRepository(apiService: apiService);

      await repository.removeFavorite(7);

      expect(apiService.removedFavoriteIds, [7]);
    });

    test('getMyPets delegates to the api service', () async {
      final repository = PetRepository(
        apiService: FakePetApiService(pets: const [testPet]),
      );

      final pets = await repository.getMyPets();

      expect(pets, [testPet]);
    });

    test('getPendingPets delegates to the api service', () async {
      final repository = PetRepository(
        apiService: FakePetApiService(pets: const [testPet]),
      );

      final pets = await repository.getPendingPets();

      expect(pets, [testPet]);
    });

    test('checkBackendHealth delegates to the api service', () async {
      final repository = PetRepository(apiService: FakePetApiService());

      expect(await repository.checkBackendHealth(), isTrue);
    });
  });
}
