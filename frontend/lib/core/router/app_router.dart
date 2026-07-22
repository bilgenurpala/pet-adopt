import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/pets/screens/favorites_page.dart';
import '../widgets/main_navigation.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: RouteNames.home,
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (!authProvider.isInitialized) {
          return null;
        }

        final isLoggedIn = authProvider.isAuthenticated;
        final isOnLoginPage = state.matchedLocation == RouteNames.login;

        if (!isLoggedIn && !isOnLoginPage) {
          return RouteNames.login;
        }

        if (isLoggedIn && isOnLoginPage) {
          return RouteNames.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
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
}
