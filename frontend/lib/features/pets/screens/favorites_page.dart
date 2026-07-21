import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/favorites_provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Favorites',
      body: Consumer2<PetProvider, FavoritesProvider>(
        builder: (context, petProvider, favoritesProvider, _) {
          if (petProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (petProvider.errorMessage != null) {
            return EmptyState(
              title: 'Something went wrong',
              subtitle: petProvider.errorMessage!,
            );
          }

          final favoritePets = petProvider.pets
              .where((pet) => favoritesProvider.isFavorite(pet.id))
              .toList();

          if (favoritePets.isEmpty) {
            return const EmptyState(
              title: 'No Favorite Pets Yet',
              subtitle:
                  'Explore pets and tap the heart icon to save your favorites.',
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
      ),
    );
  }
}
