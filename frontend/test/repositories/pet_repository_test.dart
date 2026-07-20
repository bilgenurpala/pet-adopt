import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/repositories/pet_repository.dart';

void main() {
  group('PetRepository Tests', () {
    test('Repository loads mock pets successfully', () async {
      const repository = PetRepository(useMockData: true);

      final pets = await repository.getPets();

      expect(pets, isNotEmpty);
    });

    test('Repository returns a Pet list', () async {
      const repository = PetRepository(useMockData: true);

      final pets = await repository.getPets();

      expect(pets, isA<List<Pet>>());
    });

    test('Repository returns pets with valid ids', () async {
      const repository = PetRepository(useMockData: true);

      final pets = await repository.getPets();

      expect(pets.every((pet) => pet.id > 0), isTrue);
    });
  });
}
