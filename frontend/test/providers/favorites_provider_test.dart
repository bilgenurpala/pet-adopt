import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/pets/providers/favorites_provider.dart';

void main() {
  group('FavoritesProvider Tests', () {
    test('Pet is added to favorites', () {
      final provider = FavoritesProvider();

      provider.toggleFavorite(1);

      expect(provider.isFavorite(1), isTrue);
      expect(provider.favoritePetIds.contains(1), isTrue);
    });

    test('Pet is removed from favorites', () {
      final provider = FavoritesProvider();

      provider.toggleFavorite(1);
      provider.toggleFavorite(1);

      expect(provider.isFavorite(1), isFalse);
      expect(provider.favoritePetIds.contains(1), isFalse);
    });

    test('Clear favorites removes all pets', () {
      final provider = FavoritesProvider();

      provider.toggleFavorite(1);
      provider.toggleFavorite(2);
      provider.clearFavorites();

      expect(provider.favoritePetIds, isEmpty);
    });
  });
}
