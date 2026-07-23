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
    final normalizedStatus = pet.status.trim().toLowerCase();
    final isAvailable = normalizedStatus == 'available';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => PetDetailPage(pet: pet)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PetImage(photoUrl: pet.photoUrl),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, _) {
                        final isFavorite = favoritesProvider.isFavorite(pet.id);

                        return Material(
                          color: Colors.white,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              tooltip: isFavorite
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                              onPressed: () async {
                                await favoritesProvider.toggleFavorite(pet);
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.favorite
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.pets_outlined,
                        size: 14,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _capitalize(pet.species),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isAvailable
                              ? 'Available'
                              : _statusLabel(normalizedStatus),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isAvailable
                                ? AppColors.success
                                : AppColors.warning,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Pet';
    }

    return '${trimmedValue[0].toUpperCase()}'
        '${trimmedValue.substring(1).toLowerCase()}';
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'adopted':
        return 'Adopted';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return _capitalize(status);
    }
  }
}

class _PetImage extends StatelessWidget {
  const _PetImage({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();

    if (url == null || url.isEmpty) {
      return const _PetImagePlaceholder();
    }

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: AppColors.primaryLight,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const _PetImagePlaceholder();
      },
    );
  }
}

class _PetImagePlaceholder extends StatelessWidget {
  const _PetImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: const Icon(Icons.pets, size: 48, color: AppColors.primary),
    );
  }
}
