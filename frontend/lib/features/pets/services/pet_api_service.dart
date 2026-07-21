import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/pet.dart';

class PetApiService {
  const PetApiService();

  Future<List<Pet>> getPets({
    int page = 1,
    int perPage = 100,
    String? species,
    String? size,
    String? energyLevel,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (species != null && species.isNotEmpty) {
      queryParameters['species'] = species;
    }

    if (size != null && size.isNotEmpty) {
      queryParameters['size'] = size;
    }

    if (energyLevel != null && energyLevel.isNotEmpty) {
      queryParameters['energy_level'] = energyLevel;
    }

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await ApiClient.get(
      ApiEndpoints.pets,
      queryParameters: queryParameters,
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid pets response.');
    }

    final items = data['items'];

    if (items is! List) {
      throw const FormatException('Pet list was not returned.');
    }

    return items.whereType<Map<String, dynamic>>().map(Pet.fromJson).toList();
  }

  Future<Pet> getPetById(int petId) async {
    final response = await ApiClient.get(ApiEndpoints.petDetail(petId));

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid pet response.');
    }

    return Pet.fromJson(data);
  }

  Future<bool> checkBackendHealth() async {
    final response = await ApiClient.get(ApiEndpoints.health);

    final data = response.data;

    return response.statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['status'] == 'ok';
  }
}
