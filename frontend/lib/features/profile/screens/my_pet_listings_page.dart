import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../pets/providers/pet_provider.dart';
import '../../pets/widgets/pet_card.dart';

class MyPetListingsPage extends StatefulWidget {
  const MyPetListingsPage({super.key, this.embedded = false});

  final bool embedded;

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
    if (width < 620) {
      return 1;
    }

    if (width < 920) {
      return 2;
    }

    if (width < 1220) {
      return 3;
    }

    if (width < 1580) {
      return 4;
    }

    return 5;
  }

  double _cardHeight(int columnCount) {
    if (columnCount == 1) {
      return 335;
    }

    if (columnCount == 2) {
      return 305;
    }

    return 280;
  }

  @override
  Widget build(BuildContext context) {
    final content = Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        if (petProvider.isLoading && petProvider.pets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (petProvider.errorMessage != null && petProvider.pets.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 140),
                EmptyState(
                  title: 'Could not load your listings',
                  subtitle:
                      petProvider.errorMessage ?? 'An unknown error occurred.',
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: _cardHeight(columnCount),
                ),
                itemBuilder: (context, index) {
                  return PetCard(pet: petProvider.pets[index]);
                },
              ),
            );
          },
        );
      },
    );

    if (widget.embedded) {
      return content;
    }

    return AppScaffold(title: 'My Pet Listings', body: content);
  }
}
