import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/admin/screens/admin_shell_page.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets(
    'AdminShellPage renders the wide sidebar layout without a layout error',
    (WidgetTester tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: const MaterialApp(home: AdminShellPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Sign Out'), findsOneWidget);
    },
  );
}
