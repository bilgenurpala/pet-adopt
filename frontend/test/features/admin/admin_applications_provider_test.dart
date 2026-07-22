import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/providers/admin_applications_provider.dart';
import 'package:frontend/features/admin/services/admin_api_exception.dart';

import 'admin_test_fixtures.dart';
import 'fake_admin_repository.dart';

void main() {
  test('filter loads applications with the selected status', () async {
    final repository = FakeAdminRepository(applications: [approvedApplication]);
    final provider = AdminApplicationsProvider(repository: repository);

    await provider.setFilter('approved');

    expect(provider.filter, 'approved');
    expect(repository.requestedApplicationStatus, 'approved');
    expect(provider.applications, [approvedApplication]);
    expect(provider.error, isNull);
  });

  test('status update forwards the API detail on failure', () async {
    final repository = FakeAdminRepository(applications: [approvedApplication])
      ..updateApplicationError = const AdminApiException(
        'Invalid application transition.',
      );
    final provider = AdminApplicationsProvider(repository: repository);
    await provider.load();

    final message = await provider.updateStatus(
      approvedApplication.id,
      'completed',
    );

    expect(message, 'Invalid application transition.');
    expect(repository.updatedApplicationId, approvedApplication.id);
    expect(repository.updatedApplicationStatus, 'completed');
    expect(provider.isBusy(approvedApplication.id), isFalse);
  });
}
