class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;

  bool get isAdmin => role.toLowerCase() == 'admin';

  String get displayName {
    final trimmedFullName = fullName.trim();

    if (trimmedFullName.isNotEmpty) {
      return trimmedFullName;
    }

    return username;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
