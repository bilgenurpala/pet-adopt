import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static String get aiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8001';
    }

    return 'http://127.0.0.1:8001';
  }

  static const String health = '/health';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  static const String currentUser = '/users/me';

  static const String pets = '/pets';
  static const String favorites = '/favorites';
  static const String adoptions = '/adoptions';
  static const String assistant = '/assistant';

  static String petDetail(int petId) => '/pets/$petId';

  static String petPhoto(int petId) => '/pets/$petId/photo';

  static String approvePet(int petId) => '/pets/$petId/approve';

  static String adoptionDetail(int adoptionId) => '/adoptions/$adoptionId';

  static String adoptionStatus(int adoptionId) =>
      '/adoptions/$adoptionId/status';
}
