import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/providers/admin_users_provider.dart';
import 'package:frontend/features/admin/screens/admin_users_screen.dart';
import 'package:provider/provider.dart';

import 'admin_test_fixtures.dart';
import 'fake_admin_repository.dart';

void main() {
  testWidgets('signed-in admin cannot demote their own account', (tester) async {
    final repository = FakeAdminRepository(
      currentUserId: adminUser.id,
      users: [adminUser, regularUser],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminUsersProvider(repository: repository),
        child: const MaterialApp(home: AdminUsersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final selfRoleButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Make user'),
    );

    expect(selfRoleButton.onPressed, isNull);
    expect(find.text('This is your account.'), findsOneWidget);
  });
}
