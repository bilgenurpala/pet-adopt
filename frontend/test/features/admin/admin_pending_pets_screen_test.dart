import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/providers/admin_pending_pets_provider.dart';
import 'package:frontend/features/admin/screens/admin_pending_pets_screen.dart';
import 'package:provider/provider.dart';

import 'admin_test_fixtures.dart';
import 'fake_admin_repository.dart';

void main() {
  testWidgets('approving a pending pet removes its card', (tester) async {
    final repository = FakeAdminRepository(pendingPets: [pendingPet]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminPendingPetsProvider(repository: repository),
        child: const MaterialApp(home: AdminPendingPetsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(pendingPet.name), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pumpAndSettle();

    expect(repository.approvedPetId, pendingPet.id);
    expect(find.text(pendingPet.name), findsNothing);
    expect(find.text('No pending pets'), findsOneWidget);
  });
}
