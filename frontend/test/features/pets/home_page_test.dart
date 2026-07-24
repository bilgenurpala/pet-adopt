import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/pets/providers/favorites_provider.dart';
import 'package:frontend/features/pets/providers/pet_provider.dart';
import 'package:frontend/features/pets/screens/home_page.dart';

import '../../support/fake_pet_repository.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('Home page renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => PetProvider(repository: FakePetRepository()),
            ),
            ChangeNotifierProvider(
              create: (_) => FavoritesProvider(repository: FakePetRepository()),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Search bar is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => PetProvider(repository: FakePetRepository()),
            ),
            ChangeNotifierProvider(
              create: (_) => FavoritesProvider(repository: FakePetRepository()),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });
  });
}
