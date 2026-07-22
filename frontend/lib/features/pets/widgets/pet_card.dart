import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../models/pet.dart';
import '../providers/favorites_provider.dart';
import '../screens/pet_detail_page.dart';

class PetCard extends StatelessWidget {
  const PetCard({required this.pet, super.key});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final isAvailable = pet.status.toLowerCase() == 'available';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PetDetailPage(pet: pet)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 170,
                  width: double.infinity,
                  color: AppColors.primaryLight,
                  child: pet.photoUrl != null
                      ? Image.network(
                          pet.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _PetImagePlaceholder();
                          },
                        )
                      : const _PetImagePlaceholder(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, _) {
                      final isFavorite = favoritesProvider.isFavorite(pet.id);

                      return Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          tooltip: isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          onPressed: () async {
                            await favoritesProvider.toggleFavorite(pet);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? AppColors.favorite
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.breed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.pets,
                          size: 17,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pet.species,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAvailable ? 'Available for Adoption' : pet.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isAvailable
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetImagePlaceholder extends StatelessWidget {
  const _PetImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.pets, size: 72, color: AppColors.primary),
    );
  }
}
