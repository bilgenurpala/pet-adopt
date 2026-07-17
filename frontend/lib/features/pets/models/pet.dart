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
    required this.status,
    required this.shelter,
    required this.vaccinated,
    required this.description,
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
  final String status;
  final String shelter;
  final bool vaccinated;
  final String description;
  final String? photoUrl;
}
