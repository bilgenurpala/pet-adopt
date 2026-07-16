class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.size,
    required this.energyLevel,
    required this.price,
    required this.status,
    this.description,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final String size;
  final String energyLevel;
  final double price;
  final String status;
  final String? description;
  final String? photoUrl;
}
