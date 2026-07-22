import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/pet.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/species_filter_chips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedSpecies = 'All';
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  List<Pet> _filterBySearch(List<Pet> pets) {
    final query = _currentSearch.trim().toLowerCase();

    if (query.isEmpty) {
      return pets;
    }

    return pets.where((pet) {
      return pet.name.toLowerCase().contains(query) ||
          pet.breed.toLowerCase().contains(query) ||
          pet.species.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _currentSearch = value;
    });
  }

  Future<void> _onSpeciesChanged(String species) async {
    setState(() {
      _selectedSpecies = species;
    });

    await context.read<PetProvider>().loadPets(
      species: species == 'All' ? null : species.toLowerCase(),
    );
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
      title: 'Pet Adoption',
      body: Consumer<PetProvider>(
        builder: (context, petProvider, _) {
          final visiblePets = _filterBySearch(petProvider.pets);

          if (petProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (petProvider.errorMessage != null) {
            return EmptyState(
              title: 'Something went wrong',
              subtitle: petProvider.errorMessage ?? 'Unknown error',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = _columnCount(constraints.maxWidth);

              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchBarWidget(onChanged: _onSearchChanged),
                          const SizedBox(height: 16),
                          SpeciesFilterChips(
                            selectedSpecies: _selectedSpecies,
                            onSelected: _onSpeciesChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: visiblePets.isEmpty
                        ? const EmptyState(
                            title: 'No pets found',
                            subtitle: 'Try another search keyword or filter.',
                          )
                        : RefreshIndicator(
                            onRefresh: () {
                              return context.read<PetProvider>().loadPets(
                                species: _selectedSpecies == 'All'
                                    ? null
                                    : _selectedSpecies.toLowerCase(),
                              );
                            },
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: visiblePets.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columnCount,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 18,
                                    childAspectRatio: _cardAspectRatio(
                                      columnCount,
                                    ),
                                  ),
                              itemBuilder: (context, index) {
                                return PetCard(pet: visiblePets[index]);
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
