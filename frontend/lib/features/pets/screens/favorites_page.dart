import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/favorites_provider.dart';
import '../widgets/pet_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<FavoritesProvider>().loadFavorites();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    });
  }

  Future<void> _refresh() async {
    try {
      await context.read<FavoritesProvider>().refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Favorites',
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, _) {
          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoritesProvider.favoritePets.isEmpty) {
            return const EmptyState(
              title: 'No Favorite Pets Yet',
              subtitle:
                  'Explore pets and tap the heart icon to save your favorites.',
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: favoritesProvider.favoritePets.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                return PetCard(pet: favoritesProvider.favoritePets[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
