import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/providers/favorites_provider.dart';
import 'package:frontend/features/pets/repositories/pet_repository.dart';

class FakePetRepository extends PetRepository {
  FakePetRepository({List<Pet>? initialFavorites})
    : favoritePets = List<Pet>.from(initialFavorites ?? const []);

  final List<Pet> favoritePets;

  @override
  Future<List<Pet>> getFavoritePets({int page = 1, int perPage = 100}) async {
    return List<Pet>.from(favoritePets);
  }

  @override
  Future<void> addFavorite(int petId) async {}

  @override
  Future<void> removeFavorite(int petId) async {
    favoritePets.removeWhere((pet) => pet.id == petId);
  }
}

const testPet = Pet(
  id: 1,
  name: 'Buddy',
  species: 'Dog',
  breed: 'Golden Retriever',
  age: 2,
  gender: 'Male',
  size: 'Large',
  energyLevel: 'High',
  status: 'Available',
  categoryId: 1,
  ownerId: 1,
  isApproved: true,
  description: 'Friendly dog',
  photoUrl: '',
);

const secondTestPet = Pet(
  id: 2,
  name: 'Luna',
  species: 'Cat',
  breed: 'Siamese',
  age: 3,
  gender: 'Female',
  size: 'Small',
  energyLevel: 'Low',
  status: 'Available',
  categoryId: 2,
  ownerId: 1,
  isApproved: true,
  description: 'Calm cat',
  photoUrl: '',
);

void main() {
  group('FavoritesProvider', () {
    test('loads favorite pets from repository', () async {
      final repository = FakePetRepository(initialFavorites: const [testPet]);

      final provider = FavoritesProvider(repository: repository);

      await provider.loadFavorites();

      expect(provider.favoritePets, contains(testPet));

      expect(provider.isFavorite(testPet.id), isTrue);
    });

    test('adds a pet to favorites', () async {
      final repository = FakePetRepository();

      final provider = FavoritesProvider(repository: repository);

      await provider.toggleFavorite(testPet);

      expect(provider.favoritePets, contains(testPet));

      expect(provider.isFavorite(testPet.id), isTrue);
    });

    test('removes a pet from favorites', () async {
      final repository = FakePetRepository(initialFavorites: const [testPet]);

      final provider = FavoritesProvider(repository: repository);

      await provider.loadFavorites();
      await provider.toggleFavorite(testPet);

      expect(provider.favoritePets, isEmpty);

      expect(provider.isFavorite(testPet.id), isFalse);
    });

    test('clearFavorites clears local favorites', () async {
      final repository = FakePetRepository(
        initialFavorites: const [testPet, secondTestPet],
      );

      final provider = FavoritesProvider(repository: repository);

      await provider.loadFavorites();
      provider.clearFavorites();

      expect(provider.favoritePets, isEmpty);
    });
  });
}
