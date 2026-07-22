class Adoption {
  const Adoption({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petImageUrl,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int petId;
  final String petName;
  final String? petImageUrl;
  final String status;
  final DateTime createdAt;

  factory Adoption.fromJson(Map<String, dynamic> json) {
    return Adoption(
      id: json['id'] as int,
      petId: json['pet_id'] as int,
      petName: json['pet_name'] as String? ?? '',
      petImageUrl: json['pet_photo_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
