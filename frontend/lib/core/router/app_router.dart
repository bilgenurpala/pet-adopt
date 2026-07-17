import 'package:go_router/go_router.dart';

import '../widgets/main_navigation.dart';
import '../../features/pets/screens/favorites_page.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: RouteNames.favorites,
        builder: (context, state) => const FavoritesPage(),
      ),
    ],
  );
}
