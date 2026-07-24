import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/widgets/main_navigation.dart';
import 'package:frontend/features/pets/providers/favorites_provider.dart';
import 'package:frontend/features/pets/providers/pet_provider.dart';

import '../support/fake_pet_repository.dart';

void main() {
  testWidgets('Bottom navigation renders correctly', (
    WidgetTester tester,
  ) async {
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
        child: const MaterialApp(home: MainNavigation()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
