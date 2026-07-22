import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/models/admin_dashboard_stats.dart';
import 'package:frontend/features/admin/providers/admin_dashboard_provider.dart';
import 'package:frontend/features/admin/services/admin_api_exception.dart';

import 'fake_admin_repository.dart';

void main() {
  test('load exposes dashboard statistics', () async {
    const stats = AdminDashboardStats(
      totalUsers: 12,
      totalPets: 35,
      pendingPets: 4,
      totalApplications: 9,
      pendingApplications: 3,
    );
    final provider = AdminDashboardProvider(
      repository: FakeAdminRepository(stats: stats),
    );

    final operation = provider.load();

    expect(provider.isLoading, isTrue);
    await operation;
    expect(provider.stats, same(stats));
    expect(provider.error, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('load exposes API detail on failure', () async {
    final repository = FakeAdminRepository()
      ..statsError = const AdminApiException('Admin access required.');
    final provider = AdminDashboardProvider(repository: repository);

    await provider.load();

    expect(provider.stats, isNull);
    expect(provider.error, 'Admin access required.');
    expect(provider.isLoading, isFalse);
  });
}
