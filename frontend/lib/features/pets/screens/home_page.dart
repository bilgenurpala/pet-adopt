import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../services/mock_pet_service.dart';
import '../widgets/pet_card.dart';
import '../widgets/search_bar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pets = MockPetService.getPets();

    return AppScaffold(
      title: 'Pet Store',
      body: Column(
        children: [
          const SearchBarWidget(),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: pets.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return PetCard(pet: pets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
