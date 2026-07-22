import '../models/pet.dart';
import '../services/pet_api_service.dart';

class PetRepository {
  const PetRepository({this.apiService = const PetApiService()});

  final PetApiService apiService;

  Future<List<Pet>> getPets({
    int page = 1,
    int perPage = 100,
    String? species,
    String? size,
    String? energyLevel,
    String? status,
  }) {
    return apiService.getPets(
      page: page,
      perPage: perPage,
      species: species,
      size: size,
      energyLevel: energyLevel,
      status: status,
    );
  }

  Future<Pet> getPetById(int petId) {
    return apiService.getPetById(petId);
  }

  Future<List<Pet>> getFavoritePets({int page = 1, int perPage = 100}) {
    return apiService.getFavoritePets(page: page, perPage: perPage);
  }

  Future<void> addFavorite(int petId) {
    return apiService.addFavorite(petId);
  }

  Future<void> removeFavorite(int petId) {
    return apiService.removeFavorite(petId);
  }

  Future<List<Pet>> getMyPets({int page = 1, int perPage = 100}) {
    return apiService.getMyPets(page: page, perPage: perPage);
  }

  Future<List<Pet>> getPendingPets({int page = 1, int perPage = 100}) {
    return apiService.getPendingPets(page: page, perPage: perPage);
  }

  Future<bool> checkBackendHealth() {
    return apiService.checkBackendHealth();
  }
}
