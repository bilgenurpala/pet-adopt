import '../models/pet.dart';

class MockPetService {
  static List<Pet> getPets() {
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
        price: 8500,
        status: 'Available',
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
        price: 6500,
        status: 'Available',
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
        price: 7200,
        status: 'Reserved',
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
        price: 7800,
        status: 'Available',
      ),
    ];
  }
}
