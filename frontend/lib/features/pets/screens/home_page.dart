import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../models/pet.dart';
import '../services/mock_pet_service.dart';
import '../widgets/pet_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/species_filter_chips.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<Pet> allPets;
  late List<Pet> filteredPets;

  String selectedSpecies = 'All';
  String currentSearch = '';

  @override
  void initState() {
    super.initState();
    allPets = MockPetService.getPets();
    filteredPets = allPets;
  }

  void _filterPets() {
    setState(() {
      filteredPets = allPets.where((pet) {
        final matchesSpecies = selectedSpecies == 'All'
            ? true
            : pet.species == selectedSpecies;

        final query = currentSearch.toLowerCase();

        final matchesSearch =
            pet.name.toLowerCase().contains(query) ||
            pet.breed.toLowerCase().contains(query);

        return matchesSpecies && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    currentSearch = value;
    _filterPets();
  }

  void _onSpeciesChanged(String species) {
    selectedSpecies = species;
    _filterPets();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pet Store',
      body: Column(
        children: [
          SearchBarWidget(onChanged: _onSearchChanged),
          const SizedBox(height: 16),
          SpeciesFilterChips(
            selectedSpecies: selectedSpecies,
            onSelected: _onSpeciesChanged,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredPets.isEmpty
                ? const EmptyState(
                    title: 'No pets found',
                    subtitle: 'Try another search keyword.',
                  )
                : GridView.builder(
                    itemCount: filteredPets.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      return PetCard(pet: filteredPets[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
