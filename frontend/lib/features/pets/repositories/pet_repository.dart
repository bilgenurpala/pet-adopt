import '../models/pet.dart';
import '../services/mock_pet_service.dart';
import '../services/pet_api_service.dart';

class PetRepository {
  const PetRepository({
    this.useMockData = true,
    this.apiService = const PetApiService(),
  });

  final bool useMockData;
  final PetApiService apiService;

  Future<List<Pet>> getPets() async {
    if (useMockData) {
      return MockPetService.getPets();
    }

    throw UnimplementedError('The pets endpoint is not available yet.');
  }

  Future<bool> checkBackendHealth() {
    return apiService.checkBackendHealth();
  }
}
