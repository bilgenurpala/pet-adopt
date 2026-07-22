import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:frontend/features/admin/services/admin_api_exception.dart';

import 'admin_test_fixtures.dart';
import 'fake_admin_repository.dart';

void main() {
  test('load identifies the signed-in admin', () async {
    final repository = FakeAdminRepository(
      currentUserId: adminUser.id,
      users: [adminUser, regularUser],
    );
    final provider = AdminUsersProvider(repository: repository);

    await provider.load();

    expect(provider.isSelf(adminUser.id), isTrue);
    expect(provider.isSelf(regularUser.id), isFalse);
    expect(provider.users, [adminUser, regularUser]);
  });

  test('role change updates the local user after success', () async {
    final repository = FakeAdminRepository(users: [regularUser]);
    final provider = AdminUsersProvider(repository: repository);
    await provider.load();

    final message = await provider.changeRole(regularUser.id, 'admin');

    expect(message, isNull);
    expect(repository.updatedUserId, regularUser.id);
    expect(repository.updatedUserRole, 'admin');
    expect(provider.users.single.role, 'admin');
  });

  test('delete preserves the user and returns conflict detail', () async {
    final repository = FakeAdminRepository(users: [regularUser])
      ..deleteUserError = const AdminApiException(
        'User has linked records.',
        statusCode: 409,
      );
    final provider = AdminUsersProvider(repository: repository);
    await provider.load();

    final message = await provider.deleteUser(regularUser.id);

    expect(message, 'User has linked records.');
    expect(provider.users, [regularUser]);
    expect(provider.isBusy(regularUser.id), isFalse);
  });

  test('profile update replaces the local user after success', () async {
    final repository = FakeAdminRepository(users: [regularUser]);
    final provider = AdminUsersProvider(repository: repository);
    await provider.load();

    final message = await provider.updateUser(regularUser.id, {
      'full_name': 'Updated User',
      'username': regularUser.username,
      'email': regularUser.email,
    });

    expect(message, isNull);
    expect(repository.updatedUserId, regularUser.id);
    expect(provider.users.single.fullName, 'Updated User');
  });
}
