import '../../pets/models/pet.dart';
import '../models/admin_category.dart';
import '../models/admin_adoption_application.dart';
import '../models/admin_dashboard_stats.dart';
import '../models/admin_user_summary.dart';
import '../services/admin_api_service.dart';

class AdminRepository {
  const AdminRepository({this.service = const AdminApiService()});

  final AdminApiService service;

  Future<AdminDashboardStats> getStats() async {
    final data = await service.getStats();
    return AdminDashboardStats.fromJson(data);
  }

  Future<int> getCurrentUserId() async {
    final data = await service.getCurrentUser();
    final value = data['id'];

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<List<Pet>> getPendingPets({int page = 1, int perPage = 50}) async {
    final items = await service.getPendingPets(page: page, perPage: perPage);
    return items.whereType<Map<String, dynamic>>().map(Pet.fromJson).toList();
  }

  Future<List<Pet>> getPets({int page = 1, int perPage = 50}) async {
    final items = await service.getPets(page: page, perPage: perPage);
    return items.whereType<Map<String, dynamic>>().map(Pet.fromJson).toList();
  }

  Future<List<AdminCategory>> getCategories({
    int page = 1,
    int perPage = 50,
  }) async {
    final items = await service.getCategories(page: page, perPage: perPage);
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminCategory.fromJson)
        .toList();
  }

  Future<List<AdminAdoptionApplication>> getApplications({
    int page = 1,
    int perPage = 50,
    String? status,
  }) async {
    final items = await service.getApplications(
      page: page,
      perPage: perPage,
      status: status,
    );
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminAdoptionApplication.fromJson)
        .toList();
  }

  Future<List<AdminUserSummary>> getUsers({
    int page = 1,
    int perPage = 50,
  }) async {
    final items = await service.getUsers(page: page, perPage: perPage);
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminUserSummary.fromJson)
        .toList();
  }

  Future<void> approvePet(int petId) => service.approvePet(petId);

  Future<void> deletePet(int petId) => service.deletePet(petId);

  Future<Pet> createPet(Map<String, dynamic> data) async {
    return Pet.fromJson(await service.createPet(data));
  }

  Future<Pet> updatePet(int petId, Map<String, dynamic> data) async {
    return Pet.fromJson(await service.updatePet(petId, data));
  }

  Future<void> updateApplicationStatus(int adoptionId, String status) =>
      service.updateAdoptionStatus(adoptionId, status);

  Future<void> updateUserRole(int userId, String role) =>
      service.updateUserRole(userId, role);

  Future<AdminUserSummary> updateUser(
    int userId,
    Map<String, dynamic> data,
  ) async {
    return AdminUserSummary.fromJson(await service.updateUser(userId, data));
  }

  Future<void> deleteUser(int userId) => service.deleteUser(userId);
}
