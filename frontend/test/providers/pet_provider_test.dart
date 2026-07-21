import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/providers/pet_provider.dart';

void main() {
  group('PetProvider Tests', () {
    test('Provider initializes correctly', () {
      final provider = PetProvider();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.pets, isEmpty);
    });

    test('loadPets loads mock pets successfully', () async {
      final provider = PetProvider();

      await provider.loadPets();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.pets, isNotEmpty);
    });
  });
}
