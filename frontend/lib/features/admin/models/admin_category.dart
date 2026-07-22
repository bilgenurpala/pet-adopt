class AdminCategory {
  const AdminCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    final value = json['id'];

    return AdminCategory(
      id: value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
