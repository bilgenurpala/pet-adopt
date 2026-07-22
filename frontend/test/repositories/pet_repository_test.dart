import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/repositories/pet_repository.dart';

void main() {
  group('PetRepository Tests', () {
    const repository = PetRepository();

    test('Repository returns a list of pets', () async {
      final pets = await repository.getPets();

      expect(pets, isA<List<Pet>>());
    });

    test('Repository returns pets successfully', () async {
      final pets = await repository.getPets();

      expect(pets, isNotEmpty);
    });

    test('Repository returns pets with valid ids', () async {
      final pets = await repository.getPets();

      expect(pets.every((pet) => pet.id > 0), isTrue);
    });
  });
}
