import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../models/pet.dart';
import '../providers/favorites_provider.dart';
import '../services/mock_pet_service.dart';
import '../widgets/pet_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Favorites',
      body: FutureBuilder<List<Pet>>(
        future: MockPetService.getPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load pets.'));
          }

          final allPets = snapshot.data ?? [];

          return Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, _) {
              final favoritePets = allPets.where((pet) {
                return favoritesProvider.isFavorite(pet.id);
              }).toList();

              if (favoritePets.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 90,
                          color: Colors.amber.shade400,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Favorite Pets Yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Explore adorable pets and tap the heart icon to save your favorites.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: favoritePets.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  return PetCard(pet: favoritePets[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
