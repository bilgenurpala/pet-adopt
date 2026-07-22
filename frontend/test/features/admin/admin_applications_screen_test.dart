import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/providers/admin_applications_provider.dart';
import 'package:frontend/features/admin/screens/admin_applications_screen.dart';
import 'package:provider/provider.dart';

import 'admin_test_fixtures.dart';
import 'fake_admin_repository.dart';

void main() {
  testWidgets('pending application exposes only valid actions', (tester) async {
    final repository = FakeAdminRepository(
      applications: [pendingApplication],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminApplicationsProvider(repository: repository),
        child: const MaterialApp(home: AdminApplicationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'approved'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'rejected'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'completed'), findsNothing);
  });
}
