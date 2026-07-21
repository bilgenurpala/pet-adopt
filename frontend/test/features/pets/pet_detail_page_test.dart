import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      shelter: 'Happy Paws',
      vaccinated: true,
      description: 'Friendly dog',
      photoUrl: '',
    );

    await tester.pumpWidget(const MaterialApp(home: PetDetailPage(pet: pet)));

    await tester.pumpAndSettle();

    expect(find.byType(PetDetailPage), findsOneWidget);
    expect(find.text('Buddy'), findsWidgets);
  });
}
