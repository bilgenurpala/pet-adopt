import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../pets/providers/pet_provider.dart';
import '../../pets/widgets/pet_card.dart';

class MyPetListingsPage extends StatefulWidget {
  const MyPetListingsPage({super.key});

  @override
  State<MyPetListingsPage> createState() => _MyPetListingsPageState();
}

class _MyPetListingsPageState extends State<MyPetListingsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadMyPets();
    });
  }

  Future<void> _refresh() async {
    await context.read<PetProvider>().loadMyPets();
  }

  int _columnCount(double width) {
    if (width < 600) {
      return 1;
    }

    if (width < 900) {
      return 2;
    }

    if (width < 1200) {
      return 3;
    }

    return 4;
  }

  double _cardAspectRatio(int columnCount) {
    if (columnCount == 1) {
      return 0.9;
    }

    if (columnCount == 2) {
      return 0.72;
    }

    return 0.68;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Pet Listings',
      body: Consumer<PetProvider>(
        builder: (context, petProvider, _) {
          if (petProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (petProvider.errorMessage != null) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 140),
                  EmptyState(
                    title: 'Could not load your listings',
                    subtitle:
                        petProvider.errorMessage ??
                        'An unknown error occurred.',
                  ),
                ],
              ),
            );
          }

          if (petProvider.pets.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  EmptyState(
                    title: 'No Pet Listings Yet',
                    subtitle: 'Pets you publish for adoption will appear here.',
                  ),
                ],
              ),
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
                  itemCount: petProvider.pets.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: _cardAspectRatio(columnCount),
                  ),
                  itemBuilder: (context, index) {
                    return PetCard(pet: petProvider.pets[index]);
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
