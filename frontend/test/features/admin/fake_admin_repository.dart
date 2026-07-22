import 'package:frontend/features/admin/models/admin_adoption_application.dart';
import 'package:frontend/features/admin/models/admin_category.dart';
import 'package:frontend/features/admin/models/admin_dashboard_stats.dart';
import 'package:frontend/features/admin/models/admin_user_summary.dart';
import 'package:frontend/features/admin/repositories/admin_repository.dart';
import 'package:frontend/features/pets/models/pet.dart';

class FakeAdminRepository extends AdminRepository {
  FakeAdminRepository({
    this.stats = const AdminDashboardStats(
      totalUsers: 0,
      totalPets: 0,
      pendingPets: 0,
      totalApplications: 0,
      pendingApplications: 0,
    ),
    this.currentUserId = 1,
    List<Pet> pets = const [],
    List<AdminCategory> categories = const [AdminCategory(id: 1, name: 'Dogs')],
    List<Pet> pendingPets = const [],
    List<AdminAdoptionApplication> applications = const [],
    List<AdminUserSummary> users = const [],
  }) : pets = List.of(pets),
       categories = List.of(categories),
       pendingPets = List.of(pendingPets),
       applications = List.of(applications),
       users = List.of(users);

  AdminDashboardStats stats;
  int currentUserId;
  List<Pet> pets;
  List<AdminCategory> categories;
  List<Pet> pendingPets;
  List<AdminAdoptionApplication> applications;
  List<AdminUserSummary> users;

  Object? statsError;
  Object? currentUserError;
  Object? pendingPetsError;
  Object? petsError;
  Object? categoriesError;
  Object? applicationsError;
  Object? usersError;
  Object? approvePetError;
  Object? deletePetError;
  Object? updateApplicationError;
  Object? updateUserRoleError;
  Object? updateUserError;
  Object? deleteUserError;

  int? approvedPetId;
  int? deletedPetId;
  int? updatedApplicationId;
  String? updatedApplicationStatus;
  int? updatedUserId;
  String? updatedUserRole;
  Map<String, dynamic>? updatedUserData;
  int? deletedUserId;
  String? requestedApplicationStatus;

  @override
  Future<AdminDashboardStats> getStats() async {
    if (statsError != null) {
      throw statsError!;
    }

    return stats;
  }

  @override
  Future<int> getCurrentUserId() async {
    if (currentUserError != null) {
      throw currentUserError!;
    }

    return currentUserId;
  }

  @override
  Future<List<Pet>> getPendingPets({int page = 1, int perPage = 50}) async {
    if (pendingPetsError != null) {
      throw pendingPetsError!;
    }

    return List.of(pendingPets);
  }

  @override
  Future<List<Pet>> getPets({int page = 1, int perPage = 50}) async {
    if (petsError != null) {
      throw petsError!;
    }

    return List.of(pets);
  }

  @override
  Future<List<AdminCategory>> getCategories({
    int page = 1,
    int perPage = 50,
  }) async {
    if (categoriesError != null) {
      throw categoriesError!;
    }

    return List.of(categories);
  }

  @override
  Future<List<AdminAdoptionApplication>> getApplications({
    int page = 1,
    int perPage = 50,
    String? status,
  }) async {
    requestedApplicationStatus = status;

    if (applicationsError != null) {
      throw applicationsError!;
    }

    return List.of(applications);
  }

  @override
  Future<List<AdminUserSummary>> getUsers({
    int page = 1,
    int perPage = 50,
  }) async {
    if (usersError != null) {
      throw usersError!;
    }

    return List.of(users);
  }

  @override
  Future<void> approvePet(int petId) async {
    approvedPetId = petId;

    if (approvePetError != null) {
      throw approvePetError!;
    }
  }

  @override
  Future<void> deletePet(int petId) async {
    deletedPetId = petId;

    if (deletePetError != null) {
      throw deletePetError!;
    }
  }

  @override
  Future<void> updateApplicationStatus(int adoptionId, String status) async {
    updatedApplicationId = adoptionId;
    updatedApplicationStatus = status;

    if (updateApplicationError != null) {
      throw updateApplicationError!;
    }
  }

  @override
  Future<void> updateUserRole(int userId, String role) async {
    updatedUserId = userId;
    updatedUserRole = role;

    if (updateUserRoleError != null) {
      throw updateUserRoleError!;
    }
  }

  @override
  Future<AdminUserSummary> updateUser(
    int userId,
    Map<String, dynamic> data,
  ) async {
    updatedUserId = userId;
    updatedUserData = data;

    if (updateUserError != null) {
      throw updateUserError!;
    }

    final user = users.firstWhere((item) => item.id == userId);
    return user.copyWith(
      username: data['username']?.toString(),
      email: data['email']?.toString(),
      fullName: data['full_name']?.toString(),
    );
  }

  @override
  Future<void> deleteUser(int userId) async {
    deletedUserId = userId;

    if (deleteUserError != null) {
      throw deleteUserError!;
    }
  }
}
