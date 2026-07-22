class AdminAdoptionApplication {
  const AdminAdoptionApplication({
    required this.id,
    required this.userId,
    required this.petId,
    required this.status,
    required this.applicantName,
    required this.applicantEmail,
    required this.petName,
    this.message,
    this.petPhotoUrl,
    this.createdAt,
  });

  final int id;
  final int userId;
  final int petId;
  final String status;
  final String applicantName;
  final String applicantEmail;
  final String petName;
  final String? message;
  final String? petPhotoUrl;
  final DateTime? createdAt;

  factory AdminAdoptionApplication.fromJson(Map<String, dynamic> json) {
    return AdminAdoptionApplication(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      petId: _parseInt(json['pet_id']),
      status: json['status']?.toString() ?? '',
      applicantName: json['applicant_name']?.toString() ?? '',
      applicantEmail: json['applicant_email']?.toString() ?? '',
      petName: json['pet_name']?.toString() ?? '',
      message: _cleanString(json['message']),
      petPhotoUrl: _cleanString(json['pet_photo_url']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _cleanString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }
}
