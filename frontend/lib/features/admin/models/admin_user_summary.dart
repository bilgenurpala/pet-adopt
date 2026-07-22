class AdminUserSummary {
  const AdminUserSummary({
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

  bool get isAdmin => role == 'admin';

  AdminUserSummary copyWith({String? role}) {
    return AdminUserSummary(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      role: role ?? this.role,
    );
  }

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    return AdminUserSummary(
      id: _parseInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
