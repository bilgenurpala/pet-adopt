import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AdoptionService {
  AdoptionService._();

  static Future<dynamic> getApplications() async {
    final response = await ApiClient.get(
      ApiEndpoints.adoptions,
      queryParameters: {'page': 1, 'per_page': 100},
    );

    return response.data;
  }

  static Future<dynamic> applyForPet(int petId) async {
    final response = await ApiClient.post(
      ApiEndpoints.adoptions,
      data: {'pet_id': petId},
    );

    return response.data;
  }
}
