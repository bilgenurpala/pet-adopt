abstract final class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Health
  static const String health = '/health';

  // Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  // Users
  static const String currentUser = '/users/me';
  static const String users = '/users';

  // Pets
  static const String pets = '/pets';

  static String petDetail(int petId) => '/pets/$petId';
  static String petPhoto(int petId) => '/pets/$petId/photo';
  static String approvePet(int petId) => '/pets/$petId/approve';

  // Categories
  static const String categories = '/categories';

  static String categoryDetail(int categoryId) => '/categories/$categoryId';

  // Adoptions
  static const String adoptions = '/adoptions';

  static String adoptionDetail(int adoptionId) => '/adoptions/$adoptionId';

  static String adoptionStatus(int adoptionId) =>
      '/adoptions/$adoptionId/status';

  // Favorites
  // Backend endpoints are not available yet.
  static const String favorites = '/favorites';

  // AI
  static const String aiChat = '/ai/chat';
}
