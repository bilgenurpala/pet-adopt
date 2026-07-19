abstract final class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Health
  static const String health = '/health';

  // Pets
  static const String pets = '/pets';
  static const String petDetail = '/pets';

  // Categories
  static const String categories = '/categories';

  // Favorites
  static const String favorites = '/favorites';

  // Adoption
  static const String adoptions = '/adoptions';

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';

  // AI
  static const String aiChat = '/ai/chat';
}
