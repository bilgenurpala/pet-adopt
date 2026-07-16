import 'package:flutter/material.dart';

import '../models/pet.dart';

class PetCard extends StatelessWidget {
  const PetCard({required this.pet, super.key});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pet.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${pet.species} • ${pet.breed}'),
            const SizedBox(height: 4),
            Text('${pet.age} years old'),
            const SizedBox(height: 4),
            Text('${pet.price.toStringAsFixed(0)} ₺'),
            const Spacer(),
            Text(
              pet.status,
              style: TextStyle(
                color: pet.status == 'Available' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
