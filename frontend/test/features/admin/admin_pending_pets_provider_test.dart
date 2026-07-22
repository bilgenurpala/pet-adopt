import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/providers/admin_pending_pets_provider.dart';
import 'package:frontend/features/admin/services/admin_api_exception.dart';
import 'package:frontend/features/pets/models/pet.dart';

import 'admin_test_fixtures.dart';
import 'fake_admin_repository.dart';

void main() {
  test('load combines approved and pending pet listings', () async {
    const approvedPet = Pet(
      id: 11,
      name: 'Milo',
      species: 'cat',
      breed: 'Tabby',
      age: 1,
      gender: 'male',
      size: 'small',
      energyLevel: 'medium',
      status: 'available',
      categoryId: 1,
      ownerId: 2,
      isApproved: true,
      description: 'Playful cat',
    );
    final repository = FakeAdminRepository(
      pets: [approvedPet],
      pendingPets: [pendingPet],
    );
    final provider = AdminPendingPetsProvider(repository: repository);

    await provider.load();

    expect(provider.pets, [approvedPet, pendingPet]);
    expect(provider.categories, isNotEmpty);
  });

  test('approve removes the reviewed pet', () async {
    final repository = FakeAdminRepository(pendingPets: [pendingPet]);
    final provider = AdminPendingPetsProvider(repository: repository);
    await provider.load();

    final message = await provider.approve(pendingPet.id);

    expect(message, isNull);
    expect(repository.approvedPetId, pendingPet.id);
    expect(provider.pets, isEmpty);
    expect(provider.isBusy(pendingPet.id), isFalse);
  });

  test('reject preserves the pet and returns conflict detail', () async {
    final repository = FakeAdminRepository(pendingPets: [pendingPet])
      ..deletePetError = const AdminApiException(
        'Pet has linked applications.',
        statusCode: 409,
      );
    final provider = AdminPendingPetsProvider(repository: repository);
    await provider.load();

    final message = await provider.reject(pendingPet.id);

    expect(message, 'Pet has linked applications.');
    expect(provider.pets, [pendingPet]);
    expect(provider.isBusy(pendingPet.id), isFalse);
  });
}
