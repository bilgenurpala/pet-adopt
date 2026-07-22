import '../../../core/network/api_endpoints.dart';

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
    required this.categoryId,
    required this.ownerId,
    required this.isApproved,
    required this.description,
    this.photoUrl,
    this.adoptionFee,
  });

  final int id;
  final String name;
  final String species;
  final String breed;
  final double age;
  final String gender;
  final String size;
  final String energyLevel;
  final String status;
  final int categoryId;
  final int ownerId;
  final bool isApproved;
  final String description;
  final String? photoUrl;
  final double? adoptionFee;

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      species: json['species']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      age: double.tryParse(json['age']?.toString() ?? '') ?? 0,
      gender: json['gender']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      energyLevel: json['energy_level']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      categoryId: _parseInt(json['category_id']),
      ownerId: _parseInt(json['owner_id']),
      isApproved: json['is_approved'] as bool? ?? false,
      description: json['description']?.toString() ?? '',
      photoUrl: _resolvePhotoUrl(json['photo_url']),
      adoptionFee: json['adoption_fee'] == null
          ? null
          : double.tryParse(json['adoption_fee'].toString()),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _resolvePhotoUrl(dynamic value) {
    final rawUrl = value?.toString().trim();

    if (rawUrl == null || rawUrl.isEmpty) {
      return null;
    }

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    final normalizedPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';

    return '${ApiEndpoints.baseUrl}$normalizedPath';
  }
}
