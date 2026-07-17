import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../providers/favorites_provider.dart';
import '../screens/pet_detail_page.dart';

class PetCard extends StatelessWidget {
  const PetCard({required this.pet, super.key});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetDetailPage(pet: pet)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, _) {
                    final isFavorite = favoritesProvider.isFavorite(pet.id);

                    return IconButton(
                      onPressed: () {
                        favoritesProvider.toggleFavorite(pet.id);
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.pets, size: 56, color: Colors.amber),
                ),
              ),

              const SizedBox(height: 16),

              Text(pet.name, style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: 6),

              Text(
                '${pet.species} • ${pet.breed}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 6),

              Text(
                '${pet.age} years old',
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pet.status == 'Available'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pet.status == 'Available'
                      ? 'Available for Adoption'
                      : pet.status,
                  style: TextStyle(
                    color: pet.status == 'Available'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
