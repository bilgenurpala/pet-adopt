import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/providers/pet_provider.dart';
import 'package:frontend/features/pets/repositories/pet_repository.dart';

class FakePetRepository extends PetRepository {
  FakePetRepository({this.pets = const [], this.error});

  final List<Pet> pets;
  final Object? error;

  String? lastSpecies;
  String? lastSize;
  String? lastEnergyLevel;
  String? lastStatus;

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

void main() {
  group('PetProvider', () {
    test('initializes with empty state', () {
      final provider = PetProvider(repository: FakePetRepository());

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.pets, isEmpty);
    });

    test('loadPets populates pets from the repository', () async {
      final provider = PetProvider(
        repository: FakePetRepository(pets: const [testPet]),
      );

      await provider.loadPets();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.pets, [testPet]);
    });

    test('loadPets forwards filters to the repository', () async {
      final repository = FakePetRepository();
      final provider = PetProvider(repository: repository);

      await provider.loadPets(
        species: 'cat',
        size: 'small',
        energyLevel: 'low',
        status: 'available',
      );

      expect(repository.lastSpecies, 'cat');
      expect(repository.lastSize, 'small');
      expect(repository.lastEnergyLevel, 'low');
      expect(repository.lastStatus, 'available');
    });

    test('loadPets exposes an error message on failure', () async {
      final provider = PetProvider(
        repository: FakePetRepository(error: Exception('network down')),
      );

      await provider.loadPets();

      expect(provider.isLoading, isFalse);
      expect(provider.pets, isEmpty);
      expect(provider.errorMessage, contains('network down'));
    });

    test('loadMyPets populates pets from the repository', () async {
      final provider = PetProvider(
        repository: FakePetRepository(pets: const [testPet]),
      );

      await provider.loadMyPets();

      expect(provider.pets, [testPet]);
    });

    test('loadPendingPets populates pets from the repository', () async {
      final provider = PetProvider(
        repository: FakePetRepository(pets: const [testPet]),
      );

      await provider.loadPendingPets();

      expect(provider.pets, [testPet]);
    });

    test('clearPets empties the pet list', () async {
      final provider = PetProvider(
        repository: FakePetRepository(pets: const [testPet]),
      );

      await provider.loadPets();
      provider.clearPets();

      expect(provider.pets, isEmpty);
    });

    test('clearError clears a previously set error message', () async {
      final provider = PetProvider(
        repository: FakePetRepository(error: Exception('boom')),
      );

      await provider.loadPets();
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });
}
