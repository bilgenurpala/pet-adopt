import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/pets/providers/favorites_provider.dart';
import 'package:frontend/features/pets/screens/favorites_page.dart';

void main() {
  group('FavoritesPage Widget Tests', () {
    testWidgets('Favorites page renders successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
          child: const MaterialApp(home: FavoritesPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FavoritesPage), findsOneWidget);
    });
  });
}
