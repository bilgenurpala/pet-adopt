import '../models/pet.dart';

class MockPetService {
  const MockPetService._();

  static Future<List<Pet>> getPets() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      Pet(
        id: 1,
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        age: 2,
        gender: 'Male',
        size: 'Large',
        energyLevel: 'High',
        status: 'Available',
        shelter: 'Happy Paws Shelter',
        vaccinated: true,
        description:
            'Buddy is a friendly and energetic Golden Retriever who enjoys long walks and playing with children.',
      ),
      Pet(
        id: 2,
        name: 'Luna',
        species: 'Cat',
        breed: 'British Shorthair',
        age: 1,
        gender: 'Female',
        size: 'Medium',
        energyLevel: 'Medium',
        status: 'Available',
        shelter: 'Hope Animal Center',
        vaccinated: true,
        description:
            'Luna is a calm indoor cat looking for a loving family and a quiet home.',
      ),
      Pet(
        id: 3,
        name: 'Charlie',
        species: 'Dog',
        breed: 'Beagle',
        age: 3,
        gender: 'Male',
        size: 'Medium',
        energyLevel: 'High',
        status: 'Reserved',
        shelter: 'Love Pets Rescue',
        vaccinated: true,
        description:
            'Charlie is an intelligent Beagle with a playful personality who loves outdoor activities.',
      ),
      Pet(
        id: 4,
        name: 'Milo',
        species: 'Cat',
        breed: 'Scottish Fold',
        age: 2,
        gender: 'Male',
        size: 'Small',
        energyLevel: 'Low',
        status: 'Available',
        shelter: 'Happy Tails Shelter',
        vaccinated: false,
        description:
            'Milo is a gentle and affectionate cat who enjoys relaxing and spending time with people.',
      ),
    ];
  }
}
