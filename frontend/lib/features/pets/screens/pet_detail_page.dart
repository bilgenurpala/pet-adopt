import 'package:flutter/material.dart';

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
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.pets, size: 120, color: Colors.grey),
            ),

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

            if (pet.adoptionFee != null)
              _InfoTile(
                title: 'Adoption Fee',
                value: '\$${pet.adoptionFee!.toStringAsFixed(2)}',
              ),

            const SizedBox(height: 24),

            Text('About', style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 8),

            Text(pet.description, style: Theme.of(context).textTheme.bodyLarge),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Apply for Adoption'),
              ),
            ),
          ],
        ),
      ),
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
