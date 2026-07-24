import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/adoptions/providers/adoption_provider.dart';
import 'package:frontend/features/pets/models/pet.dart';
import 'package:frontend/features/pets/screens/pet_detail_page.dart';

void main() {
  testWidgets('Pet detail page renders successfully', (
    WidgetTester tester,
  ) async {
    const pet = Pet(
      id: 1,
      name: 'Buddy',
      species: 'Dog',
      breed: 'Golden Retriever',
      age: 2,
      gender: 'Male',
      size: 'Large',
      energyLevel: 'High',
      status: 'Available',
      categoryId: 1,
      ownerId: 1,
      isApproved: true,
      description: 'Friendly dog',
      photoUrl: '',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AdoptionProvider>(
        create: (_) => AdoptionProvider(),
        child: const MaterialApp(home: PetDetailPage(pet: pet)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PetDetailPage), findsOneWidget);
    expect(find.text('Buddy'), findsWidgets);
  });
}
