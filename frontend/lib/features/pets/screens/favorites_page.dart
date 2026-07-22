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

  int _columnCount(double width) {
    if (width < 700) {
      return 1;
    }

    if (width < 1100) {
      return 2;
    }

    if (width < 1450) {
      return 3;
    }

    return 4;
  }

  double _cardAspectRatio(int columnCount) {
    if (columnCount == 1) {
      return 0.78;
    }

    if (columnCount == 2) {
      return 0.68;
    }

    return 0.65;
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = _columnCount(constraints.maxWidth);

              return RefreshIndicator(
                onRefresh: _refresh,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: favoritesProvider.favoritePets.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: _cardAspectRatio(columnCount),
                  ),
                  itemBuilder: (context, index) {
                    return PetCard(pet: favoritesProvider.favoritePets[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
