import 'package:flutter/material.dart';

class SpeciesFilterChips extends StatelessWidget {
  const SpeciesFilterChips({
    required this.selectedSpecies,
    required this.onSelected,
    super.key,
  });

  final String selectedSpecies;
  final ValueChanged<String> onSelected;

  static const List<String> species = ['All', 'Dog', 'Cat'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: species.map((item) {
        return ChoiceChip(
          label: Text(item),
          selected: selectedSpecies == item,
          onSelected: (_) => onSelected(item),
        );
      }).toList(),
    );
  }
}
