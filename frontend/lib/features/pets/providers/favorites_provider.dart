import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<int> _favoritePetIds = {};

  Set<int> get favoritePetIds => _favoritePetIds;

  bool isFavorite(int petId) {
    return _favoritePetIds.contains(petId);
  }

  void toggleFavorite(int petId) {
    if (_favoritePetIds.contains(petId)) {
      _favoritePetIds.remove(petId);
    } else {
      _favoritePetIds.add(petId);
    }

    notifyListeners();
  }

  void clearFavorites() {
    _favoritePetIds.clear();
    notifyListeners();
  }
}
