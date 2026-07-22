import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adoptions/providers/adoption_provider.dart';
import '../models/pet.dart';

class PetDetailPage extends StatelessWidget {
  const PetDetailPage({required this.pet, super.key});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PetPhoto(photoUrl: pet.photoUrl),
            const SizedBox(height: 24),
            Text(pet.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '${pet.species} • ${pet.breed}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            _InfoTile(title: 'Age', value: '${pet.age} years'),
            _InfoTile(title: 'Gender', value: pet.gender),
            _InfoTile(title: 'Size', value: pet.size),
            _InfoTile(title: 'Energy Level', value: pet.energyLevel),
            _InfoTile(title: 'Status', value: pet.status),
            _InfoTile(title: 'Category', value: pet.categoryId.toString()),
            _InfoTile(title: 'Owner', value: pet.ownerId.toString()),
            _InfoTile(title: 'Approved', value: pet.isApproved ? 'Yes' : 'No'),
            const SizedBox(height: 24),
            Text('About', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(pet.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Consumer<AdoptionProvider>(
                builder: (context, adoptionProvider, _) {
                  final alreadyApplied = adoptionProvider.hasApplicationForPet(
                    pet.id,
                  );

                  final canApply =
                      pet.isApproved &&
                      pet.status.toLowerCase() == 'available' &&
                      !alreadyApplied;

                  return ElevatedButton(
                    onPressed: adoptionProvider.isSubmitting || !canApply
                        ? null
                        : () async {
                            final success = await adoptionProvider.applyForPet(
                              pet.id,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Application submitted successfully.'
                                        : adoptionProvider.errorMessage ??
                                              'Application failed.',
                                  ),
                                ),
                              );
                          },
                    child: adoptionProvider.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            alreadyApplied
                                ? 'Application Submitted'
                                : !pet.isApproved
                                ? 'Waiting for Approval'
                                : pet.status.toLowerCase() != 'available'
                                ? 'Not Available'
                                : 'Apply for Adoption',
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetPhoto extends StatelessWidget {
  const _PetPhoto({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: url == null || url.isEmpty
            ? const _PhotoPlaceholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const _PhotoPlaceholder();
                },
              ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.pets, size: 120, color: Colors.grey),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
