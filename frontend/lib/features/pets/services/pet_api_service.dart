import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class PetApiService {
  const PetApiService();

  Future<bool> checkBackendHealth() async {
    final response = await ApiClient.get(ApiEndpoints.health);

    final data = response.data;

    return response.statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['status'] == 'ok';
  }
}
