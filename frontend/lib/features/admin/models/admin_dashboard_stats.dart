class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalPets,
    required this.pendingPets,
    required this.totalApplications,
    required this.pendingApplications,
  });

  final int totalUsers;
  final int totalPets;
  final int pendingPets;
  final int totalApplications;
  final int pendingApplications;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: _parseInt(json['total_users']),
      totalPets: _parseInt(json['total_pets']),
      pendingPets: _parseInt(json['pending_pets']),
      totalApplications: _parseInt(json['total_applications']),
      pendingApplications: _parseInt(json['pending_applications']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
